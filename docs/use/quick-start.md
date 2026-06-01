---
icon: "material/rocket-launch"
---

# Quick Start Guide

A meta-system is defined by a [syntax encoding](../../reference/syntax) that specifies the input language,
and a [semantics encoding](../../reference/semantics) that defines the meaning of the new syntax as well as basic ASP constructs.
Both encodings are written in ASP and can be combined with custom Python scripts for output formatting or additional processing.

This guide will show you a step by step example of how to define a simple meta-system,
to extend ASP with a special with boolean formulas, particularly adding operators `&and` and `&not`,
such that we can write rules such as `c:- &and(a,&not(b)).`.

!!! tip "Examples"

    You can look at more complex examples in the [Examples](../../examples) section, for temporal extensions and more.

!!! tip "More information"

    Details on each aspect of *metasp* presented in this guide can be found in the [reference section](../../reference).

!!! tip "Structure"

    You don't need to clone the repository, we suggest you just create a folder to put your encodings and run the commands from there,
    installing *metasp* with pip as explained in the [installation guide](../installation).
    If you have multiple encoding version you are trying, you can have one [configuration file](#using-a-configuration-file) for each of them to simplify the command line usage.


## Syntax

First we need to define the syntax of the new operators in a `syntax.lp` file.
Details about the syntax encoding can be found in the [syntax](../../reference/syntax) section.
This definition of type `bool` has two expressions, `&and/2` and `&not/1` whose arguments are also booleans.
As a base case we make sure all atoms are also of type `bool` by defining `atom` as a subtype of `bool`.
The occurrence of the type is set to `any`, which means that it can appear anywhere in the encoding.

`syntax.lp`
```
#type bool{
    expressions: {
        &and/2 : {
            type: bool, safety: safe;
            type: bool, safety: safe;};
        &not/1 : {
            type: bool, safety: unsafe;};
    };
    subtypes:  { atom; };
    macros:   {};
    occurrence: any;
}.
```


By providing this syntax encoding to *metasp* we can now write rules using the new operators
and *metasp* will take care of the reification and grounding simplifications.

`example.lp`
```clingo
a.
c:- &and(a,&not(b)).
```

## Transformations

Using the `syntax.lp` encoding, *metasp* applies [transformations](../../reference/transformations) to the input program `example.lp`
to avoid simplifications. The transformed program can be inspected running the command:

```console
metasp transform example.lp --syntax-encoding syntax.lp
```

## Reification

The transformed file is used to generate an extended reified output which gives the original program structure,
plus the formulas found and their types.
This output can be inspected by running the command:


```console
metasp reify example.lp --syntax-encoding syntax.lp
```

This output contains the facts representing the grammar defined by `syntax.lp` additionally to the clingo reification
plus atoms of predicate `formula/2` for every sub-formula found in the input. In our case these are the following:


```clingo
formula(bool,a).
formula(atom,a).
formula(bool,b).
formula(atom,b).
formula(bool,&not(b)).
formula(bool,&and(a,&not(b))).
formula(bool,c).
formula(atom,c).
```

For more details on the rest of the reified output check [reified definitions](../../reference/semantics/encodings/reify-defined) and [reified metasp](../../reference/semantics/encodings/reified-metasp).

!!! tip "Debugging"

    To see how formulas are being match internally to the grammar you can add the `--log debug` argument to the command line, this will show the matching of the formulas to the grammar in the logs to detect potential issues with the syntax encoding.


## Semantics and solving

We use this extended reification as input to provide semantics to the ASP program and new operators by writing a [semantics](../../reference/semantics) encoding (`semantics.lp`).
This file might use syntax of another dedicated solver such as `clingcon` see the [`MEL` example](../../examples/mel).

The semantics encoding for our example is the following:

`semantics.lp`
```clingo
#include "metasp.show.lp".
#include "metasp.meta.lp".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #Not
                :- formula(bool, &not(F)), true(&not(F)), not not true(F).  % ? "not not"
true(&not(F))   :- formula(bool, &not(F)), not true(F).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #And
true(&and(F1,F2)) :- formula(bool, &and(F1,F2)), true(F1), true(F2).
true(F1):-true(&and(F1,F2)).
true(F2):-true(&and(F1,F2)).
```

This encoding includes the basic ASP semantics from [`metasp.meta.lp`](../../reference/semantics/encodings/meta) and the encoding to handle the `#show` statements from [`metasp.show.lp`](../../reference/semantics/encodings/show).
Additionally it provides semantics for the two new operators `&not` and `&and` for `bool` formulas.

We can put all together and run the meta-system to obtain solutions as follows:

```console
metasp solve clingo example.lp --syntax-encoding syntax.lp --semantics-encoding semantics.lp
```

This command will run the `clingo` solver on the processed and reified input files using the semantics defined in `semantics.lp`.
Notice that this command line extends the one of clingo (add `-h` to see the available options).
This means that we can add things like `-n 0` to get all the models or `-c n=3` to provide a constant `n`.

!!! info "Other systems"

    If we use another system, such as `clingcon`, we will have the options of `clingcon` available instead.


## Using a configuration file

To simplify the command line usage and avoid writing long commands with the syntax encoding and semantics encoding,
you can define a configuration file `config.yml` with the meta-system definition as follows:

`config.yml`
```yaml
syntax-encoding:
  - "./syntax.lp"
semantics-encoding:
  - "./semantics.lp"
```

Then you can run the system specified in the configuration file with the following command:

```console
metasp solve clingo example.lp --meta-config config.yml
```

!!! tip "Use"

    The configuration file can also be used for the other *metasp* commands.

!!! warning "Paths"

    The paths provided in the configuration file are relative to the configuration file itself.

Other options available in the configuration file as well as the command line are the following:

| Option | Description | Default |
|---|---|---|
| `--log=<level>` | Logging level. `<level> = {debug\|info\|error\|warning}` | `warning` |
| `--syntax-encoding=<file>` | Path to syntax encoding files with the grammar. | `None` |
| `--semantics-encoding=<file>` | Path to semantics encoding defining the semantic extension. | `None` |
| `--required-constants=<file>` | Constants required to run the system. An error is shown if they are not provided. | `None` |
| `--printer=<file>` | Name of the printing function to use for models. By default, uses clingo print. See [printing](../../reference/print) | `None` |
| `--python-scripts=<file>` | Path to Python scripts to load before running the system. These files can contain custom printing functions. | `None` |
| `--ui-encoding=<file>` | Path to UI encoding files extending basic encoding for interactivity. See [UI](../../reference/ui) | `None` |


## User interface

*metasp* also provides a user interface using [clinguin](https://potassco.org/clinguin) to interactively explore the models.
You can run the interface with the following command:

```console
metasp ui --meta-config config.yml example.lp
```

This will open a web interface where you can explore the models, see the atoms and formulas in each model, and more.

!!! tip "Command line"

    We suggest that you use the `config.yml` file to run the UI rather than specific command line arguments.


!!! tip "System"

    If you are using another system such as `clingcon` you can specify it in the command line in the configuration file.
    See the [MEL example](examples/mel) for more details on using the UI with `clingcon`.

## Testing

You can define tests for your meta-system as part of the ASP encodings, using comment-based definitions.
This can be used to ensure your system is working as expected and to detect potential issues when modifying the encodings.
Details about the test definitions can be found in the [testing](../../reference/test) section.
