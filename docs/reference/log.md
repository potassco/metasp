---
icon: "material/format-list-text"
---

## Basic Logging

Logging is available to see the internal process of the meta-system. To enable logging, use the `--log` option followed by the desired log level.

The debug logs will show how formulas are internally matched.

!!! example

    If we run the example from the [quick start guide](../../use/quick-start) with debug logs, we can see how the formulas are being matched to the grammar:

    ```console
    metasp solve clingo example.lp --syntax-encoding syntax.lp --semantics-encoding semantics.lp --log debug
    ```


    ```console
    ==============================
    DEBUG:  - 🟧 Matching -> &and(a,&not(b))
    DEBUG:  - ------------------------------
    DEBUG:  - 🔶 Trying to match &and(a,&not(b)) as top level type atom
    DEBUG:  - ******************************
    DEBUG:  - ▶️ Trying to match symbol &and(a,&not(b)) as type atom
    DEBUG:  - No match of symbol &and(a,&not(b)) as type atom: Type mismatch for symbol &and(a,&not(b)) expected atom, but matches only with: ['bool']. Will try to remove sugar.
    DEBUG:  - Looking for sugar in type atom and its subtypes ['atom']
    DEBUG:  - No syntactic sugar removed for &and(a,&not(b))
    DEBUG:  - ******************************

    DEBUG:  - Not possible to match with top-level type atom
    DEBUG:  - ------------------------------
    DEBUG:  - 🔶 Trying to match &and(a,&not(b)) as top level type bool
    DEBUG:  - ******************************
    DEBUG:  - ▶️ Trying to match symbol &and(a,&not(b)) as type bool
    DEBUG:  - ☑️ Matched expression and of type bool
    DEBUG:  -   Trying to match arguments...
    DEBUG:  - ******************************
    DEBUG:  - ▶️ Trying to match symbol a as type bool
    DEBUG:  - ✅ Symbol a is base type atom, returning directly
    DEBUG:  - ******************************

    DEBUG:  - ******************************
    DEBUG:  - ▶️ Trying to match symbol &not(b) as type bool
    DEBUG:  - ☑️ Matched expression not of type bool
    DEBUG:  -   Trying to match arguments...
    DEBUG:  - ******************************
    DEBUG:  - ▶️ Trying to match symbol b as type bool
    DEBUG:  - ✅ Symbol b is base type atom, returning directly
    DEBUG:  - ******************************

    DEBUG:  -   All arguments matched!
    DEBUG:  - ✅ Symbol &not(b) is type bool, with expression (not,1)
    DEBUG:  - ******************************

    DEBUG:  -   All arguments matched!
    DEBUG:  - ✅ Symbol &and(a,&not(b)) is type bool, with expression (and,2)
    DEBUG:  - ******************************

    DEBUG:  - ✳️ Matched top-level symbol &and(a,&not(b)) as type bool.
    INFO :  - Matched &and(a,&not(b)) as types: ['bool']
    DEBUG:  -
    ==============================
    ```

## Logging from ASP encodings

The meta-system also allows to log from the ASP semantics encodings using by generating atoms of predicate `_log/2` with the desired log level and message as arguments.
These logs will be printed in the console before the model using normal logging:
this means that only logs with level higher or equal to the one specified in the command line will be printed.

!!! example

    In the semantics of the example from the [quick start guide](../../use/quick-start) we can add the following line to log a warning when two negations are nested:

    `semantics.lp`
    ```clingo
    has_not(&not(F)) :- formula(bool, &not(F)).
    _log(warning, nested_negation(&not(F))):- formula(bool, &not(F)), has_not(F).
    ```

    `example.lp`
    ```clingo
    {a}.
    :- &not(&not(a)).
    ```

    Then when we run the system we will get the following output:

    ```console
    > metasp solve clingo example.lp --syntax-encoding syntax.lp --semantics-encoding semantics.lp 0

    Metasp (<class 'metasp.app.ClingoApp'>) version 5.8.0
    Reading from examples.lp
    Solving...
    Answer: 1 (Time: 0.151s)
    WARNING:  - nested_negation(__not(__not(a)))
    a
    SATISFIABLE

    Models       : 1
    Calls        : 1
    Time         : 0.151s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
    CPU Time     : 0.143s
    ```
