#defined derive/3.

formula(T,F2) :- derive(F1,F2,T).
true(F2,K) :- derive(F1,F2,T), true(F1,K).
true(F1,K) :- derive(F1,F2,T), true(F2,K).
