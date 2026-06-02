---
hide:
  - navigation
  - toc
---

# metasp

A framework to ease the creation of Answer Set Programming (ASP) extensions using meta-programming.

The goal is to simplify the process of defining and running custom extensions by providing a structured way to specify syntax, semantics, and solver configurations.
Modelers can focus on the ASP encodings that define the details of their extension, while *metasp* takes care of the rest.

- No need for any Python coding!
- Supports different solvers such as *clingo*, *clingcon*, and more.
- No need to worry about grounding simplifications *metasp* takes care of that for you.
- Custom operators can be nested and appear anywhere in the encoding.

## Useful features

- [Customization of output](reference/print.md) through Python scripts.
- [Logging](reference/log.md) from the ASP encodings.
- Comment-based definition of [tests](reference/test.md) for your extension as part of the ASP encodings.
- Built in [clinguin](reference/ui.md) interface for interactive use.


!!! info
    *metasp* is part of the [Potassco](https://potassco.org) suite.


## Cite

!!! quote "Citation"

    **Meta-Programming for Linear-time Temporal Answer Set Programming**
    Susana Hahn, Amade Nems, Javier Romero, Torsten Schaub
    [arXiv:2605.29965](https://arxiv.org/abs/2605.29965)

    ```bibtex
    @article{hanerosc26a,
      title   = {Meta-Programming for Linear-time Temporal Answer Set Programming},
      author  = {S. Hahn and A. Nems and J. Romero and T. Schaub},
      journal = {arXiv preprint arXiv:2605.29965},
      year    = {2026},
      url     = {https://arxiv.org/abs/2605.29965}
    }
    ```
