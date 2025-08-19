# Semantics

The semantics encoding defines the meaning of the modalities and how they interact with each other.

To write the semantics encoding we provide a set of available encodings that can be imported using `#import "metasp.<file_name>.lp".`.
You can include such encodings to your semantics and write only the semantics relevant to your system.

## Provided Encodings

- [`meta.lp`](../encodings/meta.md): Adds ASP semantics for the reification predicates.
- [`derived.lp`](../encodings/derived.md): Provides support for derived predicates and their relationships.
- [`formulas.lp`](../encodings/formulas.md): Obtains the set of sub formulas present in the encoding with respect to the modalities defined in the  [syntax](./syntax.md).

### Time Support

- [`meta-time.lp`](../encodings/meta_time.md): Adds ASP semantics with a time argument to all predicates (use instead of [`meta.lp`](../encodings/meta.md)).
