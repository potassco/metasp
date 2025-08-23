# Telingo

This example uses metasp to define a system that works like [telingo](https://github.com/potassco/telingo) (See also [the paper](https://www.cs.uni-potsdam.de/wv/publications/DBLP_conf/lpnmr/CabalarKMS19.pdf)).
Unlike in the original telingo, we using meta-programming in ASP and don't do it incrementally.
It provides temporal predicates following the grammar for LTLf without past operators.

## Configuration

```yaml
metasp-systems:
  - name: telingo
    description: "Meta ASP system for temporal equilibrium logic (TEL)."
    control-name: clingo
    syntax-encoding:
      - "./telingo/syntax.lp"
    semantics-encoding:
      - "./telingo/semantics.lp"
    print-model: telingo_print_model
    constants:
      - "horizon"
```

This configuration defines a meta-system named `telingo` that uses the `clingo` solver.


## Syntax

```clingo
--8<-- "examples/telingo/syntax.lp"
```

## Semantics

```clingo
--8<-- "examples/telingo/semantics.lp"
```

## Examples

!!! example "Light example"

    Already preprocessed instance

    ```clingo
    --8<-- "examples/telingo/lights-encoding-preprocessed.lp"
    ```


    To run the lights example, use the following command:

    ```bash
    cd examples
    metasp telingo solve telingo/lights-encoding-preprocessed.lp -c horizon=4
    ```

    *output*
    ```bash
    clingo version 5.7.1
    Reading from telingo/lights-encoding-preprocessed.lp
    Solving...
    Answer: 1
    State 0:
    State 1:
    push
    State 2:
    State 3:
    State 4:

    SATISFIABLE

    Models       : 1+
    Calls        : 1
    Time         : 0.012s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
    CPU Time     : 0.008s
    ```

    Notice that it only shows the `push` due to the show statements
