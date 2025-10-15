% What about conditionals?
% % :- a: &eventually(a) Can we do this? is it then body or head?
% HEAD_ATOM :: DEL
% BODY_ATOM :: DEL

% DEL:: ATOM | box PATH DEL | dia PATH DEL | top | bot
% PATH:: step | test DEL | choice PATH PATH | seq PATH PATH | star PATH

% a:= ATOM
% a:PATH = &seq(&test (a), &step)

% % boxAtom :: String -> Formula -> Formula
% % Not good because it would not replace in [a;b]f, since it does not match
% a:= ATOM
% f:= DEL
% &box a f = &box (&seq(&test (a), &step)) f


if head(f) then check what can be a head head_types.

    match_f = match(f, as=[head_types]) This would mean looking for constructors only in the possible types
                if not match_f then
                    match with syntactic sugar
                    syntactic_sugar = match (f, as=[head_types])
                    % Might have multiple matches then it will use the first...
    if not match_f error



type(del).
type(path).
subtype(atom, del).
subtype(atom, path).
% subtype(tel, del).

constructor(del, (box, 2), any).
    arg((box, 2), 0, type, path).
    arg((box, 2), 1, type, del).
constructor(del, (dia, 2), any).
    arg((dia, 2), 0, type, path).
    arg((dia, 2), 1, type, del).
constructor(del, (top, 0), any).
constructor(del, (bot, 0), any).

allow(del, any).


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

% defined_as((path,_formula(atom,a)), (path, seq(test(_formula(atom,a)), step))).
% var(_a, path).
var(a, atom).
% var(_c, path).
% defined_as(dia(_a,_b), __dia(__seq(__test(_a), __step),_b)).
% defined_as(seq(_c,_a), __seq(_c,__seq(__test(_a), __step))).
defined_as(path, a, __seq(__test(a), __step)).
% defined_as(eventually(_a), __until(__true, _a)).

