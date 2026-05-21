fuelcost(9,l0,l4).
fuelcost(20,l0,l6).
fuelcost(14,l0,l7).
fuelcost(17,l1,l3).
fuelcost(17,l1,l7).
fuelcost(1,l1,l8).
fuelcost(14,l2,l3).
fuelcost(21,l2,l4).
fuelcost(3,l2,l5).
fuelcost(9,l2,l6).
fuelcost(17,l3,l1).
fuelcost(14,l3,l2).
fuelcost(6,l3,l4).
fuelcost(9,l4,l0).
fuelcost(21,l4,l2).
fuelcost(6,l4,l3).
fuelcost(3,l5,l2).
fuelcost(23,l5,l7).
fuelcost(20,l6,l0).
fuelcost(9,l6,l2).
fuelcost(12,l6,l7).
fuelcost(14,l7,l0).
fuelcost(17,l7,l1).
fuelcost(23,l7,l5).
fuelcost(12,l7,l6).
fuelcost(1,l8,l1).
at(t0,l3).
fuel(t0,117).
at(p0,l8).
at(p1,l4).
at(p2,l6).
at(p3,l4).
at(p4,l8).
at(p5,l2).
at(p6,l2).
at(p7,l7).
at(p8,l8).
goal(p0,l6).
goal(p1,l7).
goal(p2,l5).
goal(p3,l0).
goal(p4,l2).
goal(p5,l1).
goal(p6,l6).
goal(p7,l1).
goal(p8,l7).
steps(352).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
