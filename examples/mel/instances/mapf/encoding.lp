% guess moves
move(A,U,V) , not move(A,U,V) :- agent(A), edge(U,V,D), not &final. % changed move to 0..horizon-1
:- move(A,U,V), move(A,U',V'), (U,V) != (U',V').

% infer agent positions
at(A,U) :- start(A,U), &initial.
&eventually(&i(D,D+1), at(A,V)) :- move(A,U,V), edge(U,V,D). % this requires move at 0..horizon-1
&next(&i(0,#sup),at(A,U)) :- not &final, at(A,U), not move(A,U,V) : edge(U,V,_).

% ensure path-like strolls
:- move(A,U,V), not at(A,U).
:- goal(A,U), not at(A,U), &final.

% handle vertex/swap/follow conflicts
:- at(A,U), at(A',U), A > A'.
:- move(A,U,V), &eventually(&i(0,D), move(B,V,U)), edge(U,V,D), agent(B), agent(A).

#show move/3.
