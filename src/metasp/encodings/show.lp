#show.

% Show all true formulas unless #show. in original program
#show F : formula(atom,F), true(F), not output(_show,_).

% Show all true formulas that have a condition
#show S : output(_show(S),B), conjunction(B).

% Show all true formulas that have no condition
#show S : output(_show(S),B), literal_tuple(B,L), not atom_tuple(_,L).


% % #show.

% % Show all true formulas unless #show. in original program
% show :- not output(_show,_).

% % Show all true formulas that have a condition
% show(S,B) :- output(_show(S),B).

% % Show all true formulas that have no condition
% show(S,B) :- output(_show(S),B).



