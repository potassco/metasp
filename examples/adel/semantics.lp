#include "metasp.meta-ht-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".

% We have this condition because actions are atoms and then externals are generated for them
% Due to these externals we have actions also as fluents.
fluent(F):- formula(fluent, F), not action(F).
action(A):- formula(action_definition, &action(A)).

{label(A,(T,T+1))}:-action(A),time(T), time(T+1).

% ------------------------------
% ## Path relation || p ||

% ### Base case for actions
rel(A,M,I) :- action(A), label(A, I), model(M).

% ### Action Formulas
% rel(A, I) :- formula(path, A), formula(aformula, A), rel(A, I).
rel(&aand(A,B),M, I) :- formula(aformula, &aand(A,B)), rel(A, M, I), rel(B, M, I).
rel(&atrue,M, (T,T+1)) :- formula(aformula, &atrue), time(T), time(T+1), model(M).
rel(&aneg(A),M, (T,T+1)) :- formula(aformula, &aneg(A)), time(T), time(T+1), model(M), not rel(A, M, (T,T+1)).

% ### Path Formulas
rel(&test(A),M,(T,T)) :- formula(path, &test(A)), time(T), model(M), true(A, M, T).
rel(&choice(A,B),M, I) :- formula(path, &choice(A,B)), rel(A, M, I).
rel(&choice(A,B),M, I) :- formula(path, &choice(A,B)), rel(B, M, I).
rel(&seq(A,B),M,(T1,T3)) :- formula(path, &seq(A,B)), rel(A, M, (T1,T2)), rel(B, M, (T2,T3)).

% star identity
rel(&star(A),M,(T,T)) :- formula(path, &star(A)), time(T), model(M).
% 1 repetition
rel(&star(A),M,(T1,T2)) :- formula(path, &star(A)), rel(A, M, (T1,T2)).
% + repetitions
rel(&star(A),M,(T1,T3)) :- formula(path, &star(A)), rel(&star(A), M, (T1,T2)), rel(A, M, (T2,T3)).

rel(&conv(P),M, (T2,T1)) :- formula(path, &conv(P)), rel(P, M, (T1,T2)).


% ------------------------------
% ## Formulas

% Atoms if atom in H??

% False
:- formula(adel,&false), true(&false, M, T), time(T), model(M).

% Negation
% Why not use it as a derived operator with the alwys?
:- formula(adel,&not(F)), true(&not(F), M, T), true(F, M, T), time(T), model(M).
true(&not(F), M, T) :- formula(adel,&not(F)), not true(F, M, T), time(T), model(M).

% ## Eventually

true(&eventually(P,F), M, TI) :- formula(adel, &eventually(P,F)), time(TI),
                                 rel(P, M, (TI,TJ)), true(F, M, TJ).
% How do we the the other side? This is not explicit
true(F, M, TJ):rel(P, M, (TI,TJ)):- true(&eventually(P,F), M, TI).

% ## Always

true(&always(P,F), M, TI) :- formula(adel, &always(P,F)), time(TI), model(M),
                             true(F, t, TJ): rel(P, t, (TI,TJ)); %in both H and T
                             true(F, M, TJ): rel(P, M, (TI,TJ)). %in both H and T
% How do we the the other side? This is not explicit
true(F, t, TJ) :- true(&always(P,F), t, TI), rel(P, t, (TI,TJ)), rel(P, h, (TI,TJ)).
true(F, h, TJ) :- true(&always(P,F), h, TI), rel(P, t, (TI,TJ)), rel(P, h, (TI,TJ)).

:- true(L,h,T), not true(L,t,T), time(T).


#show action/1.
#show fluent/1.
#show label/2.
% #show rel/3.
% #show true/3.



% --------- SHOW

% Handles show statements with time steps

% Hides all to only consider the things that should be shown
#show .

show(S,B) :- show_term(S,B).
show(S,B) :- show_atom(S,B).

% Show all things if the condition is satisfied
% #show ht_true(S,M,T) : show(S,B), conjunction(B,M,T).
% By default only atoms are shown unless #show. is present or #show p/N. is used for some predicate p/N.
% #show ht_true(S,M,T) : output(S,B), conjunction(B,M,T), formula(atom,S), not show_atom(_,_), not show.


% Show all things if the condition is satisfied
#show true(S,T) : show(S,B), conjunction(B,h,T), conjunction(B,t,T).
% By default only atoms are shown unless #show. is present or #show p/N. is used for some predicate p/N.
#show true(S,T) : output(S,B), conjunction(B,h,T), conjunction(B,t,T), fluent(S), not show_atom(_,_), not show.


_log(error, "True in H but not in T"):- true(F, h, T), not true(F, t, T).
_log(error, "True in T but not in H"):- true(F, t, T), not true(F, h, T).
% _log(error, arity("Wrong arity", rel(A,B))):- rel(A,B).
% _log(error, arity("Wrong arity", true(A,B))):- true(A,B).
