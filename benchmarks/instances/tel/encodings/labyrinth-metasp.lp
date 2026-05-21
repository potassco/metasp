% #program initial.
goal(X,Y)   :- goal_on(X,Y), &initial.
reach(X,Y)  :- init_on(X,Y), &initial.
conn(X,Y,D) :- connect(X,Y,D), &initial.

% #program always.
neg_goal :- goal(X,Y), not reach(X,Y).

dir(e). dir(w). dir(n). dir(s).
inverse(e,w). inverse(w,e).
inverse(n,s). inverse(s,n).

row(X) :- field(X,Y).
col(Y) :- field(X,Y).

num_rows(X) :- row(X), not row(XX), XX = X+1.
num_cols(Y) :- col(Y), not col(YY), YY = Y+1.

dneighbor(n,X,Y,XX,Y) :- field(X,Y), field(XX,Y), XX = X+1.
dneighbor(s,X,Y,XX,Y) :- field(X,Y), field(XX,Y), XX = X-1.
dneighbor(e,X,Y,X,YY) :- field(X,Y), field(X,YY), YY = Y+1.
dneighbor(w,X,Y,X,YY) :- field(X,Y), field(X,YY), YY = Y-1.

neighbor(D,X,Y,XX,YY) :- dneighbor(D,X,Y,XX,YY).
neighbor(n,X,Y, 1, Y) :- field(X,Y), num_rows(X).
neighbor(s,1,Y, X, Y) :- field(X,Y), num_rows(X).
neighbor(e,X,Y, X, 1) :- field(X,Y), num_cols(Y).
neighbor(w,X,1, X, Y) :- field(X,Y), num_cols(Y).

% #program dynamic.
{ occurs(some_action) } :- not &initial.
rrpush   :- &prev(neg_goal), not ccpush, occurs(some_action), not &initial.
ccpush   :- &prev(neg_goal), not rrpush, occurs(some_action), not &initial.

orpush(X) :- row(X), row(XX), rpush(XX), X != XX, not &initial.
ocpush(Y) :- col(Y), col(YY), cpush(YY), Y != YY, not &initial.

rpush(X)  :- row(X), rrpush, not orpush(X), not &initial.
cpush(Y)  :- col(Y), ccpush, not ocpush(Y), not &initial.

push(X,e) :- rpush(X), not push(X,w), not &initial.
push(X,w) :- rpush(X), not push(X,e), not &initial.
push(Y,n) :- cpush(Y), not push(Y,s), not &initial.
push(Y,s) :- cpush(Y), not push(Y,n), not &initial.

shift(XX,YY,X,Y) :- neighbor(e,XX,YY,X,Y), push(XX,e), not &initial.
shift(XX,YY,X,Y) :- neighbor(w,XX,YY,X,Y), push(XX,w), not &initial.
shift(XX,YY,X,Y) :- neighbor(n,XX,YY,X,Y), push(YY,n), not &initial.
shift(XX,YY,X,Y) :- neighbor(s,XX,YY,X,Y), push(YY,s), not &initial.
shift( X, Y,X,Y) :- field(X,Y), not push(X,e), not push(X,w), not push(Y,n), not push(Y,s), not &initial.

conn(X,Y,D) :- &prev(conn(XX,YY,D)), dir(D), shift(XX,YY,X,Y), not &initial.

goal(X,Y) :- &prev(goal(XX,YY)), shift(XX,YY,X,Y), not &initial.

reach(X,Y) :- &prev(reach(XX,YY)), shift(XX,YY,X,Y), not &initial.
reach(X,Y) :- reach(XX,YY), dneighbor(D,XX,YY,X,Y), conn(XX,YY,D), conn(X,Y,E), inverse(D,E), not &initial.

% #program final.
:- neg_goal, &final.
