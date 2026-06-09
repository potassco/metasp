---
icon: "material/progress-clock"
---

--8<-- "examples/del/README.md"

-----------

## Example

!!! example "Traffic Lights"

    ```clingo
    --8<-- "examples/del/instances/paper-lights.lp"
    ```

## Definition of the system

### Configuration

```yml
--8<-- "examples/del/config.yml"
```

### Syntax

```clingo
--8<-- "examples/del/syntax.lp"
```

### Semantics

Uses the provided standard encodings:

- [`meta-time.lp`](../reference/semantics/encodings/meta-time.md) for the meta predicates with time support.
- [`show-time.lp`](../reference/semantics/encodings/show-time.md) for the show predicates with time support.
- [`reify-defined.lp`](../reference/semantics/encodings/reify-defined.md) to avoid warnings for the reification predicates.


::: examples/del/semantics.lp
    handler: asp
    options:
        encodings:
            git_link: true
        start_level: 4
