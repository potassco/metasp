fuelcost(22,l0,l1).
fuelcost(23,l0,l3).
fuelcost(4,l0,l5).
fuelcost(22,l1,l0).
fuelcost(4,l1,l2).
fuelcost(21,l1,l5).
fuelcost(4,l2,l1).
fuelcost(4,l2,l3).
fuelcost(10,l2,l4).
fuelcost(23,l3,l0).
fuelcost(4,l3,l2).
fuelcost(12,l3,l5).
fuelcost(10,l4,l2).
fuelcost(6,l4,l5).
fuelcost(4,l5,l0).
fuelcost(21,l5,l1).
fuelcost(12,l5,l3).
fuelcost(6,l5,l4).
at(t0,l3).
fuel(t0,44).
at(p0,l5).
at(p1,l0).
at(p2,l3).
at(p3,l5).
at(p4,l2).
at(p5,l4).
goal(p0,l4).
goal(p1,l5).
goal(p2,l0).
goal(p3,l4).
goal(p4,l4).
goal(p5,l2).
steps(34).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
