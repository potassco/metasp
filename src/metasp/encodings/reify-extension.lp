reserved_predicate(_show):-
    output(_show,B).

reserved_predicate(_show(A)):-
    output(_show(A),B).


match(output(O,L), @match_output(O)):- output(O,L), not reserved_predicate(O).

% Remove the previous output
hide(output(O,L)):-output(O,L).

% Add the match output
#show output(F, L):match(output(O,L),F).
#show sugar(F, O):match(output(O,L),F).
