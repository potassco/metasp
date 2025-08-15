#include "metasp.meta-time.lp".
#include "metasp.formulas.lp".
#include "metasp.show.lp".
#include "metasp.derived.lp".

#const lambda= horizon+1.


%================================================
% Bounded translation
%================================================
%--------- initially
:- true(initial,K), time(K), K!=0.
true(initial,0).

%--------- finally
:- true(final,K), time(K), K!=lambda-1.
true(final,lambda-1).

%--------- Next
% ->
true(V,K+1) :- true(next(I,V),K), time(K), K<lambda-1.
:- true(next(_,_),K), time(K), K=lambda-1.
:- true(next(I,_),K), outside(I,(K,K+1)), time(K), K<lambda-1.
% <-
true(next(I,V),K) :-  true(V,K+1), not outside(I,(K,K+1)), time(K), K<lambda-1,
                      formula(mel,next(I,V)).

% --------- Always
% ->
true(always(I,V),K) :- witness(always(I,V),(K,J)) : time(J), K<=J;
                       formula(mel,always(I,V)), time(K).
witness(always(I,V),(K,J)) :- true(always(I,V),K),
                              time(K), time(J), K<=J.
witness(always(I,V),(K,J)) :- outside(I,(K,J)), formula(mel,always(I,V)),
                              time(K), time(J), K<=J.
witness(always(I,V),(K,J)) :- true(V,J), formula(mel,always(I,V)),
                              time(K), time(J), K<=J.
true(V,J) :- witness(always(I,V),(K,J)), not outside(I,(K,J)),
             time(K), time(J), K<=J.

% --------- Eventually
witness(eventually(I,V),(K,J)): time(J), K<=J :- true(eventually(I,V),K).
true(eventually(I,V),K) :- witness(eventually(I,V),(K,J)),
                           time(K), time(J), K<=J.
                        :- witness(eventually(I,V),(K,J)), outside(I,(K,J)),
                           time(K), time(J), K<=J.
true(V,J):-witness(eventually(I,V),(K,J)),
           time(K), time(J), K<=J.
witness(eventually(I,V),(K,J)):- true(V,J), not outside(I,(K,J)), formula(mel,eventually(I,V)),
                                 time(K), time(J), K<=J.


%================================================
% Time
%================================================

&sum{t(0)} = 0 :- time(0).

&sum{t(K) ; -t(K+1)} <= -1:- time(K), time(K+1).

%================================================
% Intervals
%================================================
i(I) :- formula(mel, eventually(I,V)).
i(I) :- formula(mel, always(I,V)).
i(I) :- formula(mel, next(I,V)).

outside((M,N),(K,K')):-
    i((M,N)), time(K), time(K'), K<=K', &sum{t(K); -t(K')} > -M.
outside((M,N),(K,K')):-
    i((M,N)), time(K), time(K'), K<=K', &sum{t(K'); -t(K)} > N-1, N!=w.
