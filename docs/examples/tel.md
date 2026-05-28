--8<-- "examples/tel/README.md"

-----------

## Example

!!! example "Traffic Lights"

    ```clingo
    --8<-- "examples/tel/instances/paper-lights.lp"
    ```

## Definition of the system

### Configuration

```yml
--8<-- "examples/tel/config.yml"
```

### Syntax

```clingo
--8<-- "examples/tel/syntax.lp"
```

### Semantics

Uses the provided standard encodings:

- [`meta-time.lp`](../reference/semantics/encodings/meta-time.md) for the meta predicates with time support.
- [`show-time.lp`](../reference/semantics/encodings/show-time.md) for the show predicates with time support.
- [`reify-defined.lp`](../reference/semantics/encodings/reify-defined.md) to avoid warnings for the reification predicates.


::: examples/tel/semantics.lp
    handler: asp
    options:
        encodings:
            git_link: true
        start_level: 4


