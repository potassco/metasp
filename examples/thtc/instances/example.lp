
% ----------------
%# Initial state
% ----------------
% Initial position
&assign(p,0):-&initial.

% Initial speed * 100
&assign(s,8000):-&initial.

% Acceleration changes
&assign(&next(4,acc), 1135):-&initial.
&assign(&next(6,acc), -230):-&initial.

% ----------------
%# Domain values
% ----------------

% Radar limit and position
&assign(rdlimit,9000).
&assign(rdpos,40000).

% ----------------
%# Dynamic rules
% ----------------

&assign(&next(s), &add(s,acc)).
&assign(&next(p), &add(p,s)).

% Either inertia for the s like this
% Or adding an acceleration of 0, one is enough
&assign(&next(s), s):- not &neq(&add(0,&next(s)),s).
% &assign(&next(s), s):- not &neq(&next(s),s).
% &assign(acc, 0):- not neq(acc,0).


% If the car’s speed (s) exceeds the radar’s speed limit (rdlimit)
% at or after passing the radar’s position (rdpos) at any time, a ﬁne is issued.
&next_tel(fine):- &lt(p,rdpos), &leq(rdpos, &add(0,&next(p))), &lt(rdlimit,&add(0,&next(s))),not &final.


% #show &assign/2.
