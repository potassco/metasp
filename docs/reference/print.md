---
icon: "material/printer"
---

# Printing

To print the models obtained by the meta-system, one can define a custom Python function or use one of the available print functions.

!!! note
    By default, if no print function is specified, the models will be printed using the default output of the solver.

## Available print functions

All available print functions are listed in the [API documentation](../../api/#metasp.printing).

## Custom print function

To define a custom print function, you can create a Python script that contains the function. The function should take a model and a [Meta System](../../api/#metasp.system) as input and print the desired output to `stdout`.

In the melingo example, we define a custom print function in `melingo/print_functions.py`:

```python
--8<-- "examples/melingo/print_functions.py"
```
