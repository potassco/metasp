#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".

%% ------- Fischer Ladner closure --------- %%
formula(del, &eventually(P,&eventually(&star(P),F))) :- formula(del, &eventually(&star(P),F)).
formula(del, &eventually(P1,F)) :- formula(del, &eventually(&choice(P1,P2),F)).
formula(del, &eventually(P2,F)) :- formula(del, &eventually(&choice(P1,P2),F)).
formula(del, &eventually(P1,&eventually(P2,F))) :- formula(del, &eventually(&seq(P1,P2),F)).
formula(del, &eventually(P2,F)) :- formula(del, &eventually(&seq(P1,P2),F)).

formula(del, &always(P,&always(&star(P),F))) :- formula(del, &always(&star(P),F)).
formula(del, &always(P1,F)) :- formula(del, &always(&choice(P1,P2),F)).
formula(del, &always(P2,F)) :- formula(del, &always(&choice(P1,P2),F)).
formula(del, &always(P1,&always(P2,F))) :- formula(del, &always(&seq(P1,P2),F)).
formula(del, &always(P2,F)) :- formula(del, &always(&seq(P1,P2),F)).


% &true/0
true(&true,K) :- formula(del,&true), time(K).
% &false/0
:- formula(del,&false), time(K), true(&false,K).

% dia &step
true(F,K+1): time(K+1) :- formula(del,&eventually(&step,F)), true(&eventually(&step,F),K).
true(&eventually(&step,F),K) :- true(F,K+1), formula(del,&eventually(&step,F)), time(K).

% dia &test
true(F,K) :- formula(del,&eventually(&test(F2),F)), true(&eventually(&test(F2),F),K).
true(F2,K) :- formula(del,&eventually(&test(F2),F)), true(&eventually(&test(F2),F),K).
true(&eventually(&test(F2),F),K) :- true(F,K),true(F2,K), formula(del,&eventually(&test(F2),F)).

% dia choice
true(&eventually(P1,F),K);true(&eventually(P2,F),K) :- true(&eventually(&choice(P1,P2),F),K).
true(&eventually(&choice(P1,P2),F),K) :- true(&eventually(P1,F),K), formula(del,&eventually(&choice(P1,P2),F)).
true(&eventually(&choice(P1,P2),F),K) :- true(&eventually(P2,F),K), formula(del,&eventually(&choice(P1,P2),F)).

% dia seq
true(&eventually(P1,&eventually(P2,F)),K) :- true(&eventually(&seq(P1,P2),F),K).
true(&eventually(&seq(P1,P2),F),K):- true(&eventually(P1,&eventually(P2,F)),K), formula(del, &eventually(&seq(P1,P2),F)).

% dia &star
true(F,K); true(&eventually(P,&eventually(&star(P),F)),K):-  true(&eventually(&star(P),F),K).
true(&eventually(&star(P),F),K):-  formula(del, &eventually(&star(P),F)), true(F,K).
true(&eventually(&star(P),F),K):-  formula(del, &eventually(&star(P),F)), true(&eventually(P,&eventually(&star(P),F)),K).

% box &step
true(F,K+1):- formula(del,&always(&step,F)), true(&always(&step,F),K), time(K+1).
true(&always(&step,F),K) :- true(F,K+1), formula(del,&always(&step,F)), time(K).
true(&always(&step,F),K) :- formula(del,&always(&step,F)), time(K), not time(K+1).

% box &test
true(F,K) :- formula(del,&always(&test(F2),F)), true(&always(&test(F2),F),K), true(F2,K).
% Maybe there is something missing here because implications in HT are different
true(&always(&test(F2),F),K) :- not true(F2,K), formula(del,&always(&test(F2),F)), time(K).
true(&always(&test(F2),F),K) :- true(F2,K), true(F,K), formula(del,&always(&test(F2),F)).


% box choice
true(&always(P1,F),K) :- true(&always(&choice(P1,P2),F),K).
true(&always(P2,F),K) :- true(&always(&choice(P1,P2),F),K).
true(&always(&choice(P1,P2),F),K) :- true(&always(P1,F),K), true(&always(P2,F),K), formula(del,&always(&choice(P1,P2),F)).


% box seq
true(&always(P1,&always(P2,F)),K) :- true(&always(&seq(P1,P2),F),K).
true(&always(&seq(P1,P2),F),K):- true(&always(P1,&always(P2,F)),K), formula(del, &always(&seq(P1,P2),F)).

% box &star
true(F,K):-  true(&always(&star(P),F),K).
true(&always(P,&always(&star(P),F)),K):-  true(&always(&star(P),F),K).
true(&always(&star(P),F),K):-  formula(del, &always(&star(P),F)), true(F,K), true(&always(P,&always(&star(P),F)),K).


