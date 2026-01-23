#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".

true(__initial,0) :- formula(mel,__initial).                                                %%#(\label{enc:satisfaction:mel:initial:one}#)
:- formula(mel,__initial), true(__initial,T), T!=0.                                         %%#(\label{enc:satisfaction:mel:initial:two}#)

true(F,T+1) : time(T+1) :- formula(mel,__next(I,F)), true(__next(I,F),T).                       %%#(\label{enc:satisfaction:mel:next:one}#)
:- true(__next(I,_),T), outside(I,(T,T+1)), time(T).
true(__next(I,F),T) :- formula(mel,__next(I,F)), true(F,T+1), time(T), not outside(I,(T,T+1)).  %%#(\label{enc:satisfaction:mel:next:two}#)

witness(eventually(I,F),(T,J)): time(J), T<=J :- true(__eventually(I,F),T).
true(__eventually(I,F),T) :- witness(eventually(I,F),(T,J)),
                           time(T), time(J), T<=J.
                         :- witness(eventually(I,F),(T,J)), outside(I,(T,J)),
                           time(T), time(J), T<=J.
true(F,J):-witness(eventually(I,F),(T,J)),
           time(T), time(J), T<=J.
witness(eventually(I,F),(T,J)):- formula(mel,__eventually(I,F)), true(F,J), not outside(I,(T,J)),
                                 time(T), time(J), T<=J.

:- true(__final,K), time(K), K!=n.
true(__final,n).

% __top/0
true(__top,K) :- formula(mel,__top), time(K).
% __bot/0
:- formula(mel,__bot), time(K), true(__bot,K).



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

