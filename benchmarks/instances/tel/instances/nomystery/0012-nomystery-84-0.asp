fuelcost(11,l0,l1).
fuelcost(16,l0,l2).
fuelcost(3,l0,l4).
fuelcost(11,l1,l0).
fuelcost(4,l1,l3).
fuelcost(23,l1,l4).
fuelcost(25,l1,l5).
fuelcost(16,l2,l0).
fuelcost(20,l2,l4).
fuelcost(4,l3,l1).
fuelcost(9,l3,l5).
fuelcost(3,l4,l0).
fuelcost(23,l4,l1).
fuelcost(20,l4,l2).
fuelcost(21,l4,l5).
fuelcost(25,l5,l1).
fuelcost(9,l5,l3).
fuelcost(21,l5,l4).
at(t0,l3).
fuel(t0,84).
at(p0,l2).
at(p1,l5).
at(p2,l0).
at(p3,l2).
at(p4,l1).
at(p5,l1).
goal(p0,l3).
goal(p1,l1).
goal(p2,l2).
goal(p3,l4).
goal(p4,l5).
goal(p5,l0).
steps(85).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
