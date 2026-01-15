#show.

% Show all true atom formulas unless #show. in original program
#show true(F,K) : formula(atom,F), true(F,K), not show.

% Show all true formulas that have a condition
#show true(S,K) : show(S,B), conjunction(B,K).

