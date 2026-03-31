fuelcost(9,l0,l3).
fuelcost(22,l0,l7).
fuelcost(16,l1,l3).
fuelcost(8,l2,l3).
fuelcost(6,l2,l5).
fuelcost(10,l2,l6).
fuelcost(1,l2,l7).
fuelcost(9,l3,l0).
fuelcost(16,l3,l1).
fuelcost(8,l3,l2).
fuelcost(18,l3,l6).
fuelcost(18,l3,l7).
fuelcost(16,l4,l5).
fuelcost(2,l4,l6).
fuelcost(15,l4,l7).
fuelcost(6,l5,l2).
fuelcost(16,l5,l4).
fuelcost(10,l6,l2).
fuelcost(18,l6,l3).
fuelcost(2,l6,l4).
fuelcost(22,l7,l0).
fuelcost(1,l7,l2).
fuelcost(18,l7,l3).
fuelcost(15,l7,l4).
at(t0,l3).
fuel(t0,86).
at(p0,l0).
at(p1,l5).
at(p2,l6).
at(p3,l3).
at(p4,l6).
at(p5,l6).
at(p6,l0).
at(p7,l3).
goal(p0,l3).
goal(p1,l6).
goal(p2,l4).
goal(p3,l2).
goal(p4,l0).
goal(p5,l4).
goal(p6,l1).
goal(p7,l2).
steps(259).
truck(T) :- fuel(T,_).
package(P) :- at(P,L), not truck(P).
location(L) :- fuelcost(_,L,_).
location(L) :- fuelcost(_,_,L).
locatable(O) :- at(O,L).

action(unload(P,T,L)) :- package(P), truck(T), location(L).
action(load(P,T,L)) :- package(P), truck(T), location(L).
action(drive(T,L1,L2)) :- fuelcost(Fueldelta,L1,L2), truck(T).
