fuelcost(4,l0,l1).
fuelcost(16,l0,l2).
fuelcost(20,l0,l3).
fuelcost(4,l1,l0).
fuelcost(9,l1,l2).
fuelcost(14,l1,l3).
fuelcost(16,l2,l0).
fuelcost(9,l2,l1).
fuelcost(21,l2,l3).
fuelcost(20,l3,l0).
fuelcost(14,l3,l1).
fuelcost(21,l3,l2).
at(t0,l2).
fuel(t0,52).
at(p0,l2).
at(p1,l1).
at(p2,l3).
at(p3,l2).
goal(p0,l0).
goal(p1,l0).
goal(p2,l2).
goal(p3,l1).
steps(40).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
