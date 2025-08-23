# Delingo

This example uses metasp to define a system that mixes the temporal equilibrium logic (TEL) with dynamic logic (DEL).
It is based on the work presented in [Delingo](https://www.cs.uni-potsdam.de/wv/publications/DBLP_conf/ecai/CabalarDSL20.pdf).
We, however, do not limit where the DEL operators can be used, allowing them to be used in the head and body of rules.
This can be done since we are not doing things incrementally.


## Configuration

```yaml
metasp-systems:
  - name: delingo
    description: "Meta ASP system joining temporal equilibrium logic (TEL) with dynamic logic (DEL)."
    control-name: clingo
    syntax-encoding:
      - "./telingo/syntax.lp"
      - "./delingo/syntax.lp"
    semantics-encoding:
      - "./telingo/semantics.lp"
      - "./delingo/semantics.lp"
    print-model: telingo_print_model
    constants:
      - "horizon"
```
This configuration defines a meta-system named `melingo` that uses the `clingo` solver.


## Syntax

```clingo
--8<-- "examples/delingo/syntax.lp"
```

## Semantics

```clingo
--8<-- "examples/delingo/semantics.lp"
```

## Examples

!!! example "Elevator example"

    Already preprocessed instance.
    We use the elevator example from [the paper](https://www.cs.uni-potsdam.de/wv/publications/DBLP_conf/ecai/CabalarDSL20.pdf).

    ```clingo
    --8<-- "examples/delingo/elevator-preprocessed.lp"
    ```


    To run the elevator example, use the following command:

    ```bash
    cd examples
    metasp delingo solve delingo/elevator-preprocessed.lp -c horizon=10 1
    ```

    *output*
    ```bash
        clingo version 5.7.1
        Reading from delingo/elevator-preprocessed.lp
        Solving...
        Answer: 1
        State 0:
        up
        at(3)
        State 1:
        up
        at(4)
        State 2:
        serve
        at(5)
        State 3:
        down
        at(5)
        State 4:
        down
        at(4)
        State 5:
        down
        at(3)
        State 6:
        down
        at(2)
        State 7:
        serve
        at(1)
        State 8:
        wait
        at(1)
        State 9:
        wait
        at(1)
        State 10:
        final
        at(1)

        SATISFIABLE

        Models       : 1+
        Calls        : 1
        Time         : 0.024s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
        CPU Time     : 0.024s
    ```

