#program initial.
pos_r(R,1,I) :- pos(R,I,_).
pos_r(R,-1,J) :- pos(R,_,J).

#program dynamic.
{ occurs(some_action) }.
1 <= { selectRobot(R) : _robot(R) } <= 1 :- occurs(some_action).
1 <= { selectDir(D,O) : _dir(D,O) } <= 1 :- occurs(some_action).

go(R,D,O) :- selectRobot(R), selectDir(D,O).
go_foo(R,O) :- go(R,_,O).
go(R,D) :- go(R,D,_).

sameLine(R,D,O,RR)  :- go(R,D,O), 'pos_r(R,-O,L), 'pos_r(RR,-O,L), R != RR.
blocked(R,D,O,I+DI) :- go(R,D,O), 'pos_r(R,-O,L), not _conn(D,L,I), _dl(D,DI), _dim(I), _dim(I+DI).
blocked(R,D,O,L)    :- sameLine(R,D,O,RR), 'pos_r(RR,O,L).

reachable(R,D,O,I) :- go(R,D,O), 'pos_r(R,O,I).
reachable(R,D,O,I+DI) :- reachable(R,D,O,I), not blocked(R,D,O,I+DI), _dl(D,DI), _dim(I+DI).

:- go(R,D,O), 'pos_r(R,O,I), blocked(R,D,O,I+DI), _dl(D,DI).
:- go(R,D,O), 'go(R,DD,O).

pos_r(R,O,I) :- reachable(R,D,O,I), not reachable(R,D,O,I+DI), _dl(D,DI).
pos_r(R,O,I) :- 'pos_r(R,O,I), not go_foo(R,O).

#program final.
:- _target(R,I,_), not pos_r(R,1,I).
:- _target(R,_,J), not pos_r(R,-1,J).
