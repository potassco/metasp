reserved_predicate(output(_show,B)):-
    output(_show,B).

reserved_predicate(output(_show(A),B)):-
    output(_show(A),B).


processed((A,L), @process_output(A)):-output(A,L), not reserved_predicate(output(A, L)).

% Remove the previous output
hide(output(A,L)):-output(A,L).

% Add the processed output
#show output(O, L):processed((A,L),O).
