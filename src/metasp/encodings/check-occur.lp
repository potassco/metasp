% Ideally this should print some error and not just be unsat
:- symbol_literal(F,L), formula(T,F), literal_tuple(_,L), not allow(T, body).
:- symbol_literal(F,L), formula(T,F), literal_tuple(_,-L), not allow(T, body).
:- symbol_literal(F,L), formula(T,F), atom_tuple(_,L), not allow(T, head).
