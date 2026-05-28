% Handles show statements

#show.

show(S,B) :- show_term(S,B).
show(S,B) :- show_atom(S,B).

% Show all things if the condition is satisfied
#show S : show(S,B), conjunction(B).
% By default only atoms are shown unless #show. is present or #show p/N. is used for some predicate p/N.
#show S : output(S,B), conjunction(B), formula(atom,S), not show_atom(_,_), not show.
