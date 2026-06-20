%# Semantics encoding for Temporal Equilibrium Logic (TEL)

%## Included standard encodings
#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".
% ----------------------------

%## Operators

%### `&true`
true(&true,K) :- formula(tel,&true), time(K).

%### `&initial`
true(&initial,0) :- formula(tel,&initial).
:- formula(tel,&initial), true(&initial,K), K!=0.

%### `&next`
true(F,K+1) : time(K+1) :- formula(tel,&next(F)), true(&next(F),K).
true(&next(F),K) :- formula(tel,&next(F)), true(F,K+1), time(K).

%### `&prev`
true(F,K-1) : time(K-1) :- formula(tel,&prev(F)), true(&prev(F),K).
true(&prev(F),K) :- formula(tel,&prev(F)), true(F,K-1), time(K).

%### `&eventually`
true(F,J) : time(J), K<=J :- true(&eventually(F),K).
true(&eventually(F),K) :- formula(tel,&eventually(F)), true(F,J), K<=J, time(K), time(J).

%### `&not`
true(&not(F),K) :- formula(tel,&not(F)), not true(F,K), time(K).
:- true(&not(F),K), true(F,K), time(K).
