---
icon: "material/pen-plus"
---

# Syntax

The syntax encoding specifies the grammar and their safety, enabling checks and the generation of externals.
The grammar is used during preprocessing to generate formulas.

## Grammar definition

A grammar is defined as follows:

- `type(name)`, where `name` is the name of the grammar (e.g., `tel` for temporal logic).
- `subtype(parent, child)`, where `child` is a subtype of `parent`.
- `constructor(type, operator, arity, (arg1_type, ..., argN_type))`, where `type` is the type of formula the operator constructs, `operator` is the name of the operator, `arity` is the number of arguments, and `argX_type` is the type of the X-th argument (for `0 <= X < arity`).
- `arg(operator, position, property)`, where `position` is the argument position (0-indexed) and `property` is one of `unsafe`, `num`, or `fixed(X)`, indicating that the argument at `position` of `operator` has the given property.


**Built-in Types:**
- `atom`: Any atom, not matching any constructor
- `num`: Numeric arguments.


**Occurrence Restriction:**
- Use `allow(type, location)` to specify where a type can appear  where `location` is one of   `head`, `body`.


## Safety

## Derived operators
