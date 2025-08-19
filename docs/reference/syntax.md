---
icon: "material/pen-plus"
---

# Syntax

The syntax encoding specifies the modalities and their safety, enabling checks and the generation of externals.
Modalities are checked during preprocessing to store which atoms are part of the grammar.

## Modality definition

A grammar called `type` is defined as a set of modalities, each with a name and arity.

- `modality(type, operator, arity, argument_type)`, where `argument_type` is a tuple giving the type of each argument.

Alternatively `modality(type1, type2)` can be used to say that any atom matching grammar `type2` is also a modality of type `type1`.


**Built-in Types:**
- `atom`: Any atom, excluding modality operator names (consider renaming to `non_modality_atom`).
- `num`: Numeric arguments.
- `fixed(X)`: Fixed constant `X` (term or constant), possibly distinct from other constants.


**Occurrence Restriction:**
- Use `occurence(type, location)` to specify where modalities can appear  where `location` is one of   `head`, `body`.


## Safety

## Derived operators
