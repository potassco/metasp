---
hide:
  - navigation
---

# Getting started

## Installation

=== "Pip"

    ```console
    pip install metasp
    ```

=== "Development mode"

    ```console
    git clone https://github.com/potassco/metasp.git
    cd metasp
    pip install -e .[all]
    ```

    !!! warning

        Use only for development purposes

## Usage

### System configuration

To create a new meta-system one must provide a configuration file.
This file must be named `metasp.yml` and be placed in the directory from where metasp is called.

The configuration file has contains the following

Below is an example configuration for defining meta-systems in `metasp.yml`.
Each entry under `metasp-systems` describes a system, its solver, encodings, and additional options.
Notice that one file might define multiple systems or versions of a system that use different encodings.

```yaml
metasp-systems:
  - name: <system_name>
    description: "<Brief description of the meta-system>"
    solver: <solver_name>
    syntax-encoding:
      - "<path/to/syntax.lp>"
    semantics-encoding:
      - "<path/to/semantics.lp>"
    python-scripts:
      - "<path/to/script.py>"
    print-model: <python_function_to_print_model>
    constants:
      - "<constant_name>"
```

**Configuration fields:**

- `name`: Unique identifier for the meta-system. It will be made available in the command line as  `metasp <system_name>`
- `description`: Short summary of the system's purpose for rendering help.
- `solver`: Backend solver to use (e.g., `clingcon`, `clingo`), see [Solvers](reference/components/solver.md).
- `syntax-encoding`: List of relative paths to ASP files encoding the input language syntax, see [Syntax](reference/components/syntax.md).
- `semantics-encoding`: List of relative paths to ASP files encoding the system's semantics, see [Semantics](reference/components/semantics.md).
- `python-scripts`: Optional Python scripts for custom processing or printing, see [Printing](reference/components/printing.md).
- `print-model`: Python function (from scripts) to format output models, see [Printing](reference/components/printing.md).
- `constants`: List of constant parameters required by the system, each constant in this list will generate a corresponding attribute in the system. This attribute can be used in the printing of the model. In case the constant is not provided, an error will be raised.

You can define multiple systems by adding more entries to the `metasp-systems` list. Adjust paths and options as needed for your use case.

### Command line interface

Details about the command line usage can be found with:

```console
metasp -h
```

This will list the available systems based on the configuration, where each system can be selected for execution using their name.

When running a system with `metasp <system_name>` will be an extension of the command line options provided by the underlying solver, such as `clingo` or `clingcon`. The system will automatically handle the reification of the input and semantics encoding, while making available the command line options for the solver.

!!! example

    Move to the examples directory and you can run the systems

    ```
    cd examples
    ```



    ```console
    metasp example_system --solver clingo --other-options
    ```
