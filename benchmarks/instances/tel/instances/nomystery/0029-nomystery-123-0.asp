fuelcost(12,l0,l1).
fuelcost(19,l0,l7).
fuelcost(12,l1,l0).
fuelcost(11,l1,l4).
fuelcost(14,l1,l6).
fuelcost(15,l1,l8).
fuelcost(1,l2,l3).
fuelcost(21,l2,l4).
fuelcost(1,l3,l2).
fuelcost(17,l3,l4).
fuelcost(16,l3,l5).
fuelcost(11,l4,l1).
fuelcost(21,l4,l2).
fuelcost(17,l4,l3).
fuelcost(24,l4,l7).
fuelcost(16,l5,l3).
fuelcost(2,l5,l7).
fuelcost(14,l6,l1).
fuelcost(14,l6,l8).
fuelcost(19,l7,l0).
fuelcost(24,l7,l4).
fuelcost(2,l7,l5).
fuelcost(4,l7,l8).
fuelcost(15,l8,l1).
fuelcost(14,l8,l6).
fuelcost(4,l8,l7).
at(t0,l7).
fuel(t0,123).
at(p0,l2).
at(p1,l5).
at(p2,l7).
at(p3,l6).
at(p4,l7).
at(p5,l6).
at(p6,l0).
at(p7,l7).
at(p8,l0).
goal(p0,l0).
goal(p1,l0).
goal(p2,l6).
goal(p3,l3).
goal(p4,l6).
goal(p5,l1).
goal(p6,l1).
goal(p7,l0).
goal(p8,l7).
steps(370).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
