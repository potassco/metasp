%% ------- Fischer Ladner closure --------- %%
formula(del, __dia(P,__dia(__star(P),F))) :- formula(del, __dia(__star(P),F)).
formula(del, __box(P,__box(__star(P),F))) :- formula(del, __box(__star(P),F)).

formula(del, __dia(P1,F)) :- formula(del, __dia(__choice(P1,P2),F)).
formula(del, __dia(P2,F)) :- formula(del, __dia(__choice(P1,P2),F)).
formula(del, __box(P1,F)) :- formula(del, __box(__choice(P1,P2),F)).
formula(del, __box(P2,F)) :- formula(del, __box(__choice(P1,P2),F)).

formula(del, __box(P1,__box(P2,F))) :- formula(del, __box(__seq(P1,P2),F)).
formula(del, __box(P2,F)) :- formula(del, __box(__seq(P1,P2),F)). %This had to be included since we don't have rules for subformulas anymore
formula(del, __dia(P1,__dia(P2,F))) :- formula(del, __dia(__seq(P1,P2),F)).
formula(del, __dia(P2,F)) :- formula(del, __dia(__seq(P1,P2),F)). %This had to be included since we don't have rules for subformulas anymore


%% ------- Semantics --------- %%
% __top/0
true(__top,K) :- formula(del,__top), time(K).
% __bot/0
:- formula(del,__bot), time(K), true(__bot,K).

% dia __step
true(F,K+1): time(K+1) :- formula(del,__dia(__step,F)), true(__dia(__step,F),K).
true(__dia(__step,F),K) :- true(F,K+1), formula(del,__dia(__step,F)), time(K).

% dia __test
true(F,K) :- formula(del,__dia(__test(F2),F)), true(__dia(__test(F2),F),K).
true(F2,K) :- formula(del,__dia(__test(F2),F)), true(__dia(__test(F2),F),K).
true(__dia(__test(F2),F),K) :- true(F,K),true(F2,K), formula(del,__dia(__test(F2),F)).

% dia choice
true(__dia(P1,F),K);true(__dia(P2,F),K) :- true(__dia(__choice(P1,P2),F),K).
true(__dia(__choice(P1,P2),F),K) :- true(__dia(P1,F),K), formula(del,__dia(__choice(P1,P2),F)).
true(__dia(__choice(P1,P2),F),K) :- true(__dia(P2,F),K), formula(del,__dia(__choice(P1,P2),F)).

% dia seq
true(__dia(P1,__dia(P2,F)),K) :- true(__dia(__seq(P1,P2),F),K).
true(__dia(__seq(P1,P2),F),K):- true(__dia(P1,__dia(P2,F)),K), formula(del, __dia(__seq(P1,P2),F)).

% dia __star
true(F,K); true(__dia(P,__dia(__star(P),F)),K):-  true(__dia(__star(P),F),K).
true(__dia(__star(P),F),K):-  formula(del, __dia(__star(P),F)), true(F,K).
true(__dia(__star(P),F),K):-  formula(del, __dia(__star(P),F)), true(__dia(P,__dia(__star(P),F)),K).

% box __step
true(F,K+1):- formula(del,__box(__step,F)), true(__box(__step,F),K), time(K+1).
true(__box(__step,F),K) :- true(F,K+1), formula(del,__box(__step,F)), time(K).
true(__box(__step,F),K) :- formula(del,__box(__step,F)), time(K), not time(K+1).

% box __test
true(F,K) :- formula(del,__box(__test(F2),F)), true(__box(__test(F2),F),K), true(F2,K).
% Maybe there is something missing here because implications in HT are different
true(__box(__test(F2),F),K) :- not true(F2,K), formula(del,__box(__test(F2),F)), time(K).
true(__box(__test(F2),F),K) :- true(F2,K), true(F,K), formula(del,__box(__test(F2),F)).


% box choice
true(__box(P1,F),K) :- true(__box(__choice(P1,P2),F),K).
true(__box(P2,F),K) :- true(__box(__choice(P1,P2),F),K).
true(__box(__choice(P1,P2),F),K) :- true(__box(P1,F),K), true(__box(P2,F),K), formula(del,__box(__choice(P1,P2),F)).


% box seq
true(__box(P1,__box(P2,F)),K) :- true(__box(__seq(P1,P2),F),K).
true(__box(__seq(P1,P2),F),K):- true(__box(P1,__box(P2,F)),K), formula(del, __box(__seq(P1,P2),F)).

% box __star
true(F,K):-  true(__box(__star(P),F),K).
true(__box(P,__box(__star(P),F)),K):-  true(__box(__star(P),F),K).
true(__box(__star(P),F),K):-  formula(del, __box(__star(P),F)), true(F,K), true(__box(P,__box(__star(P),F)),K).

