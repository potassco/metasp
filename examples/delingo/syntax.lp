modality(del, atom).
modality(del, box, 2, (path,del)).
modality(del, dia, 2, (path,del)).
modality(del, top, 0, ()).
modality(del, bot, 0, ()).


modality(path, step, 0, ()).
modality(path, test, 1, (del,)).
modality(path, choice, 2, (path, path)).
modality(path, seq, 2, (path, path)).
modality(path, star, 1, (path,)).
modality(path, converse, 1, (path,)).

modality(del, final, 0, ()). %Derived
modality(path, atom, 0, ()). %Derived to avoid the a?;t


occurence(del, body).




% Input

dia(star(a),b).

% ----> after first thing we get

subformula(del, dia(star(a),b)).
subformula(path, star(a)).
subformula(path, a).
subformula(atom, a).
subformula(del, a).
subformula(del, b).
subformula(path, b).

% Not yet but we will need it.
subformula(path, test(a)).

% ->>>> we apply rule
% Already an issue if we don't have the context since would also be replaced by b?;step, but maybe not bacause it is not a path
define((path, X), (path, seq(test(X),step))):- subformula(path, X), subformula(atom,X).

define((del, dia(seq(R1,R2))), (del, dia(R1,dia(R2,X)))):- subformula(del, dia(seq(R1,R2),X)).
define((del, box(seq(R1,R2))), (del, box(R1,box(R2,X)))):- subformula(del, box(seq(R1,R2),X)).

define((path, a), (path, seq(test(a),step))).
define((path, b), (path, seq(test(b),step))).

% ->>>With define as a directive we can do  the replacement


subformula(del, dia(star(seq(test(a),step)),b)).
subformula(path, star(seq(test(a),step))).
subformula(path, seq(test(a),step)).
subformula(atom, a). % Not here since it does not match the type
subformula(del, a). % Not here since it does not match the type
subformula(del, b). % Not here since it does not match the type
subformula(path, seq(test(b),step)). %SIt is unnecesary but it is there

% Keeps only the things without syntactic sugar, no need for intermediate formulas


% the issue is that when we do the FLC we get one repetition unfolded
subformula(del, dia(P,dia(star(P),F))):-subformula(del, dia(star(P),F)). %<----- We need this rule before we apply the derive

% But we also need to now apply the define to this new formula. but we didn't know this formula before so now we have:
subformula(del, dia(seq(test(a),step),dia(star(seq(test(a),step)),b))).
% but we want to have so where do we apply things? We would need to have the definition of subformulas together with the syntax, which is not ideal
subformula(del, dia(test(a), dia(step,dia(star(seq(test(a),step)),seq(test(b),step))))).


% -------- If we had it before, we wouldn't know we needed to  apply that rule yet

subformula(del, dia(star(a),b)).
subformula(path, star(a)).
subformula(path, a).
subformula(atom, a).
subformula(del, a).
subformula(del, b).
subformula(path, b).

% becomes also
subformula(del, dia(a, dia(star(a),b))).
% since a is still a path expression we would get the replacement.
% Still we need to have in the same solve all the derive and generation of subformulas so that one derive can trigger another one.
% If the definiton of subformula is more evolved, perhaps we could do it all in one encoding, where the show statements ignore any defined formula
% It should also replace those formulas where they appear in the reification. Which would be in the output predicate.

% If we have no show statements, could we maybe use something other than output and have mapping(FORMULA, LITERAL)??
% Then that is what we would use in the meta encoding and what we would replace when we want to hide all defined operators and remove syntactic sugar





%
% Can the right side of the define also be a derived type?

define((path, X), (path, seq(test(X),step))):- subformula(path, X), subformula(atom,X).


% Same issues as AMADE in renopro we need a linearized way to replace things.
% What if we pass the grounded things by renopro? and use it to replace the things in define?

% Initially:
subformula(del, dia(a,b)).
% After transformation:
subformula(del, dia(seq(test(a),step),b)).
% But we also need to add the new subformulas and apply the define again.



arg(del, dia, 0, a).
arg(del, dia, 1, b).




subformula(path, a).


% type(del).
% type(path).
% subtype(atom, del).

% constructor(del, box, 2, (path,del)).
% constructor(del, dia, 2, (path,del)).
% constructor(del, top, 0, ()).
% constructor(del, bot, 0, ()).

% constructor(path, step, 0, ()).
% constructor(path, test, 1, (del,)).
% constructor(path, choice, 2, (path, path)).
% constructor(path, seq, 2, (path, path)).
% constructor(path, star, 1, (path,)).
% constructor(path, converse, 1, (path,)).

% % Defined operators
defined(del, final, 0, ()).
subtype(path, atom). %can't really replace subtype by defined....

