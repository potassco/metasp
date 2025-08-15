#include "metasp.meta-time.lp".
#include "metasp.derived.lp".
#include "metasp.formulas.lp".
#include "metasp.show.lp".

#const lambda= horizon+1.

% true/0
true(true,K) :- formula(tel,true), time(K).
% false/0
:- formula(tel,false), time(K), true(false,K).

% and/2
true(and(F,G),K) :- formula(tel,and(F,G)), true(F,K), true(G,K).
true((F;G),K) :- formula(tel,and(F,G)), true(and(F,G),K).

% or/2
true(or(F,G),K) :- formula(tel,or(F,G)), true((F;G),K).
true(F,K);true(G,K) :- formula(tel,or(F,G)), true(or(F,G),K).

% neg/1 (default negation)
true(neg(F),K) :- formula(tel,neg(F)), time(K), not true(F,K).
not true(F,K) :- formula(tel,neg(F)), true(neg(F),K).

% initial/0
true(initial,0) :- formula(tel,initial).
:- true(initial,K), formula(tel,initial), K!=0.

% final/0.
true(final,lambda-1) :- formula(tel,final).
:- true(final,K), formula(tel,final), K!=lambda-1.

% next/1
true(F,K+1): time(K+1) :- formula(tel,next(F)), true(next(F),K).
true(next(F),K) :- true(F,K+1), formula(tel,next(F)), time(K).

% until/2
true(until_then(L,R,J),K): K<=J, time(J)
  :- formula(tel,until(L,R)), true(until(L,R),K), time(K).
true(until(L,R),K)
  :- formula(tel,until(L,R)), true(until_then(L,R,_),K).

true(L,I) :- true(until_then(L,R,J),K), I=K..J-1.
true(R,J) :- true(until_then(L,R,J),K).
true(until_then(L,R,J),K)
  :- formula(tel,until(L,R)), time(K), time(J), K<=J, true(R,J),
     true(L,I) : I=K..J-1.

%--------- Derived

derive(wnext(F),or(next(F),final),tel) :- formula(tel,wnext(F)).
% wprev/1
derive(wprev(F),or(prev(F),initial),tel) :- formula(tel,wprev(F)).
% eventually_after/1
derive(eventually(F),until(true,F),tel) :- formula(tel,eventually(F)).
% always/1
derive(always(F),release(false,F),tel) :- formula(tel,always(F)).
% release/2
derive(release(L,R),until(R,and(R,or(L,final))),tel) :- formula(tel,release(L,R)).
