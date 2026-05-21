fuelcost(2,l0,l1).
fuelcost(25,l0,l3).
fuelcost(16,l0,l4).
fuelcost(2,l1,l0).
fuelcost(7,l1,l2).
fuelcost(14,l1,l3).
fuelcost(7,l2,l1).
fuelcost(7,l2,l3).
fuelcost(25,l3,l0).
fuelcost(14,l3,l1).
fuelcost(7,l3,l2).
fuelcost(25,l3,l4).
fuelcost(16,l4,l0).
fuelcost(25,l4,l3).
at(t0,l4).
fuel(t0,57).
at(p0,l4).
at(p1,l3).
at(p2,l1).
at(p3,l3).
at(p4,l3).
goal(p0,l0).
goal(p1,l0).
goal(p2,l0).
goal(p3,l4).
goal(p4,l4).
steps(86).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
