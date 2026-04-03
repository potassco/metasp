atrobot(X) :- at(X), &initial.

% #program dynamic.
{ occurs(some_action) } :- not &initial.
atrobot(N) :- connected(C,N), C != N, not atother(N), occurs(some_action), not &initial.
atother(N) :- connected(C,N), C != N, atrobot(O), O != N, occurs(some_action), not &initial.

move(C,N) :- &prev(atrobot(C)), atrobot(N), connected(C,N), C != N, not &initial.
done     :- move(C,N), not &initial.

:- not done, occurs(some_action), not &initial.

visited(X) :- &prev(visited(X)), not &initial.
visited(X) :- atrobot(X), not &initial.

% #program final.
:- visit(X), not visited(X), &final.
