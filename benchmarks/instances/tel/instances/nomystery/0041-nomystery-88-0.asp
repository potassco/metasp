fuelcost(13,l0,l3).
fuelcost(19,l0,l4).
fuelcost(12,l0,l5).
fuelcost(7,l1,l3).
fuelcost(5,l1,l5).
fuelcost(20,l2,l3).
fuelcost(16,l2,l5).
fuelcost(13,l3,l0).
fuelcost(7,l3,l1).
fuelcost(20,l3,l2).
fuelcost(20,l3,l4).
fuelcost(1,l3,l5).
fuelcost(19,l4,l0).
fuelcost(20,l4,l3).
fuelcost(12,l5,l0).
fuelcost(5,l5,l1).
fuelcost(16,l5,l2).
fuelcost(1,l5,l3).
at(t0,l3).
fuel(t0,88).
at(p0,l3).
at(p1,l5).
at(p2,l1).
at(p3,l2).
at(p4,l0).
at(p5,l3).
goal(p0,l0).
goal(p1,l2).
goal(p2,l4).
goal(p3,l5).
goal(p4,l3).
goal(p5,l2).
steps(265).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
