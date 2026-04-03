#program initial.
at_t(P,To) :- at(P,To).
clear_t(P) :- clear(P).
atgoal(S) :- isgoal(L), stone(S), at(S,L).

#program dynamic.
{ occurs(some_action) }.
1 <= {pushtonongoal(P,S,Ppos,From,To,Dir) :
        _movedir(Ppos,From,Dir),
	_movedir(From,To,Dir),
	_isnongoal(To),
	_player(P),
	_stone(S),
	Ppos != To,
	Ppos != From,
	From != To;

      move(P,From,To,Dir) :
	_movedir(From,To,Dir),
	_player(P),
	From != To;

      pushtogoal(P,S,Ppos,From,To,Dir) :
	_movedir(Ppos,From,Dir),
	_movedir(From,To,Dir),
	_isgoal(To),
	_player(P),
	_stone(S),
	Ppos != To,
	Ppos != From,
	From != To;

      noop} <= 1 :-
  occurs(some_action).

del(at(P,Ppos)) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isnongoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

del(at(S,From)) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isnongoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

del(clear(To)) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isnongoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

at_t(P,From) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isnongoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

at_t(S,To) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isnongoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

clear_t(Ppos) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isnongoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

del(atgoal(S)) :-
  pushtonongoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isnongoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

del(at(P,From)) :-
  move(P,From,To,Dir),
  _movedir(From,To,Dir),
  _player(P),
  From != To.

del(clear(To)) :-
  move(P,From,To,Dir),
  _movedir(From,To,Dir),
  _player(P),
  From != To.

at_t(P,To) :-
  move(P,From,To,Dir),
  _movedir(From,To,Dir),
  _player(P),
  From != To.

clear_t(From) :- move(P,From,To,Dir),
_movedir(From,To,Dir),
_player(P),
From != To.

del(at(P,Ppos)) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isgoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

del(at(S,From)) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isgoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

del(clear(To)) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isgoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

at_t(P,From) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isgoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

at_t(S,To) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isgoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

clear_t(Ppos) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isgoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

atgoal(S) :-
  pushtogoal(P,S,Ppos,From,To,Dir),
  _stone(S),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isgoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

clear_t(L) :- 'clear_t(L), not del(clear(L)).

atgoal(S) :- 'atgoal(S), not del(atgoal(S)), _stone(S).

at_t(T,L) :- 'at_t(T,L), not del(at(T,L)).

:- pushtonongoal(P,S,Ppos,From,To,Dir),
   not preconditions_png(P,S,Ppos,From,To,Dir),
   _movedir(Ppos,From,Dir),
   _movedir(From,To,Dir),
   _isnongoal(To),
   _player(P),
   _stone(S),
   Ppos != To,
   Ppos != From,
   From != To.

preconditions_png(P,S,Ppos,From,To,Dir) :-
  'at_t(P,Ppos),
  'at_t(S,From),
  'clear_t(To),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isnongoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

:- move(P,From,To,Dir),
   not preconditions_m(P,From,To,Dir),
   _movedir(From,To,Dir),
   _player(P),
   From != To.

preconditions_m(P,From,To,Dir) :-
  'at_t(P,From),
  'clear_t(To),
  _movedir(From,To,Dir),
  _movedir(From,To,Dir),
  _player(P),
  From != To.

:- pushtogoal(P,S,Ppos,From,To,Dir),
   not preconditions_pg(P,S,Ppos,From,To,Dir),
   _movedir(Ppos,From,Dir),
   _movedir(From,To,Dir),
   _isgoal(To),
   _player(P),
   _stone(S),
   Ppos != To,
   Ppos != From,
   From != To.

preconditions_pg(P,S,Ppos,From,To,Dir) :-
  'at_t(P,Ppos),
  'at_t(S,From),
  'clear_t(To),
  _movedir(Ppos,From,Dir),
  _movedir(From,To,Dir),
  _isgoal(To),
  _player(P),
  _stone(S),
  Ppos != To,
  Ppos != From,
  From != To.

goalreached :- 	'goalreached.
goalreached :- 	atgoal(X): _goal(X).

#program final.
:- not goalreached.
