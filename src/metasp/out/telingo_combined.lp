

%%%%%% File: ./telingo/semantics.lp %%%%%%

#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/meta-time.lp".
#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/derived.lp".
#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/formulas.lp".
#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/show-time.lp".
#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/reify-defined.lp".

#const lambda= horizon+1.
world(W):-time(W).

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



%%%%%% Reified Input %%%%%%

tag(incremental).
atom_tuple(0).
atom_tuple(0,1).
literal_tuple(0).
rule(disjunction(0),normal(0)).
external(2,false).
atom_tuple(1).
atom_tuple(1,3).
literal_tuple(1).
literal_tuple(1,2).
rule(disjunction(1),normal(1)).
external(4,false).
external(5,false).
external(6,false).
atom_tuple(2).
atom_tuple(2,7).
rule(disjunction(2),normal(1)).
atom_tuple(3).
atom_tuple(3,8).
literal_tuple(2).
literal_tuple(2,-4).
rule(disjunction(3),normal(2)).
atom_tuple(4).
literal_tuple(3).
literal_tuple(3,4).
literal_tuple(3,8).
rule(disjunction(4),normal(3)).
atom_tuple(5).
atom_tuple(5,9).
literal_tuple(4).
literal_tuple(4,6).
rule(disjunction(5),normal(4)).
output(initial,4).
literal_tuple(5).
literal_tuple(5,9).
output(next(push),5).
literal_tuple(6).
literal_tuple(6,4).
output(green,6).
literal_tuple(7).
literal_tuple(7,8).
output(red,7).
output(push,1).
literal_tuple(8).
literal_tuple(8,7).
output(eventually(always(green)),8).
literal_tuple(9).
literal_tuple(9,5).
output(always(green),9).
literal_tuple(10).
literal_tuple(10,3).
output(_show(push),10).
output(_show,0).