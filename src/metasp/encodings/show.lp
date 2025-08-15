#show.

% Show all true formulas unless #show. in original program
#show (F,K) : formula(atom,F), true(F,K), not output(_show,_).

% Show all true formulas that have a condition
#show (S,K) : output(_show(S),B), conjunction(B,K).

% Show all true formulas that have no condition
#show (S,K) : time(K), output(_show(S),B), literal_tuple(B,L), not atom_tuple(_,L).
