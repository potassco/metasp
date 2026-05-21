fuelcost(8,l0,l2).
fuelcost(15,l0,l4).
fuelcost(16,l1,l2).
fuelcost(25,l1,l3).
fuelcost(8,l2,l0).
fuelcost(16,l2,l1).
fuelcost(1,l2,l3).
fuelcost(19,l2,l4).
fuelcost(25,l3,l1).
fuelcost(1,l3,l2).
fuelcost(7,l3,l4).
fuelcost(15,l4,l0).
fuelcost(19,l4,l2).
fuelcost(7,l4,l3).
at(t0,l0).
fuel(t0,63).
at(p0,l0).
at(p1,l1).
at(p2,l4).
at(p3,l2).
at(p4,l0).
goal(p0,l4).
goal(p1,l2).
goal(p2,l0).
goal(p3,l1).
goal(p4,l4).
steps(190).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
