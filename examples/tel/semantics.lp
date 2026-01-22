#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".
#include "metasp.check-occur.lp".

true(__true,K) :- formula(tel,__true), time(K).

true(__initial,0) :- formula(tel,__initial).
:- formula(tel,__initial), true(__initial,K), K!=0.

true(F,K+1) : time(K+1) :- formula(tel,__next(F)), true(__next(F),K).
true(__next(F),K) :- formula(tel,__next(F)), true(F,K+1), time(K).

true(F,J) : time(J), K<=J :- true(__eventually(F),K).
true(__eventually(F),K) :- formula(tel,__eventually(F)), true(F,J), K<=J, time(K), time(J).
