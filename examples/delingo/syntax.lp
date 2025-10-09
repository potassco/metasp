type(del).
type(path).
subtype(atom, del).


constructor(del, box, 2, (path,del)).
constructor(del, dia, 2, (path,del)).
constructor(del, top, 0, ()).
constructor(del, bot, 0, ()).


constructor(path, step, 0, ()).
constructor(path, test, 1, (del,)).
constructor(path, choice, 2, (path, path)).
constructor(path, seq, 2, (path, path)).
constructor(path, star, 1, (path,)).

allow(del, body).


% Derived We need this in the grammar to parse the input
subtype(path, atom).

%% ------- Derived --------- %%
derive(box(A,F),box(seq(test(A),step),F),del) :- formula(del,box(A,F)),  formula(atom,A).
derive(dia(A,F),dia(seq(test(A),step),F),del) :- formula(del,dia(A,F)),  formula(atom,A).

% defined_as((path,_formula(atom,a)), (path, seq(test(_formula(atom,a)), step))).
% var(path,_a).
% defined_as(_a, seq(test(_a), step)).
