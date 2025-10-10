type(del).
type(path).
subtype(atom, del).
subtype(atom, path).
subtype(tel, del).


constructor(del, (box, 2), body).
    arg((box, 2), 0, type, path).
    arg((box, 2), 1, type, del).
constructor(del, (dia, 2), body).
    arg((dia, 2), 0, type, path).
    arg((dia, 2), 1, type, del).
constructor(del, (top, 0), body).
constructor(del, (bot, 0), body).


constructor(path, (step, 0), none).
constructor(path, (test, 1), none).
    arg((test, 1), 0, type, del).
constructor(path, (choice, 2), none).
    arg((choice, 2), 0, type, path).
    arg((choice, 2), 1, type, path).
constructor(path, (seq, 2), none).
    arg((seq, 2), 0, type, path).
    arg((seq, 2), 1, type, path).
constructor(path, (star, 1), none).
    arg((star, 1), 0, type, path).



% Derived We need this in the grammar to parse the input

%% ------- Derived --------- %%
% derive(box(A,F),box(seq(test(A),step),F),del) :- formula(del,box(A,F)),  formula(atom,A).
% derive(dia(A,F),dia(seq(test(A),step),F),del) :- formula(del,dia(A,F)),  formula(atom,A).

% defined_as((path,_formula(atom,a)), (path, seq(test(_formula(atom,a)), step))).
% var(_a, path).
var(a, atom).
% var(_c, path).
% defined_as(dia(_a,_b), __dia(__seq(__test(_a), __step),_b)).
% defined_as(seq(_c,_a), __seq(_c,__seq(__test(_a), __step))).
defined_as(path, a, __seq(__test(a), __step)).
% defined_as(eventually(_a), __until(__true, _a)).
