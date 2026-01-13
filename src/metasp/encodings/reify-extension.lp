reserved_predicate(output(_show,B)):-
    output(_show,B).

reserved_predicate(output(_show(A),B)):-
    output(_show(A),B).

:- symbol_literal(F,L), formula(T,F), literal_tuple(_,L), not allow(T, body).
:- symbol_literal(F,L), formula(T,F), literal_tuple(_,-L), not allow(T, body).
:- symbol_literal(F,L), formula(T,F), atom_tuple(_,L), not allow(T, head).

processed((O,L), @process_output(O)):-output(O,L), not reserved_predicate(output(O, L)).

% Remove the previous output
hide(output(O,L)):-output(O,L).

% Add the processed output
#show output(F, L):processed((O,L),F).
#show sugar(F, O):processed((O,L),F).
