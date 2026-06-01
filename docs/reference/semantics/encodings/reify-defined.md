
# `reify-defined.lp`

Adds defined directives for the reification predicates to avoid warnings when using clingo.
Check the [How to build your own ASP system?!](https://arxiv.org/abs/2008.06692) paper for more details on the reification predicates and their semantics.

::: src/metasp/encodings/reify-defined.lp
    handler: asp
    options:
        glossary:
            include_references: false
        predicate_table: true
        encodings: false
        start_level: 1

## Examples

!!! example "Example"

    For the following program

    `f.lp`
    ```clingo
    {a;b}.
    c :- a, not b.
    :- b.
    ```

    The reified output will be:

    `gringo f.lp --output=reify`
    ```clingo
    atom_tuple(0).                  % at0 := {a,b}
    atom_tuple(0,1).                % (a1 := a) in at0
    atom_tuple(0,2).                % (a2 := b) in at0
    literal_tuple(0).               % lt0 := {} (Literal tuple of arity 0)
    rule(choice(0),normal(0)).      % choice(at0) :- and(lt0)   <->   {a;b} :- #true.

    atom_tuple(1).                  % at1 := {} (Atom tuple of arity 0)
    literal_tuple(1).               % lt1 := {b}
    literal_tuple(1,2).             % (a2 := b) in lt1
    rule(disjunction(1),normal(1)). % disjunction(at1) :- and(lt1)   <->  #false :- b.

    atom_tuple(2).                  % at2 := {c}
    atom_tuple(2,3).                % a3 := c in at2
    literal_tuple(2).               % lt2 := {a, not b}
    literal_tuple(2,-2).            % (a-2 := not b) in lt2
    literal_tuple(2,1).             % (a1 := a) in lt2
    rule(disjunction(2),normal(2)). % disjunction(at2) :- and(lt2)   <->  c :- a, not b.

    literal_tuple(3).               % lt3 := {a}
    literal_tuple(3,1).             % (a1 := a) in lt3
    output(a,3).                    % Show a if lt3

    output(b,1).                    % Show b if lt1

    literal_tuple(4).               % lt4 := {b}
    literal_tuple(4,3).             % (a3 := c) in lt3
    output(c,4).                    % Show c if lt4
    ```
