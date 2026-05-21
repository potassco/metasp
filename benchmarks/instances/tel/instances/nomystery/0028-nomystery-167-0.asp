fuelcost(14,l0,l2).
fuelcost(1,l0,l4).
fuelcost(2,l0,l8).
fuelcost(24,l1,l4).
fuelcost(22,l1,l5).
fuelcost(25,l1,l7).
fuelcost(14,l2,l0).
fuelcost(18,l2,l4).
fuelcost(8,l2,l5).
fuelcost(9,l3,l5).
fuelcost(14,l3,l8).
fuelcost(1,l4,l0).
fuelcost(24,l4,l1).
fuelcost(18,l4,l2).
fuelcost(5,l4,l8).
fuelcost(22,l5,l1).
fuelcost(8,l5,l2).
fuelcost(9,l5,l3).
fuelcost(8,l5,l8).
fuelcost(8,l6,l8).
fuelcost(25,l7,l1).
fuelcost(2,l8,l0).
fuelcost(14,l8,l3).
fuelcost(5,l8,l4).
fuelcost(8,l8,l5).
fuelcost(8,l8,l6).
at(t0,l7).
fuel(t0,167).
at(p0,l6).
at(p1,l6).
at(p2,l3).
at(p3,l0).
at(p4,l7).
at(p5,l2).
at(p6,l4).
at(p7,l6).
at(p8,l8).
goal(p0,l1).
goal(p1,l0).
goal(p2,l7).
goal(p3,l5).
goal(p4,l1).
goal(p5,l8).
goal(p6,l8).
goal(p7,l2).
goal(p8,l5).
steps(502).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
