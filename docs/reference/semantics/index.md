---
title: "Semantics"
icon: "material/head-question"
---


The semantics encoding defines the semantics of the meta-system, specifying how the reified program is interpreted and how the models are generated.
This encoding must also give semantics to the ASP rules, for this you can include the provided encodings below.

!!! warning

    If your semantics encoding has `#include` statements,
    the included files can't use `&operator` syntax, as they will not be resolved by *metasp* and will lead to errors.
    If you wish to use multiple files specify multiple `--semantics-encoding`, which can be simplified with a `config.yml` file.

## Systems

The semantics encodings might use a different solver. For instance in the [MEL example](../../examples/mel) we use `clingcon` syntax.
The specific system will be selected when running the `solve` command of *metasp*, providing the corresponding solver as argument.

### Available systems

- [`clingo`](https://potassco.org/clingo/)
- [`clingcon`](https://potassco.org/clingcon/)
- [`fclingo`](https://potassco.org/fclingo/)

If you need another system, please open an issue in [GitHub](https://github.com/potassco/metasp).

## Available encodings

To simplify the writing of your semantics encoding
we provide a set of available encodings that can be imported using

```clingo
#include "metasp.<file_name>.lp".
```

Available encodings to be included in the semantics encoding:

### Basic encodings

- [`meta.lp`](encodings/meta.md): Provides the basic ASP semantics.
- [`show.lp`](encodings/show.md): Provides a basic show encoding to show the atoms in the output.
- [`reify-defined.lp`](encodings/reify-defined.md): Provides `#defined` for the predicates in the reified program, include it to avoid warnings when some features are not used.

### Time extension encodings

- [`meta-time.lp`](encodings/meta-time.md): Provides the basic ASP semantics with time extension.
- [`show-time.lp`](encodings/show-time.md): Provides a show encoding to show the atoms in the output with time extension.
