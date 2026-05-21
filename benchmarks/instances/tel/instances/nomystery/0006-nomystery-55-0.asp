fuelcost(18,l0,l1).
fuelcost(3,l0,l3).
fuelcost(11,l0,l4).
fuelcost(18,l1,l0).
fuelcost(10,l1,l2).
fuelcost(8,l1,l4).
fuelcost(10,l2,l1).
fuelcost(15,l2,l4).
fuelcost(3,l3,l0).
fuelcost(13,l3,l4).
fuelcost(11,l4,l0).
fuelcost(8,l4,l1).
fuelcost(15,l4,l2).
fuelcost(13,l4,l3).
at(t0,l1).
fuel(t0,55).
at(p0,l0).
at(p1,l3).
at(p2,l1).
at(p3,l2).
at(p4,l4).
goal(p0,l4).
goal(p1,l4).
goal(p2,l4).
goal(p3,l1).
goal(p4,l3).
steps(56).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
