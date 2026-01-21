%% ------- Fischer Ladner closure --------- %%
formula(del, __eventually(P,__eventually(__star(P),F))) :- formula(del, __eventually(__star(P),F)).
formula(del, __eventually(P1,F)) :- formula(del, __eventually(__choice(P1,P2),F)).
formula(del, __eventually(P2,F)) :- formula(del, __eventually(__choice(P1,P2),F)).
formula(del, __eventually(P1,__eventually(P2,F))) :- formula(del, __eventually(__seq(P1,P2),F)).
formula(del, __eventually(P2,F)) :- formula(del, __eventually(__seq(P1,P2),F)).

formula(del, __always(P,__always(__star(P),F))) :- formula(del, __always(__star(P),F)).
formula(del, __always(P1,F)) :- formula(del, __always(__choice(P1,P2),F)).
formula(del, __always(P2,F)) :- formula(del, __always(__choice(P1,P2),F)).
formula(del, __always(P1,__always(P2,F))) :- formula(del, __always(__seq(P1,P2),F)).
formula(del, __always(P2,F)) :- formula(del, __always(__seq(P1,P2),F)).


% __true/0
true(__true,K) :- formula(del,__true), time(K).
% __false/0
:- formula(del,__false), time(K), true(__false,K).

% dia __step
true(F,K+1): time(K+1) :- formula(del,__eventually(__step,F)), true(__eventually(__step,F),K).
true(__eventually(__step,F),K) :- true(F,K+1), formula(del,__eventually(__step,F)), time(K).

% dia __test
true(F,K) :- formula(del,__eventually(__test(F2),F)), true(__eventually(__test(F2),F),K).
true(F2,K) :- formula(del,__eventually(__test(F2),F)), true(__eventually(__test(F2),F),K).
true(__eventually(__test(F2),F),K) :- true(F,K),true(F2,K), formula(del,__eventually(__test(F2),F)).

% dia choice
true(__eventually(P1,F),K);true(__eventually(P2,F),K) :- true(__eventually(__choice(P1,P2),F),K).
true(__eventually(__choice(P1,P2),F),K) :- true(__eventually(P1,F),K), formula(del,__eventually(__choice(P1,P2),F)).
true(__eventually(__choice(P1,P2),F),K) :- true(__eventually(P2,F),K), formula(del,__eventually(__choice(P1,P2),F)).

% dia seq
true(__eventually(P1,__eventually(P2,F)),K) :- true(__eventually(__seq(P1,P2),F),K).
true(__eventually(__seq(P1,P2),F),K):- true(__eventually(P1,__eventually(P2,F)),K), formula(del, __eventually(__seq(P1,P2),F)).

% dia __star
true(F,K); true(__eventually(P,__eventually(__star(P),F)),K):-  true(__eventually(__star(P),F),K).
true(__eventually(__star(P),F),K):-  formula(del, __eventually(__star(P),F)), true(F,K).
true(__eventually(__star(P),F),K):-  formula(del, __eventually(__star(P),F)), true(__eventually(P,__eventually(__star(P),F)),K).

% box __step
true(F,K+1):- formula(del,__always(__step,F)), true(__always(__step,F),K), time(K+1).
true(__always(__step,F),K) :- true(F,K+1), formula(del,__always(__step,F)), time(K).
true(__always(__step,F),K) :- formula(del,__always(__step,F)), time(K), not time(K+1).

% box __test
true(F,K) :- formula(del,__always(__test(F2),F)), true(__always(__test(F2),F),K), true(F2,K).
% Maybe there is something missing here because implications in HT are different
true(__always(__test(F2),F),K) :- not true(F2,K), formula(del,__always(__test(F2),F)), time(K).
true(__always(__test(F2),F),K) :- true(F2,K), true(F,K), formula(del,__always(__test(F2),F)).


% box choice
true(__always(P1,F),K) :- true(__always(__choice(P1,P2),F),K).
true(__always(P2,F),K) :- true(__always(__choice(P1,P2),F),K).
true(__always(__choice(P1,P2),F),K) :- true(__always(P1,F),K), true(__always(P2,F),K), formula(del,__always(__choice(P1,P2),F)).


% box seq
true(__always(P1,__always(P2,F)),K) :- true(__always(__seq(P1,P2),F),K).
true(__always(__seq(P1,P2),F),K):- true(__always(P1,__always(P2,F)),K), formula(del, __always(__seq(P1,P2),F)).

% box __star
true(F,K):-  true(__always(__star(P),F),K).
true(__always(P,__always(__star(P),F)),K):-  true(__always(__star(P),F),K).
true(__always(__star(P),F),K):-  formula(del, __always(__star(P),F)), true(F,K), true(__always(P,__always(__star(P),F)),K).
