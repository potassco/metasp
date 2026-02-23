# metasp

## Installation

To install the project you must have Python 3.12 or higher, and run

```bash
pip install metasp
```

## Usage

Run the following for basic usage information:

```bash
metasp -h
```

This gives you three different modes of operation:
Here are the available modes:

- **solve**: Solve the processed and reified input files using the meta encoding for the semantics.
- **transform**: Output the transformed first-order program and perform syntactic checks.
- **reify**: Output the reification with extensions.
- **ui**: Launch the user interface mode.


### Solving


```bash
metasp solve <system> <input_files>
```

The first argument <system> specifies the system to use for solving, which can be either `clingo`, `clingcon` or `fclingo`.
In what follows we will use `clingo` as an example, but the same applies to the other systems.

Once this is provided you will get a normal `clingo` command line interface, where you can provide additional arguments to the solver.
For example, you can specify the number of models to compute with `-n 0`.
And directly add your input files.

You can see how to run different examples in the `examples` folder, each example contains a `README.md` file with instructions on how to run it

- [`examples/tel`](examples/tel) example of how to use the `tel` (Temporal Equilibrium Logic) extension.
- [`examples/del`](examples/del) example of how to use the `del` (Dynamic Equilibrium Logic) extension.
- [`examples/mel`](examples/mel) example of how to use the `mel` (Modal Equilibrium Logic) extension.

Notice all of them are under finite traces.


#### Metasp basic arguments

You can see the additional arguments for the `metasp` that indicate the extension.

```bash
metasp solve clingo -h
```
#### Additional Arguments

- **Logging**
    Use `--log` to set the logging level. For detailed parsing information, set it to `debug`.

- **Extension Files**
    - `--syntax-encoding`: Specify the path to syntax encoding files containing the grammar.
    - `--semantics-encoding`: Provide the path to semantics encoding files that define the semantic extension.

#### Output Configuration

- **Printer Function**
    Choose the printing function for models with `--printer`.
    - Default: Normal clingo print.
    - Alternative: `temporal_printer` (prints each state on a separate line).
    - Custom: Add your own printing functions using the `--python-scripts` argument.

- **Python Scripts**
    Use `--python-scripts` to load custom Python scripts before running the system.
    These scripts can contain custom printing functions.
    See the `examples/mel` folder for usage examples.

#### Command line tools

To avoid long command lines, you can use a YAML configuration file to set arguments for your extension. Here is an example structure:

```yaml
syntax-encoding:
    - "./syntax.lp"
semantics-encoding:
    - "./semantics.lp"
printer: temporal_printer
required-constants:
    - "n"
```

- **syntax-encoding**: List of syntax encoding files.
- **semantics-encoding**: List of semantics encoding files.
- **printer**: Printer function to use (e.g., `temporal_printer`).
- **required-constants**: Constants required for the encoding.

The `required-constants` field helps ensure all necessary constants are provided, preventing unexpected results when running the system.


### UI

To launch the user interface, provide your system configuration using the `--meta-config config.yml` argument.
The configuration file can optionally include a `ui-encoding` field to add extra encodings for UI generation.
The `ui-encoding` field is optional and can be used to enhance the UI generation with additional logic or features.
