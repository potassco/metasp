# Melingo

This example uses metasp to define a system that works like the work presented in [Melingo](https://arxiv.org/pdf/2506.08150).


## Configuration

```yaml
metasp-systems:
  - name: melingo
    description: "Meta ASP system with for metric equilibrium logic (MEL) using clingcon as backend solver."
    control-name: clingcon
    syntax-encoding:
      - "./melingo/syntax.lp"
    semantics-encoding:
      - "./melingo/semantics.lp"
    python-scripts:
      - "./melingo/print_functions.py"
    print-model: melingo_print_model
    constants:
      - "horizon"
```
This configuration defines a meta-system named `melingo` that uses the `clingo` solver.


## Syntax

```clingo
--8<-- "examples/melingo/syntax.lp"
```

## Semantics

```clingo
--8<-- "examples/melingo/semantics.lp"
```
## Examples

!!! example "Light example"

    Already preprocessed instance

    ```clingo
    --8<-- "examples/melingo/lights-encoding-preprocessed.lp"
    ```


    To run the lights example, use the following command:

    ```bash
    cd examples
    metasp melingo melingo/lights-encoding-preprocessed.lp -c horizon=2  3
    ```

    *output*
    ```bash
        clingo version 5.7.1
        Reading from melingo/lights-encoding-preprocessed.lp
        Solving...
        Answer: 1
        State 0 @0:
        red
        State 1 @5:
        push
        red
        State 2 @15:
        green

        Answer: 2
        State 0 @0:
        red
        State 1 @5:
        push
        red
        State 2 @16:
        green

        Answer: 3
        State 0 @0:
        red
        State 1 @5:
        push
        red
        State 2 @17:
        green

        SATISFIABLE

        Models       : 3+
        Calls        : 1
        Time         : 0.008s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
        CPU Time     : 0.008s
    ```

