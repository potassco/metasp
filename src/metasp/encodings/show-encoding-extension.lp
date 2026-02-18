% New predicates
show_atom(X,B):-
    rule(disjunction(H),normal(B)),
    atom_tuple(H,L),
    symbol_literal(_show_atom(X),L).

show_term(X,B):-
    rule(disjunction(H),normal(B)),
    atom_tuple(H,L),
    symbol_literal(_show_term(X),L).

show :- output(_show, _).

#show show_atom/2.
#show show_term/2.
#show show/0.


% Symbol table linking to literals
symbol_literal(S,L):- output(S,B), literal_tuple(B,L).
#show symbol_literal(S,L):symbol_literal(S,L), not reserved(_,S).


reserved(show,_show_atom(X)):- output(_show_atom(X), _).
reserved(show,_show_term(X)):- output(_show_term(X), _).
reserved(show,_show):- output(_show, _).



% Hiden predicates
% Hide rule but not the literal tuple
hide(rule(disjunction(H),normal(B))):-
    rule(disjunction(H),normal(B)),
    atom_tuple(H,L),
    symbol_literal(S,L),
    reserved(show,S).

hide(atom(L)):-
    rule(disjunction(H),normal(B)),
    atom_tuple(H,L),
    symbol_literal(S,L),
    reserved(show,S).

hide(atom_tuple(H)):-
    rule(disjunction(H),normal(B)),
    atom_tuple(H,L),
    symbol_literal(S,L),
    reserved(show,S).

hide(literal_tuple(B)):-
    literal_tuple(B,L),
    symbol_literal(S,L),
    reserved(show,S).

hide(output(S,B)):-
    output(S,B),
    reserved(show,S).
