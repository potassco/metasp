#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".

true(&initial,0) :- formula(mel,&initial).                                                %%#(\label{enc:satisfaction:mel:initial:one}#)
:- formula(mel,&initial), true(&initial,T), T!=0.                                         %%#(\label{enc:satisfaction:mel:initial:two}#)

true(F,T+1) : time(T+1) :- formula(mel,&next(I,F)), true(&next(I,F),T).                       %%#(\label{enc:satisfaction:mel:next:one}#)
:- true(&next(I,_),T), outside(I,(T,T+1)), time(T).
true(&next(I,F),T) :- formula(mel,&next(I,F)), true(F,T+1), time(T), not outside(I,(T,T+1)).  %%#(\label{enc:satisfaction:mel:next:two}#)

witness(eventually(I,F),(T,J)): time(J), T<=J :- true(&eventually(I,F),T).
true(&eventually(I,F),T) :- witness(eventually(I,F),(T,J)),
                           time(T), time(J), T<=J.
                         :- witness(eventually(I,F),(T,J)), outside(I,(T,J)),
                           time(T), time(J), T<=J.
true(F,J):-witness(eventually(I,F),(T,J)),
           time(T), time(J), T<=J.
witness(eventually(I,F),(T,J)):- formula(mel,&eventually(I,F)), true(F,J), not outside(I,(T,J)),
                                 time(T), time(J), T<=J.

:- true(&final,K), time(K), K!=n.
true(&final,n).

% &top/0
true(&top,K) :- formula(mel,&top), time(K).
% &bot/0
:- formula(mel,&bot), time(K), true(&bot,K).



%================================================
% Time
%================================================

&sum{t(0)} = 0 :- time(0).

&sum{t(K) ; -t(K+1)} <= -1:- time(K), time(K+1).

%================================================
% Intervals
%================================================
i((M,N)) :- formula(mel, &eventually(&i(M,N),V)).
i((M,N)) :- formula(mel, &always(&i(M,N),V)).
i((M,N)) :- formula(mel, &next(&i(M,N),V)).

outside(&i(M,N),(K,K')):-
    i((M,N)), time(K), time(K'), K<=K', &sum{t(K); -t(K')} > -M.
outside(&i(M,N),(K,K')):-
    i((M,N)), time(K), time(K'), K<=K', &sum{t(K'); -t(K)} > N-1, N!=#sup.

