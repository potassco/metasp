
# `meta.lp`

Gives ASP semantics for the reification predicates as done in [How to build your own ASP system?!](https://arxiv.org/abs/2008.06692)

!!! tip

    To avoid warnings, also include `reify-defined.lp` in your semantics encoding, which adds defined directives for the reification predicates.


::: src/metasp/encodings/meta.lp
    handler: asp
    options:
        glossary:
            include_references: false
        predicate_info:
            include_undocumented: false
        encodings:
            git_link: true
        start_level: 1
