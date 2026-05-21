fuelcost(16,l0,l2).
fuelcost(8,l0,l4).
fuelcost(12,l0,l8).
fuelcost(15,l1,l2).
fuelcost(17,l1,l7).
fuelcost(16,l2,l0).
fuelcost(15,l2,l1).
fuelcost(23,l2,l3).
fuelcost(5,l2,l7).
fuelcost(23,l3,l2).
fuelcost(23,l3,l7).
fuelcost(8,l4,l0).
fuelcost(9,l4,l7).
fuelcost(17,l5,l6).
fuelcost(21,l5,l7).
fuelcost(17,l6,l5).
fuelcost(17,l6,l7).
fuelcost(17,l7,l1).
fuelcost(5,l7,l2).
fuelcost(23,l7,l3).
fuelcost(9,l7,l4).
fuelcost(21,l7,l5).
fuelcost(17,l7,l6).
fuelcost(22,l7,l8).
fuelcost(12,l8,l0).
fuelcost(22,l8,l7).
at(t0,l1).
fuel(t0,172).
at(p0,l3).
at(p1,l4).
at(p2,l4).
at(p3,l3).
at(p4,l5).
at(p5,l2).
at(p6,l3).
at(p7,l0).
at(p8,l0).
goal(p0,l6).
goal(p1,l0).
goal(p2,l8).
goal(p3,l7).
goal(p4,l4).
goal(p5,l0).
goal(p6,l2).
goal(p7,l7).
goal(p8,l2).
steps(104).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
