% Handles show statements with time steps

% Hides all to only consider the things that should be shown
#show .

show(S,B) :- show_term(S,B).
show(S,B) :- show_atom(S,B).

% Show all things if the condition is satisfied
#show true(S,T) : show(S,B), conjunction(B,T).
% By default only atoms are shown unless #show. is present or #show p/N. is used for some predicate p/N.
#show true(S,T) : output(S,B), conjunction(B,T), formula(atom,S), not show_atom(_,_), not show.
