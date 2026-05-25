fuelcost(25,l0,l1).
fuelcost(7,l0,l2).
fuelcost(8,l0,l4).
fuelcost(25,l1,l0).
fuelcost(16,l1,l3).
fuelcost(25,l1,l5).
fuelcost(7,l2,l0).
fuelcost(6,l2,l6).
fuelcost(16,l3,l1).
fuelcost(13,l3,l7).
fuelcost(8,l4,l0).
fuelcost(14,l4,l6).
fuelcost(2,l4,l7).
fuelcost(25,l5,l1).
fuelcost(12,l5,l6).
fuelcost(4,l5,l7).
fuelcost(6,l6,l2).
fuelcost(14,l6,l4).
fuelcost(12,l6,l5).
fuelcost(22,l6,l7).
fuelcost(13,l7,l3).
fuelcost(2,l7,l4).
fuelcost(4,l7,l5).
fuelcost(22,l7,l6).
at(t0,l1).
fuel(t0,85).
at(p0,l6).
at(p1,l1).
at(p2,l2).
at(p3,l5).
at(p4,l4).
at(p5,l3).
at(p6,l6).
at(p7,l2).
goal(p0,l3).
goal(p1,l3).
goal(p2,l0).
goal(p3,l0).
goal(p4,l0).
goal(p5,l2).
goal(p6,l4).
goal(p7,l4).
steps(128).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
