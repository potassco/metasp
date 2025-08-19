
% Adds a time step argument to the normal meta encoding.

%*
time(T)
.......
Represents the time steps in the temporal logic that are between 0 and `lambda-1`.

Args:
    T (int): Numerical identifier for the time step.
*%

time(0..lambda-1).

%*
conjunction(B, T)
.............
The set of literals in the conjunction identified by `B` holds since all literals are true or false as specified.

Args:
    B (int): Numerical identifier unique within its class.
    T (int): Numerical identifier for the time step where the conjunction holds.
*%

conjunction(B,T) :- literal_tuple(B), time(T),
        hold(L,T) : literal_tuple(B, L), L > 0;
    not hold(L,T) : literal_tuple(B,-L), L > 0.

%*
body(BODY, T)
..................
The body used in a rule as `BODY` is true at step `T`.

Args:
    BODY (atom):

     - `normal(B)`: Normal body with literals (The conjunction of literals is true).
     - `sum(B, G)`: Sum body with literals and a threshold (The sum of weights satisfies the upper lower bound).
    T (int): Numerical identifier for the time step where the body holds.
*%

body(normal(B),T) :- rule(_,normal(B)), conjunction(B,T), time(T).
body(sum(B,G),T)  :- rule(_,sum(B,G)), time(T),
    #sum { W,L :     hold(L,T), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : not hold(L,T), weighted_literal_tuple(B,-L,W), L > 0 } >= G.

%*
hold(A, T)
................
The atom `A` holds at time step `T`.
Args:
    A (int): Numerical identifier of the atom.
    T (int): Numerical identifier for the time step where the atom holds.
*%

  hold(A,T) : atom_tuple(H,A)   :- rule(disjunction(H),B), body(B,T), time(T).
{ hold(A,T) : atom_tuple(H,A) } :- rule(     choice(H),B), body(B,T), time(T).

%*
true(O, T)
............
The output `O` is true at time step `T`. It is equivalent to `hold/2`, but this predicate uses the atom and not the literal number.
Therefor it can be used and derived in the semantics encoding to define truth of formulas that use modalities.

Args:
    O (atom): Value to be output.
    T (int): Numerical identifier for the time step where the output is true.
*%


% True if the literal tuple for the output holds
true(O,T) :- output(O,B), time(T), hold(L,T) : literal_tuple(B,L).
% If a formula its true, its literal holds
hold(L,T) :- output(O,B), time(T), true(O,T),  literal_tuple(B,L).
