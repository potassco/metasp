
% Instance based on nfloors
floor(1..nfloors).
at((nfloors+1)/2):-&initial.
called(1;nfloors):-&initial.

% Encoding

{wait;up; down;serve} = 1 :- not &final.
:- up, at(X), not floor(X+1). :- down, at(X), not floor(X-1).

% ISSUE: If we dont have the floor(X-1) condition here,
% the external generated is #external at(X-1): down, at(X), which leads to an infinite grounding
&next(at(X+1)):- up, at(X), not &final, floor(X+1).
&next(at(X-1)):- down, at(X), not &final, floor(X-1).
&next(at(X) ):- at(X), not up, not down, not &final.
&next(called(X)):- called(X), not &final, #false:at(X), serve.
:- called(X), &final.
ready :- called(X), at(X).

