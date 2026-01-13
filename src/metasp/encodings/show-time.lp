#show.

% Show all true atom formulas unless #show. in original program
% #show true(F,K) : formula(function,F), true(F,K), not show(_,_), not show_hide.

% Show all true formulas that have a condition
#show true(S,K) : show(S,B), conjunction(B,K).

% Show all true formulas that have no condition
% This line below does not work because it shows every atom even when it is not true
% #show true(S,K) : time(K), show(S,B), literal_tuple(B,L), not atom_tuple(_,L).
