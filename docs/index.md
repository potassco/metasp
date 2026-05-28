---
hide:
  - navigation
  - toc
---

# metasp

A framework to ease the creation of Answer Set Programming (ASP) extensions using meta-programming.

The goal is to simplify the process of defining and running custom extensions by providing a structured way to specify syntax, semantics, and solver configurations.

- No need for any Python coding!
- Supports different solvers such as *clingo*, *clingcon*, and more.
- No need to worry about grounding simplifications metasp takes care of that for you.
- Modelers can focus on the ASP encodings that define the syntax and semantics of their systems, while *metasp* takes care of the rest.
- Extended operators can be nested and appear anywhere in the encoding.

## Useful features

- [Customization of output](reference/print.md) through Python scripts.
- [Logging](reference/log.md) from the ASP encodings.
- Comment-based definition of [tests](reference/test.md) for your extension as part of the ASP encodings.
- Built in [clinguin](reference/ui.md) interface for interactive use.


!!! info
    *metasp* is part of the [Potassco](https://potassco.org) suite.


## Cite
