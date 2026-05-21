% #program initial.
on(N1,N) :- on0(N,N1), &initial.

% #program always.
:- on(N1,N), N1>=N.

% #program dynamic.
{ occurs(some_action) } :- not &initial.
1 { move(N) : disk(N) } 1 :- occurs(some_action), not &initial.

1 { where(N) : disk(N) }1 :- occurs(some_action), not &initial.

:- move(N), N<5, not &initial.

:- &prev(on(N,N1)), move(N), not &initial.

:- &prev(on(N,N1)), where(N), not &initial.

:- move(N), &prev(move(N)), not &initial.

on(N1,N) :- move(N), where(N1), not &initial.
on(N,N1) :- &prev(on(N,N1)), not move(N1), not &initial.

% #program final.
:- not on(N,N1), ongoal(N1,N), &final.
:- on(N,N1), not ongoal(N1,N), &final.
