%# Semantics encoding for Temporal Equilibrium Logic (TEL)
% This version uses the explicit H and T sets.

%## Included standard encodings
#include "metasp.meta-ht-time.lp".
#include "metasp.show-ht-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".
% ----------------------------

%## Operators

%### `&true`
true(&true, M, K) :- formula(tel,&true), model(M), time(K).

%### `&initial`
true(&initial, M, 0) :- formula(tel,&initial), model(M).
:- formula(tel,&initial), true(&initial, M, K), K!=0.

%### `&next`
true(F,M,K+1) : time(K+1) :- formula(tel,&next(F)), true(&next(F),M,K).
true(&next(F),M,K) :- formula(tel,&next(F)), true(F,M,K+1), time(K).

%### `&prev`
true(F,M,K-1) : time(K-1) :- formula(tel,&prev(F)), true(&prev(F),M,K).
true(&prev(F),M,K) :- formula(tel,&prev(F)), true(F,M,K-1), time(K).

%### `&eventually`
true(F,M,J) : time(J), K<=J :- true(&eventually(F),M,K).
true(&eventually(F),M,K) :- formula(tel,&eventually(F)), true(F,M,J), K<=J, time(K), time(J).

%### `&not`
true(&not(F),M,K) :- model(M), formula(tel,&not(F)), not true(F,t,K), time(K).
:- true(&not(F),M,K), true(F,t,K), time(K).
