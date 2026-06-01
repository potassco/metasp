---
icon: "material/monitor-eye"
---


With *metasp* we also provide integration with [clinguin](https://potassco.org/clinguin/).
A browser to interact with the models of your extension can be opened with the `ui` command.

```console
metasp ui -h
```

**Features**
- Browse solutions
- Set constants
- Download models
- See inferences
- Force atoms


!!! warning

    Use the option `--meta-config` to specify the configuration file with the syntax and semantics encodings of your extension, otherwise the UI will not work.


!!! example

    The UI for the [Boolean extension](../../examples/bool) can be opened with the following command:

    ```console
    metasp ui examples/bool/tests/and_not.test.lp --meta-config examples/bool/config.yml
    ```

    <img src="https://github.com/potassco/metasp/blob/master/examples/bool/ui.gif?raw=true">


## Customization

The UI can be further customized by including a `ui-encoding` in the configuration file, which can contain any ASP code to extend the basic UI encoding provided by *metasp*.


### Labels

Formulas in the UI can be shown with a custom label by defining a `label/2`, in the `ui-encoding` which takes an atom and its corresponding label as arguments.

!!! example

    For instance in [tel](../../examples/tel) we define the following labels for the temporal operators using an external python function

    ```clingo
    --8<-- "examples/tel/ui.lp"
    ```

### Extending the interface

The interface can be extended by defining new elements and attributes in the `ui-encoding` file. We advise looking in to the structure of the basic encoding in `src/metasp/encodings/ui.lp` to understand where to add new elements.

!!! example

    For instance in the [mel example](../../examples/mel) we add a footer to the interface showing the time of each model by including the following code in the `ui-encoding`:

    ```clingo
    --8<-- "examples/mel/ui.lp"
    ```


## UI encoding


::: src/metasp/encodings/ui.lp
    handler: asp
    options:
        encodings:
            git_link: true
        start_level: 2
