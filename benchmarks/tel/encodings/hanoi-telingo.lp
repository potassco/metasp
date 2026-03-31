#program initial.
on(N1,N) :- on0(N,N1).

#program always.
:- on(N1,N), N1>=N.

#program dynamic.
{ occurs(some_action) }.
1 { move(N) : _disk(N) } 1 :- occurs(some_action).

1 { where(N) : _disk(N) }1 :- occurs(some_action).

:- move(N), N<5.

:- 'on(N,N1), move(N).

:- 'on(N,N1), where(N).

:- move(N), 'move(N).

on(N1,N) :- move(N), where(N1).
on(N,N1) :- 'on(N,N1), not move(N1).

#program final.
:- not on(N,N1), _ongoal(N1,N).
:- on(N,N1), not _ongoal(N1,N).
