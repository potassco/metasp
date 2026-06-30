# Show statements

Show statements that appear in the input are transformed to rules so that predicate `output/2`
always has the full set of symbols.
We use the introduced rules to extend the reified output with `show/0`, `show_atom/2` and `show_term/2` predicates
that can be used in the semantics encoding to show the corresponding atoms and formulas in the output.

See [reified defined](../../semantics/encodings/reify-defined) and [reify metasp](../../semantics/encodings/reify-metasp) for more details on the reification predicates and their semantics.

| Input | Internal Transformation |
|---|---|
| `#show.` | `_show.` |
| `#show p/N.` (for some predicate `p` and arity `N`) | `_show_atom(p(X1, ..., XN)) :- p(X1, ..., XN).` |
| `#show T : B` (for some term `T` and body `B`) | `_show_term(T) :- B.` |

!!! info

    We follow the convention of preceding the new predicates with an underscore to avoid conflicts with internal predicates.

!!! tip

    If you want to see this transformation for your input you can use the `transform` command of *metasp*.


When the program is reified we give special treatment to the new auxiliary predicates, generating the following corresponding facts in the reification.


| Input | Reified output |
|---|---|
| `#show.` | `show.` |
| `#show p/N.` (for some predicate `p` and arity `N`) | `show_atom(p(X1, ..., XN), L).` where L is the literal number corresponding to the atom `p(X1, ..., XN)` |
| `#show T : B` (for some term `T` and body `B`) | `show_term(T, L).` where L is the literal number corresponding to the body `B` |

We provide an encoding to use these predicates in the semantics encoding for actually showing the atoms and formulas in the output,
see [`show.lp`](../semantics/encodings/show.md) for more details.

!!! info

    If your system is a temporal extension, you can use the [`show-time.lp`](../semantics/encodings/show-time.md) instead which extends the show encoding with time.
