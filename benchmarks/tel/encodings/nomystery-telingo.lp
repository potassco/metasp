#program initial.
at_t(O,L) :- at(O,L).
fuel_t(T,F) :- fuel(T,F).

#program dynamic.
1 { occurs(A) : _action(A) } 1.

unload(P,T,L) :- occurs(unload(P,T,L)).
load(P,T,L) :- occurs(load(P,T,L)).
drive(T,L1,L2) :- occurs(drive(T,L1,L2)).

at_t(P,L) :- unload(P,T,L).
del(in(P,T)) :- unload(P,T,L).

del(at_t(P,L)) :- load(P,T,L).
in(P,T) :- load(P,T,L).

del(at_t(T,L1)) :- drive(T,L1,L2).
at_t(T,L2) :- drive(T,L1,L2).
del(fuel_t(T,Fuelpre)) :- drive(T,L1,L2), 'fuel_t(T,Fuelpre).
fuel_t(T,Fuelpre - Fueldelta) :- drive(T,L1,L2), _fuelcost(Fueldelta,L1,L2), 'fuel_t(T,Fuelpre), Fuelpre >= Fueldelta.

at_t(O,L) :- 'at_t(O,L), not del(at_t(O,L)).
in(P,T) :- 'in(P,T), not del(in(P,T)).
fuel_t(T,Level) :- 'fuel_t(T,Level), not del(fuel_t(T,Level)), _truck(T).

 :- unload(P,T,L), not preconditions_u(P,T,L).
preconditions_u(P,T,L) :- 'at_t(T,L), 'in(P,T), _package(P), _truck(T).

 :- load(P,T,L), not preconditions_l(P,T,L).
preconditions_l(P,T,L) :- 'at_t(T,L), 'at_t(P,L).

 :- drive(T,L1,L2), not preconditions_d(T,L1,L2).
preconditions_d(T,L1,L2) :- 'at_t(T,L1), 'fuel_t(T,Fuelpre), _fuelcost(Fueldelta,L1,L2), Fuelpre >= Fueldelta.

#program final.
:- _goal(P,L), not at_t(P,L).
