
# Reification predicates

Adds defined directives for the reification predicates to avoid warnings when using clingo.

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


!!! example "Example Theory"

    Cosidering the following theory definition

    `grammar.lp`
    ```clingo
    #theory theory{
        term {
        >   : 2, unary;
        >?  : 1, binary, left
        };
        &tel/0     : term, any;
        &tel_eq/0     : term, {=}, term, any
    }.
    ```

    and the following program

    `f.lp`
    ```clingo
    &tel{ > f(a,1) }.
    ```

    The reified output will be:

    `gringo f.lp grammar.lp --output=reify`
    ```clingo
    theory_string(3,"a").             % s3 := "a"
    theory_number(4,1).               % s4 := 1
    theory_string(2,"f").             % s2 := "f"
    theory_tuple(0).                  % tt0 := (a,1)
    theory_tuple(0,0,3).              % s3 in tt0 at 0
    theory_tuple(0,1,4).              % s4 in tt0 at 1
    theory_function(5,2,0).           % s5 := f(a,1)

    theory_string(1,">").             % s1 := ">"
    theory_tuple(1).                  % tt1 := (f(a,1))
    theory_tuple(1,0,5).              % s5 in tt1 at 0
    theory_function(6,1,1).           % s6 := >(f(a,1))

    theory_tuple(2).                  % tt2 = ( >(f(a,1)) )
    theory_tuple(2,0,6).              % s6 in tt12 at 0
    literal_tuple(0).                 % lt := {} (No condition)
    theory_element(0,2,0).            % te0 := ( >(f(a,1)) )
    theory_element_tuple(0).          % tet0 := { ( >(f(a,1)) ) }
    theory_element_tuple(0,0).        % te0 in tet0
    theory_string(0,"tel").           % s0 := "tel"
    theory_atom(1,0,0).               % a1 := &tel{ ( >(f(a,1)) ) }

    atom_tuple(0).                    % at0 := { &tel{ ( >(f(a,1)) ) } }
    atom_tuple(0,1).                  % a1 in at0
    literal_tuple(0).                 % lt0 := {}
    rule(disjunction(0),normal(0)).   % or(at0) :- and(lt0)   <->   &tel{ ( >(f(a,1)) ) } :- #true.
    ```
