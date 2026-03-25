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


true(&always(I,F),T) :- witness(&always(I,F),(T,J)) : time(J), T<=J;
                       formula(mel, &always(I,F)), time(T).
witness(&always(I,F),(T,J)) :- true(&always(I,F),T),
                              time(T), time(J), T<=J.
witness(&always(I,F),(T,J)) :- outside(I,(T,J)), formula(mel, &always(I,F)),
                              time(T), time(J), T<=J.
witness(&always(I,F),(T,J)) :- true(F,J), formula(mel, &always(I,F)),
                              time(T), time(J), T<=J.
true(F,J) :- witness(&always(I,F),(T,J)), not outside(I,(T,J)),
             time(T), time(J), T<=J.



:- true(&final,T), time(T), T!=n.
true(&final,n).

% &true/0
true(&true,T) :- formula(mel,&true), time(T).
% &false/0
:- formula(mel,&false), time(T), true(&false,T).



%================================================
% Time
%================================================

&sum{t(0)} = 0 :- time(0).

&sum{t(T) ; -t(T+1)} <= -1:- time(T), time(T+1).

%================================================
% Intervals
%================================================
i((M,N)) :- formula(mel, &eventually(&i(M,N),V)).
i((M,N)) :- formula(mel, &always(&i(M,N),V)).
i((M,N)) :- formula(mel, &next(&i(M,N),V)).

outside(&i(M,N),(T,T')):-
    i((M,N)), time(T), time(T'), T<=T', &sum{t(T); -t(T')} > -M.
outside(&i(M,N),(T,T')):-
    i((M,N)), time(T), time(T'), T<=T', &sum{t(T'); -t(T)} > N-1, N!=#sup.

