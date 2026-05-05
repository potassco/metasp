#show.

show(S,B) :- show_term(S,B).
show(S,B) :- show_atom(S,B).

#show S : show(S,B), conjunction(B).
#show S : output(S,B), conjunction(B), formula(atom,S), not show_atom(_,_), not show.
