% #program initial
pos_r(R,1,I) :- pos(R,I,_), &initial.
pos_r(R,-1,J) :- pos(R,_,J), &initial.

% #program dynamic.
{ occurs(some_action) } :- &initial.
1 <= { selectRobot(R) : robot(R) } <= 1 :- occurs(some_action), not &initial.
1 <= { selectDir(D,O) : dir(D,O) } <= 1 :- occurs(some_action), not &initial.

go(R,D,O) :- selectRobot(R), selectDir(D,O), not &initial.
go_foo(R,O) :- go(R,_,O), not &initial.
go(R,D) :- go(R,D,_), not &initial.

sameLine(R,D,O,RR)  :- go(R,D,O), &prev(pos_r(R,-O,L)), &prev(pos_r(RR,-O,L)), R != RR, not &initial.
blocked(R,D,O,I+DI) :- go(R,D,O), &prev(pos_r(R,-O,L)), not conn(D,L,I), dl(D,DI), dim(I), dim(I+DI), not &initial.
blocked(R,D,O,L)    :- sameLine(R,D,O,RR), &prev(pos_r(RR,O,L)), not &initial.

reachable(R,D,O,I) :- go(R,D,O), &prev(pos_r(R,O,I)), not &initial.
reachable(R,D,O,I+DI) :- reachable(R,D,O,I), not blocked(R,D,O,I+DI), dl(D,DI), dim(I+DI), not &initial.

:- go(R,D,O), &prev(pos_r(R,O,I)), blocked(R,D,O,I+DI), dl(D,DI), not &initial.
:- go(R,D,O), &prev(go(R,DD,O)), not &initial.

pos_r(R,O,I) :- reachable(R,D,O,I), not reachable(R,D,O,I+DI), dl(D,DI), not &initial.
pos_r(R,O,I) :- &prev(pos_r(R,O,I)), not go_foo(R,O), not &initial.

% #program final.
:- target(R,I,_), not pos_r(R,1,I), &final.
:- target(R,_,J), not pos_r(R,-1,J), &final.
