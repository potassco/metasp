
% Should only activate when we have show_hide
#show.

% Show all true formulas unless #show. in original program
#show F : formula(atom,F), true(F), not show_hide.

#show S : show(S,B), conjunction(B).

% #show S : show(S,B), literal_tuple(B,L), not atom_tuple(_,L).




