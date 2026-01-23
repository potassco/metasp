---
icon: "material/brain"
---

# Controls

Controls are the backend engines that execute the logic programs defined in the meta-systems. They are wrappers of the [clingo.Control](https://potassco.org/clingo/python-api/5.5/clingo/control.html#clingo.control.Control) object and are responsible for processing the encodings and producing solutions based on the semantics defined in the meta-system configuration.

## Supported Controls

- **Clingo**: A popular ASP solver that supports various encodings and optimizations.
- **Clingcon**: An ASP solver that extends Clingo with support for linear constraints.
