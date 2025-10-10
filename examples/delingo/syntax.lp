type(del).
type(path).
subtype(atom, del).
subtype(atom, path).
subtype(tel, del).


constructor(del, (box, 2), body).
constructor(del, (dia, 2), body).

    arg((dia, 2), 0, type, path).
    arg((dia, 2), 1, type, del).

constructor(del, (top, 0), body).
constructor(del, (bot, 0), body).


constructor(path, (step, 0), none).
constructor(path, (test, 1), none).
constructor(path, (choice, 2), none).
constructor(path, (seq, 2), none).
constructor(path, (star, 1), none).



% Derived We need this in the grammar to parse the input

%% ------- Derived --------- %%
% derive(box(A,F),box(seq(test(A),step),F),del) :- formula(del,box(A,F)),  formula(atom,A).
% derive(dia(A,F),dia(seq(test(A),step),F),del) :- formula(del,dia(A,F)),  formula(atom,A).

% defined_as((path,_formula(atom,a)), (path, seq(test(_formula(atom,a)), step))).
% var(path,_a).
% defined_as(_a, seq(test(_a), step)).
