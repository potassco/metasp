#show .

show(S,B) :- show_term(S,B).
show(S,B) :- show_atom(S,B).

#show true(S,T) : show(S,B), conjunction(B,T).
#show true(S,T) : output(S,B), conjunction(B,T), formula(atom,S), not show_atom(_,_), not show.
