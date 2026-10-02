

% {f}.
% Default negation
% &always(a, &not(f)).
% Strong negation
% &always(a, &sneg(f)).
% -f.

% cross:- -train.

&action(red).
% &always(&atrue, train).
% &always(&atrue, -train).
-&always(&atrue, train).
-a.

% THIS WORKS
% {red}.
% -train:-red.
% train:-red.


% &always(a, -f).
% &always(a, f).
% &always(&seq(&atrue,&atrue), f):-&initial.

% #show &always/2.
% #show f/0.
% #show &initial/0.
