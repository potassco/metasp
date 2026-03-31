% #program initial.
at_t(P,To) :- at(P,To), &initial.
clear_t(P) :- clear(P), &initial.
atgoal(S) :- isgoal(L), stone(S), at(S,L), &initial.

% #program dynamic.
{ occurs(some_action) } :- not &initial.
1 <= {pushtonongoal(P,S,Ppos,From,To,Dir) :
        movedir(Ppos,From,Dir),
	movedir(From,To,Dir),
	isnongoal(To),
	player(P),
	stone(S),
	Ppos != To,
	Ppos != From,
	From != To;

      move(P,From,To,Dir) :
        movedir(From,To,Dir),
	player(P),
	From != To;

      pushtogoal(P,S,Ppos,From,To,Dir) :
        movedir(Ppos,From,Dir),
	movedir(From,To,Dir),
	isgoal(To),
	player(P),
	stone(S),
	Ppos != To,
	Ppos != From,
	From != To;

      noop } <= 1 :-
  occurs(some_action),
  not &initial.

del(at(P,Ppos)) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isnongoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

del(at(S,From)) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isnongoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

del(clear(To)) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isnongoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

at_t(P,From) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isnongoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

at_t(S,To) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isnongoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

clear_t(Ppos) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isnongoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

del(atgoal(S)) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isnongoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

del(at(P,From)) :-
  move(P,From,To,Dir),
  movedir(From,To,Dir),
  player(P),
  From != To,
  not &initial.

del(clear(To)) :-
  move(P,From,To,Dir),
  movedir(From,To,Dir),
  player(P),
  From != To,
  not &initial.

at_t(P,To) :-
  move(P,From,To,Dir),
  movedir(From,To,Dir),
  player(P),
  From != To,
  not &initial.

clear_t(From) :-
  move(P,From,To,Dir),
  movedir(From,To,Dir),
  player(P),
  From != To,
  not &initial.

del(at(P,Ppos)) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isgoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

del(at(S,From)) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isgoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

del(clear(To)) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isgoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

at_t(P,From) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isgoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

at_t(S,To) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isgoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

clear_t(Ppos) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isgoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

atgoal(S) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  stone(S),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isgoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

clear_t(L) :- &prev(clear_t(L)), not del(clear(L)),
  not &initial.
atgoal(S) :-
  &prev(atgoal(S)),
  not del(atgoal(S)),
  stone(S),
  not &initial.

at_t(T,L) :-
  &prev(at_t(T,L)),
  not del(at(T,L)),
  not &initial.

:- pushtonongoal(P,S,Ppos,From,To,Dir),
   not preconditions_png(P,S,Ppos,From,To,Dir),
   movedir(Ppos,From,Dir),
   movedir(From,To,Dir),
   isnongoal(To),
   player(P),
   stone(S),
   Ppos != To,
   Ppos != From,
   From != To,
   not &initial.

preconditions_png(P,S,Ppos,From,To,Dir) :-
  &prev(at_t(P,Ppos)),
  &prev(at_t(S,From)),
  &prev(clear_t(To)),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isnongoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

:- move(P,From,To,Dir),
   not preconditions_m(P,From,To,Dir),
   movedir(From,To,Dir),
   player(P),
   From != To,
   not &initial.

preconditions_m(P,From,To,Dir) :-
  &prev(at_t(P,From)),
  &prev(clear_t(To)),
  movedir(From,To,Dir),
  movedir(From,To,Dir),
  player(P),
  From != To,
  not &initial.

:- pushtogoal(P,S,Ppos,From,To,Dir),
   not preconditions_pg(P,S,Ppos,From,To,Dir),
   movedir(Ppos,From,Dir),
   movedir(From,To,Dir),
   isgoal(To),
   player(P),
   stone(S),
   Ppos != To,
   Ppos != From,
   From != To,
   not &initial.

preconditions_pg(P,S,Ppos,From,To,Dir) :-
  &prev(at_t(P,Ppos)),
  &prev(at_t(S,From)),
  &prev(clear_t(To)),
  movedir(Ppos,From,Dir),
  movedir(From,To,Dir),
  isgoal(To),
  player(P),
  stone(S),
  Ppos != To,
  Ppos != From,
  From != To,
  not &initial.

goalreached :- 	&prev(goalreached), not &initial.
goalreached :- 	atgoal(X): goal(X); not &initial.

% #program final.
:- not goalreached, &final.
