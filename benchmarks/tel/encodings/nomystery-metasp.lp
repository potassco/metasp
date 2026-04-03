% #program initial
at_t(O,L) :- at(O,L), &initial.
fuel_t(T,F) :- fuel(T,F), &initial.

% #program dynamic.
1 { occurs(A) : action(A) } 1 :- not &initial.

unload(P,T,L) :- occurs(unload(P,T,L)), not &initial.
load(P,T,L) :- occurs(load(P,T,L)), not &initial.
drive(T,L1,L2) :- occurs(drive(T,L1,L2)), not &initial.

at_t(P,L) :- unload(P,T,L), not &initial.
del(in(P,T)) :- unload(P,T,L), not &initial.

del(at_t(P,L)) :- load(P,T,L), not &initial.
in(P,T) :- load(P,T,L), not &initial.

del(at_t(T,L1)) :- drive(T,L1,L2), not &initial.
at_t(T,L2) :- drive(T,L1,L2), not &initial.
del(fuel_t(T,Fuelpre)) :- drive(T,L1,L2), &prev(fuel_t(T,Fuelpre)), not &initial.
fuel_t(T,Fuelpre - Fueldelta) :- drive(T,L1,L2), fuelcost(Fueldelta,L1,L2), &prev(fuel_t(T,Fuelpre)), Fuelpre >= Fueldelta, not &initial.

at_t(O,L) :- &prev(at_t(O,L)), not del(at_t(O,L)), not &initial.
in(P,T) :- &prev(in(P,T)), not del(in(P,T)), not &initial.
fuel_t(T,Level) :- &prev(fuel_t(T,Level)), not del(fuel_t(T,Level)), truck(T), not &initial.

:- unload(P,T,L), not preconditions_u(P,T,L), not &initial.
preconditions_u(P,T,L) :- &prev(at_t(T,L)), &prev(in(P,T)), package(P), truck(T), not &initial.

:- load(P,T,L), not preconditions_l(P,T,L), not &initial.
preconditions_l(P,T,L) :- &prev(at_t(T,L)), &prev(at_t(P,L)), not &initial.

:- drive(T,L1,L2), not preconditions_d(T,L1,L2), not &initial.
preconditions_d(T,L1,L2) :- &prev(at_t(T,L1)), &prev(fuel_t(T,Fuelpre)), fuelcost(Fueldelta,L1,L2), Fuelpre >= Fueldelta, not &initial.

% #program final.
:- goal(P,L), not at_t(P,L), &final.
