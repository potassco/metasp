---
icon: "material/creation-outline"
---

# Transformations

There are several transformations that *metasp* applies to the input encodings to avoid grounding simplifications.

We use the [aspen](https://potassco.org/aspen) system to perform the first order transformations using ASP.
And the [meta-tools](https://potassco.org/meta-tools) system which simplifies the extension of the reified output.

The two main transformations consist of traanslating [show statements](./show)
into rules, and adding [externals](./externals) to avoid grounding simplifications of the reified program.
