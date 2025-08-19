%% ------- Fischer Ladner closure --------- %%
formula(del, dia(P,dia(star(P),F))) :- formula(del, dia(star(P),F)).
formula(del, box(P,box(star(P),F))) :- formula(del, box(star(P),F)).
formula(del, dia(P1,F)) :- formula(del, dia(choice(P1,P2),F)).
formula(del, dia(P2,F)) :- formula(del, dia(choice(P1,P2),F)).
formula(del, box(P1,F)) :- formula(del, box(choice(P1,P2),F)).
formula(del, box(P2,F)) :- formula(del, box(choice(P1,P2),F)).

%% ------- Semantics --------- %%
% top/0
true(top,K) :- formula(del,top), time(K).
% bot/0
:- formula(del,bot), time(K), true(bot,K).

% dia step
true(F,K+1): time(K+1) :- formula(del,dia(step,F)), true(dia(step,F),K).
true(dia(step,F),K) :- true(F,K+1), formula(del,dia(step,F)), time(K).

% dia test
true(F,K) :- formula(del,dia(test(F2),F)), true(dia(test(F2),F),K).
true(F2,K) :- formula(del,dia(test(F2),F)), true(dia(test(F2),F),K).
true(dia(test(F2),F),K) :- true(F,K),true(F2,K), formula(del,dia(test(F2),F)).

% dia choice
true(dia(P1,F),K);true(dia(P2,F),K) :- true(dia(choice(P1,P2),F),K).
true(dia(choice(P1,P2),F),K) :- true(dia(P1,F),K), formula(del,dia(choice(P1,P2),F)).
true(dia(choice(P1,P2),F),K) :- true(dia(P2,F),K), formula(del,dia(choice(P1,P2),F)).

% dia star
true(F,K); true(dia(P,dia(star(P),F)),K):-  true(dia(star(P),F),K).
true(dia(star(P),F),K):-  formula(del, dia(star(P),F)), true(F,K).
true(dia(star(P),F),K):-  formula(del, dia(star(P),F)), true(dia(P,dia(star(P),F)),K).

% box step
true(F,K+1):- formula(del,box(step,F)), true(box(step,F),K), time(K+1).
true(box(step,F),K) :- true(F,K+1), formula(del,box(step,F)), time(K).

% box test
true(F,K) :- formula(del,box(test(F2),F)), true(box(test(F2),F),K), true(F2,K).
% Maybe there is something missing here because implications in HT are different
true(box(test(F2),F),K) :- not true(F2,K), formula(del,box(test(F2),F)), time(K).
true(box(test(F2),F),K) :- true(F2,K), true(F,K), formula(del,box(test(F2),F)).


% box choice
true(box(P1,F),K) :- true(box(choice(P1,P2),F),K).
true(box(P2,F),K) :- true(box(choice(P1,P2),F),K).
true(box(choice(P1,P2),F),K) :- true(box(P1,F),K), true(box(P2,F),K), formula(del,box(choice(P1,P2),F)).

% box star
true(F,K):-  true(box(star(P),F),K).
true(box(P,box(star(P),F)),K):-  true(box(star(P),F),K).
true(box(star(P),F),K):-  formula(del, box(star(P),F)), true(F,K), true(box(P,box(star(P),F)),K).


%% ------- Derived --------- %%


derive(dia(seq(P1,P2),F),dia(P1,dia(P2,F)),del) :- formula(del,dia(seq(P1,P2),F)).
derive(box(seq(P1,P2),F),box(P1,box(P2,F)),del) :- formula(del,box(seq(P1,P2),F)).

derive(box(A,F),box(seq(test(A),step),F),del) :- formula(del,box(A,F)),  formula(atom,A).
derive(dia(A,F),dia(seq(test(A),step),F),del) :- formula(del,dia(A,F)),  formula(atom,A).

