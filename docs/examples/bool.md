--8<-- "examples/bool/README.md"

-----------

## Example

!!! example "Simple example"

    ```clingo
    --8<-- "examples/bool/instances/simple.lp"
    ```

## Definition of the system

### Configuration

```yml
--8<-- "examples/bool/config.yml"
```

### Syntax

```clingo
--8<-- "examples/bool/syntax.lp"
```

### Semantics

Uses the provided standard encodings:

- [`meta.lp`](../reference/semantics/encodings/meta.md) for the meta predicates.
- [`show.lp`](../reference/semantics/encodings/show.md) for the show predicates.
- [`reify-defined.lp`](../reference/semantics/encodings/reify-defined.md) to avoid warnings for the reification predicates.


::: examples/bool/semantics.lp
    handler: asp
    options:
        encodings:
            git_link: true
        start_level: 4


