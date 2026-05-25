fuelcost(16,l0,l3).
fuelcost(12,l0,l5).
fuelcost(9,l1,l2).
fuelcost(12,l1,l3).
fuelcost(2,l1,l4).
fuelcost(9,l2,l1).
fuelcost(4,l2,l3).
fuelcost(5,l2,l4).
fuelcost(10,l2,l5).
fuelcost(16,l3,l0).
fuelcost(12,l3,l1).
fuelcost(4,l3,l2).
fuelcost(12,l3,l5).
fuelcost(2,l4,l1).
fuelcost(5,l4,l2).
fuelcost(12,l5,l0).
fuelcost(10,l5,l2).
fuelcost(12,l5,l3).
at(t0,l4).
fuel(t0,56).
at(p0,l5).
at(p1,l5).
at(p2,l1).
at(p3,l0).
at(p4,l1).
at(p5,l1).
goal(p0,l3).
goal(p1,l4).
goal(p2,l5).
goal(p3,l2).
goal(p4,l4).
goal(p5,l3).
steps(85).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
