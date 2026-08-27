#show .

show(S,B) :- show_term(S,B).
show(S,B) :- show_atom(S,B).

% Show all things if the condition is satisfied
% #show ht_true(S,M,T) : show(S,B), conjunction(B,M,T).
% By default only atoms are shown unless #show. is present or #show p/N. is used for some predicate p/N.
% #show ht_true(S,M,T) : output(S,B), conjunction(B,M,T), formula(atom,S), not show_atom(_,_), not show.


% Show all things if the condition is satisfied
#show true(S,T) : show(S,B), conjunction(B,h,T), conjunction(B,t,T).
% By default only atoms are shown unless #show. is present or #show p/N. is used for some predicate p/N.
#show true(S,T) : output(S,B), conjunction(B,h,T), conjunction(B,t,T), formula(atom,S), not show_atom(_,_), not show.
