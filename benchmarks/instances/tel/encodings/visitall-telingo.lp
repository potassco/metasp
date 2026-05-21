#program initial.
atrobot(X) :- at(X).

#program dynamic.
{ occurs(some_action) }.
atrobot(N) :- _connected(C,N), C != N, not atother(N), occurs(some_action).
atother(N) :- _connected(C,N), C != N, atrobot(O), O != N, occurs(some_action).

move(C,N) :- 'atrobot(C), atrobot(N), _connected(C,N), C != N.
done     :- move(C,N).

:- not done, occurs(some_action).

visited(X) :- 'visited(X).
visited(X) :- atrobot(X).

#program final.
:- _visit(X), not visited(X).
