#const n=4.

disk(1..n).
peg(a;b;c).
init_on(1..n,a).
goal_on(1..n,c).

on(D,P) :- init_on(D,P), initial.


% Move a disk to some peg
1 {move(D,P) : disk(D), peg(P)} 1 :- not final.

% Effects of moves
next(on(D,P)) :- move(D,P).
next(on(D,P)) :- on(D,P), not move(D, _), not final.

% Check moves
:- move(D,P), on(D',P), D'<D.
:- move(D,P_TO), on(D,P_FROM), on(D',P_FROM), D'<D.

:- goal_on(D,P), not on(D,P), final.

_show(move(D,P)):-move(D,P).
_show(on(D,P)):-on(D,P).
_show.

#external initial.
#external final.
#external on(D,P):move(D,P).
