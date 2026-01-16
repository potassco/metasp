#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".

% __top/0
true(__top,K) :- formula(mel,__top), time(K).
% __bot/0
:- formula(mel,__bot), time(K), true(__bot,K).
%--------- initially
:- true(__initial,K), time(K), K!=0.
true(__initial,0).

%--------- finally
:- true(__final,K), time(K), K!=n.
true(__final,n).

%--------- Next
% ->
true(V,K+1) :- true(__next(I,V),K), time(K), K<n.
:- true(__next(_,_),K), time(K), K=n.
:- true(__next(I,_),K), outside(I,(K,K+1)), time(K), K<n.
% <-
true(__next(I,V),K) :-  true(V,K+1), not outside(I,(K,K+1)), time(K), K<n,
                      formula(mel,__next(I,V)).

% --------- Always
% ->
true(__always(I,V),K) :- witness(always(I,V),(K,J)) : time(J), K<=J;
                       formula(mel,always(I,V)), time(K).
witness(always(I,V),(K,J)) :- true(__always(I,V),K),
                              time(K), time(J), K<=J.
witness(always(I,V),(K,J)) :- outside(I,(K,J)), formula(mel,__always(I,V)),
                              time(K), time(J), K<=J.
witness(always(I,V),(K,J)) :- true(V,J), formula(mel,__always(I,V)),
                              time(K), time(J), K<=J.
true(V,J) :- witness(always(I,V),(K,J)), not outside(I,(K,J)),
             time(K), time(J), K<=J.

% --------- Eventually
witness(eventually(I,V),(K,J)): time(J), K<=J :- true(__eventually(I,V),K).
true(__eventually(I,V),K) :- witness(eventually(I,V),(K,J)),
                           time(K), time(J), K<=J.
                        :- witness(eventually(I,V),(K,J)), outside(I,(K,J)),
                           time(K), time(J), K<=J.
true(V,J):-witness(eventually(I,V),(K,J)),
           time(K), time(J), K<=J.
witness(eventually(I,V),(K,J)):- true(V,J), not outside(I,(K,J)), formula(mel,__eventually(I,V)),
                                 time(K), time(J), K<=J.


%================================================
% Time
%================================================

&sum{t(0)} = 0 :- time(0).

&sum{t(K) ; -t(K+1)} <= -1:- time(K), time(K+1).

%================================================
% Intervals
%================================================
i((M,N)) :- formula(mel, __eventually(__i(M,N),V)).
i((M,N)) :- formula(mel, __always(__i(M,N),V)).
i((M,N)) :- formula(mel, __next(__i(M,N),V)).

outside(__i(M,N),(K,K')):-
    i((M,N)), time(K), time(K'), K<=K', &sum{t(K); -t(K')} > -M.
outside(__i(M,N),(K,K')):-
    i((M,N)), time(K), time(K'), K<=K', &sum{t(K'); -t(K)} > N-1, N!=#sup.

#show witness/2.
#show outside/2.
