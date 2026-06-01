---
icon: "material/printer"
---

# Printing

To print the models obtained by the meta-system in the command line, one can define a custom Python function or use one of the available print functions.

!!! tip "Show statements"

    To specify the atoms that you wish to include as *shown* check the [show statements](../../reference/transformations/show) section.

!!! note "Default printing"
    By default, if no print function is specified, the models will be printed using the default output of the solver.

## Available print functions

All available print functions are listed in the [API documentation](../api/#printing-functions).

## Create your own print function

To define a custom print function, you can create a Python script that contains the function. The function should take a model and a [Meta System](../../api/#metasp.system) as input and print the desired output to `stdout`.

The script and the function can then be specified when running the system with the `--printer` and `--python-scripts` options.

!!! example

    In the mel, we define a custom print function in `melingo/print_functions.py`:

    ```python
    --8<-- "examples/mel/print_functions.py"
    ```
