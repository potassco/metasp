#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.check-occur.lp".

#const lambda= horizon+1.
world(W):-time(W).

% true/0
true(__true,K) :- formula(tel,__true), time(K).

% initial/0
true(__initial,0) :- formula(tel,__initial).
:- true(__initial,K), formula(tel,__initial), K!=0.

% next/1
true(F,K+1): time(K+1) :- formula(tel,__next(F)), true(__next(F),K).
true(__next(F),K) :- true(F,K+1), formula(tel,__next(F)), time(K).

% __until/2
true(F,J) : time(J), K<=J :- true(__eventually(F),K).
true(__eventually(F),K) :- formula(tel,__eventually(F)), true(F,J), K<=J, time(K), time(J).


