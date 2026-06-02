---
icon: "material/list-status"
---

# Testing

To simplify the testing of the meta-system, for a given instance, *metasp* provides a comment-based description of tests withing the ASP instance file. This allows to easily specify the expected output for a given instance and check if the system is working as expected.

## Test definition

Tests are defined in the ASP instance file using line comments with the following format:

```clingo
% #TEST
% <command to run the test>
% - <shown symbols in model 1>
% - <shown symbols in model 2>
% ...
```

- The first line must be `% #TEST` to indicate the start of a test definition.
- The second line must contain the command to run the test, this command should include the necessary options to run the system and should be relative to the location of the instance file. `metasp solve` is not required in the command, as it will be added automatically when running the tests.
- The following lines must start with `% -` and contain the expected shown symbols in each model, one line per model. The order of the models and atoms within them is not relevant.


!!! info "Unsatisfiable instances"

     If the instance is expected to be unsatisfiable, the test definition should not include any expected model.


!!! info "Multiple tests"

    You can define multiple tests in the same file, each test will be run separately and the expected output will be checked against the actual output.

!!! tip "Naming"

    Instances with a test definition should be named "name.test.lp" to easily identify them as test instances, and in order for the automatic test discovery to find them when running the tests.

!!! tip "Usage"

    Since the tests are defined as comments in the instance files, they do not affect the normal execution of the system, and the same instance can be used both for testing and for normal runs.


!!! warning "Shown symbols"

    The atoms in the model of the test should be the ones shown in the output of the system.



!!! example

    Following the example from the [quick start guide](../../use/quick-start), we can define a test for the following instance:

    `examples/bool/tests/not_nested.test.lp`
    ```clingo
    --8<-- "examples/bool/tests/not_nested.test.lp"
    ```

## Running tests

To run the tests defined in the instance files, use the following command:

```bash
metasp test
```

This command will automatically discover all the instances in the current directory with test definitions (files with extension `.test.lp`) and run the tests defined in them, checking if the expected output matches the actual output.

You can also specify specific test files to run by providing them as arguments:

```bash
metasp test <file>.test.lp
```


!!! example

    If we run the tests for the instance defined in `examples/bool/tests/not_nested.test.lp` we will get the following output:

    ```bash
    > metasp test examples/bool/tests/not_nested.test.lp

    ========================================
    Running test 'not_nested.test.lp'
    ========================================
    Metasp (<class 'metasp.app.ClingoApp'>) version 5.8.0
    Reading from examples/bool/tests/not_nested.test.lp
    Solving...
    Answer: 1 (Time: 0.149s)
    WARNING:  - nested_negation(__not(__not(a)))
    a
    Answer: 2 (Time: 0.150s)
    WARNING:  - nested_negation(__not(__not(a)))
    b
    a
    SATISFIABLE

    Models       : 2
    Calls        : 1
    Time         : 0.150s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
    CPU Time     : 0.142s
    ✓ Test 'not_nested.test.lp' passed.

    -----------------------
    TEST Results: ✓

        Test passed!
    ```
