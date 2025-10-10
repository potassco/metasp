%========
% The syntax is restricted to the one of the LPNMR paper
% with only next in the head
%========

%----------
% Domain
%----------
item(icard). item(cash).
loc(dentist). loc(office). loc(atm). loc(home).

#const size = 1.
distance(dentist,home,20*size).
distance(dentist,office,30*size).
distance(dentist,atm,40*size).
distance(home,office,15*size).
distance(home,atm,15*size).
distance(office,atm,20*size).
distance(Y,X,D):-distance(X,Y,D).

%----------
% Program
%----------

% Initial
at(ram,office):-__initial.
at(cash,atm):-__initial.
at(icard,home):-__initial.

% Action
go(ram,L') : loc(L'), L'!=L :- at(ram,L), not __final.

% Fulents
has(ram,I) :- at(ram,L), at(I,L), item(I).
at(ram,L) :- at(ram,L), has(ram,I).

% Effects
__next(__i(D,D+1),at(ram,L')) :- at(ram,L), go(ram,L'), distance(L,L',D).

% Innertia
__next(__i(0,__w),has(ram,I)) :- has(ram,I), not __final.
% __next(__i(0,__w),at(I,L)) :- at(I,L), item(I), not has(_,I), not __final.
__next(at(I,L)) :- at(I,L), item(I), not has(_,I), not __final.

% GOAL
goal :- at(ram,dentist), has(ram,icard), has(ram,cash).

% Represent the goal!
:- not __eventually(__i(0,60*size),goal), __initial.

#external __eventually(__i(0,60*size),goal).
#external __initial.
#external __final.
#external at(ram,L): loc(L).
#external at(I,L): item(I), loc(L).
#external has(ram,I): item(I).

_show(go(P,L)):-go(P,L).
_show.
