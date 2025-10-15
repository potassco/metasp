% Acceleration changes
__assign(__next(4,acc), 1135):-__initial.
__assign(__next(6,acc), -230):-__initial.

% Initial position
__assign(p,0):-__initial.

% Initial speed
__assign(s,8000):-__initial.

__assign(__next(s), __sum(s,acc)).
__assign(__next(p), __sum(p,s)).

% Either inertia for the s like this
% Or adding an acceleration of 0, one is enough
__assign(__next(s), s):- not __neq(__next(s),s).
% __assign(acc, 0):- not neq(acc,0).

% Radar limit and position
__assign(rdlimit,9000).
__assign(rdpos,40000).

% If the car’s speed (s) exceeds the radar’s speed limit (rdlimit)
% at or after passing the radar’s position (rdpos) at any time, a ﬁne is issued.
__next(fine):- __lt(p,rdpos), __leq(rdpos, __next(p)), __lt(rdlimit,__next(s)),not __final.

#external __initial.
#external __final.
#external not_yet.
#external __neq(__next(s),s).
#external __neq(acc,0).
#external __lt(p,rdpos).
#external __leq(rdpos, __next(p)).
#external __lt(rdlimit,__next(s)).
