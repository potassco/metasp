fuelcost(1,l0,l2).
fuelcost(4,l0,l3).
fuelcost(16,l0,l4).
fuelcost(5,l1,l2).
fuelcost(19,l1,l3).
fuelcost(1,l2,l0).
fuelcost(5,l2,l1).
fuelcost(22,l2,l4).
fuelcost(4,l3,l0).
fuelcost(19,l3,l1).
fuelcost(10,l3,l4).
fuelcost(16,l4,l0).
fuelcost(22,l4,l2).
fuelcost(10,l4,l3).
at(t0,l0).
fuel(t0,36).
at(p0,l4).
at(p1,l4).
at(p2,l1).
at(p3,l3).
at(p4,l2).
goal(p0,l3).
goal(p1,l3).
goal(p2,l0).
goal(p3,l4).
goal(p4,l0).
steps(109).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
