%*
conjunction(B)
.............
The set of literals in the conjunction identified by `B` holds since all literals are true or false as specified.

Args:
    B (int): Numerical identifier unique within its class.
*%
conjunction(B) :- literal_tuple(B),
      hold(L): literal_tuple(B, L), L>0;
  not hold(L): literal_tuple(B,-L), L>0.

%*
body(BODY)
..................
The body used in a rule as `BODY` is true.

Args:
    BODY (atom):

     - `normal(B)`: Normal body with literals (The conjunction of literals is true).
     - `sum(B, G)`: Sum body with literals and a threshold (The sum of weights satisfies the upper lower bound).
*%

body(normal(B)) :- rule(_,normal(B)), conjunction(B).
body(sum(B,G))  :- rule(_,sum(B,G)),
  #sum {
    W,L:     hold(L), weighted_literal_tuple(B, L,W), L>0;
    W,L: not hold(L), weighted_literal_tuple(B,-L,W), L>0
  } >= G.

%*
hold(A)
................
The atom `A` holds.
Args:
    A (int): Numerical identifier of the atom.
*%

  hold(A): atom_tuple(H,A)   :- rule(disjunction(H),B), body(B).
{ hold(A): atom_tuple(H,A) } :- rule(     choice(H),B), body(B).


%*
true(O)
............
The output `O` is true. It is equivalent to `hold/1`, but this predicate uses the atom and not the literal number.
Therefor it can be used and derived in the semantics encoding to define truth of formulas that use types in the grammar.

Args:
    O (atom): Value to be output.
*%


% True if the literal tuple for the output holds
true(O) :- output(O,B), hold(L) : literal_tuple(B,L).
% If a formula its true, its literal holds
hold(L) :- output(O,B), true(O),  literal_tuple(B,L).
