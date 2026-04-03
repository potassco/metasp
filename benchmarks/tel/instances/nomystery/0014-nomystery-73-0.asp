fuelcost(25,l0,l1).
fuelcost(20,l0,l3).
fuelcost(15,l0,l4).
fuelcost(25,l1,l0).
fuelcost(10,l1,l2).
fuelcost(3,l1,l4).
fuelcost(10,l2,l1).
fuelcost(22,l2,l3).
fuelcost(4,l2,l4).
fuelcost(3,l2,l5).
fuelcost(20,l3,l0).
fuelcost(22,l3,l2).
fuelcost(15,l4,l0).
fuelcost(3,l4,l1).
fuelcost(4,l4,l2).
fuelcost(13,l4,l5).
fuelcost(3,l5,l2).
fuelcost(13,l5,l4).
at(t0,l1).
fuel(t0,73).
at(p0,l0).
at(p1,l0).
at(p2,l2).
at(p3,l4).
at(p4,l5).
at(p5,l0).
goal(p0,l2).
goal(p1,l2).
goal(p2,l5).
goal(p3,l0).
goal(p4,l1).
goal(p5,l3).
steps(74).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
