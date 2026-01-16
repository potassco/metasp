#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".

world(W):-time(W).

% true/0
true(__true,K) :- formula(tel,__true), time(K).
% false/0
:- formula(tel,__false), time(K), true(__false,K).

% and/2
true(__and(F,G),K) :- formula(tel,__and(F,G)), true(F,K), true(G,K).
true((F;G),K) :- formula(tel,__and(F,G)), true(__and(F,G),K).

% or/2
true(__or(F,G),K) :- formula(tel,__or(F,G)), true((F;G),K).
true(F,K);true(G,K) :- formula(tel,__or(F,G)), true(__or(F,G),K).

% neg/1 (default negation)
true(__neg(F),K) :- formula(tel,__neg(F)), time(K), not true(F,K).
not true(F,K) :- formula(tel,__neg(F)), true(__neg(F),K).

% initial/0
true(__initial,0) :- formula(tel,__initial).
:- true(__initial,K), formula(tel,__initial), K!=0.

% final/0.
true(__final,n) :- formula(tel,__final).
:- true(__final,K), formula(tel,__final), K!=n.

% next/1
true(F,K+1): time(K+1) :- formula(tel,__next(F)), true(__next(F),K).
true(__next(F),K) :- true(F,K+1), formula(tel,__next(F)), time(K).
% __until/2
true(until_then(L,R,J),K): K<=J, time(J)
  :- formula(tel,__until(L,R)), true(__until(L,R),K), time(K).
true(__until(L,R),K)
  :- formula(tel,__until(L,R)), true(until_then(L,R,_),K).

true(L,I) :- true(until_then(L,R,J),K), I=K..J-1.
true(R,J) :- true(until_then(L,R,J),K).
true(until_then(L,R,J),K)
  :- formula(tel,__until(L,R)), time(K), time(J), K<=J, true(R,J),
     true(L,I) : I=K..J-1.


