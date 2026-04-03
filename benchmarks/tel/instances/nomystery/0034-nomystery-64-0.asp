fuelcost(19,l0,l1).
fuelcost(17,l0,l2).
fuelcost(23,l0,l3).
fuelcost(19,l1,l0).
fuelcost(2,l1,l2).
fuelcost(25,l1,l3).
fuelcost(17,l2,l0).
fuelcost(2,l2,l1).
fuelcost(20,l2,l3).
fuelcost(23,l3,l0).
fuelcost(25,l3,l1).
fuelcost(20,l3,l2).
at(t0,l0).
fuel(t0,64).
at(p0,l1).
at(p1,l3).
at(p2,l2).
at(p3,l0).
goal(p0,l0).
goal(p1,l0).
goal(p2,l3).
goal(p3,l1).
steps(97).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
