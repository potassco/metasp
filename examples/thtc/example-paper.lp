% Acceleration changes
assign(next(4,acc), 1135):-initial.
assign(next(6,acc), -230):-initial.

% Initial position
assign(p,0):-initial.

% Initial speed
assign(s,8000):-initial.

assign(next(s), sum(s,acc)).
assign(next(p), sum(p,s)).

% Either inertia for the s like this
% Or adding an acceleration of 0, one is enough
assign(next(s), s):- not neq(next(s),s).
% assign(acc, 0):- not neq(acc,0).

% Radar limit and position
assign(rdlimit,9000).
assign(rdpos,40000).

% If the car’s speed (s) exceeds the radar’s speed limit (rdlimit)
% at or after passing the radar’s position (rdpos) at any time, a ﬁne is issued.
next(fine):- lt(p,rdpos), leq(rdpos, next(p)), lt(rdlimit,next(s)),not final.

#external initial.
#external final.
#external not_yet.
#external neq(next(s),s).
#external neq(acc,0).
#external lt(p,rdpos).
#external leq(rdpos, next(p)).
#external lt(rdlimit,next(s)).
