fuelcost(10,l0,l2).
fuelcost(18,l0,l3).
fuelcost(10,l0,l4).
fuelcost(2,l1,l2).
fuelcost(24,l1,l4).
fuelcost(10,l2,l0).
fuelcost(2,l2,l1).
fuelcost(2,l2,l3).
fuelcost(18,l3,l0).
fuelcost(2,l3,l2).
fuelcost(16,l3,l4).
fuelcost(10,l4,l0).
fuelcost(24,l4,l1).
fuelcost(16,l4,l3).
at(t0,l3).
fuel(t0,42).
at(p0,l0).
at(p1,l4).
at(p2,l4).
at(p3,l4).
at(p4,l2).
goal(p0,l1).
goal(p1,l2).
goal(p2,l3).
goal(p3,l3).
goal(p4,l0).
steps(64).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
