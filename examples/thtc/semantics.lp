%## Included standard encodings
#include "metasp.meta-time.lp".
#include "metasp.show-time.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".

%### `&initial`
true(&initial,0) :- formula(tel,&initial).
:- formula(tel,&initial), true(&initial,K), K!=0.

%### `&final`
true(&final,n) :- formula(tel,&final).
:- formula(tel,&final), true(&final,K), K!=n.
% next_N1(V1) := D2*next_N2(V2) + D3*next_N3(V3)

%### `&next_tel`
true(F,K+1) : time(K+1) :- formula(tel,&next_tel(F)), true(&next_tel(F),K).
true(&next_tel(F),K) :- formula(tel,&next_tel(F)), true(F,K+1), time(K).

&sum{D2*var(V2,KN2);D3*var(V3,KN3)}=var(V1,KN1):-
        KN1 = K+N1, %Can't put the arithmetic on the head
        KN2 = K+N2,
        KN3 = K+N3,
        formula(thtc_assign,&assign(X1,X2)), time(K),
        &df{var(V2,KN2)},
        &df{var(V3,KN3)},
        true(&assign(X1,X2),K),
        X1 = &times_next(D1,N1,V1),
        X2 = &add(&times_next(D2,N2,V2),&times_next(D3,N3,V3)).

% formula(thtc_assign,&assign(&times_next(1,0,z),&add(&times_next(0,0,_one),&times_next(10,0,_one)))).


% sum(var(V11,K+N11),D12,var(V12,K+N12),
%                 -D21,var(V21,K+N21), -D22,var(V22,K+N22)):-
% true(&lt(X1,X2),K):-
%         formula(thtc,&lt(X1,X2)), time(K),
%         &sum{D11*var(V11,K+N11);D12*var(V12,K+N12);
%                 -D21*var(V21,K+N21); -D22*var(V22,K+N22)}<0,
%         X1 = &add(&times_next(D11,N11,V11),&times_next(D12,N12,V12)),
%         X2 = &add(&times_next(D21,N21,V21),&times_next(D22,N22,V22)).

% &show {var(A,K):formula(atom, A), time(K)}.

% #show true/2.

true(&lt(X1,X2),K):-
        formula(thtc,&lt(X1,X2)), time(K),
        KN11 = K+N11,
        KN12 = K+N12,
        KN21 = K+N21,
        KN22 = K+N22,
        &sus{D11*var(V11,KN11);D12*var(V12,KN12);
                -D21*var(V21,KN21); -D22*var(V22,KN22)}<0,
        X1 = &add(&times_next(D11,N11,V11),&times_next(D12,N12,V12)),
        X2 = &add(&times_next(D21,N21,V21),&times_next(D22,N22,V22)).


true(&neq(X1,X2),K):-
        formula(thtc,&neq(X1,X2)), time(K),
        KN11 = K+N11,
        KN12 = K+N12,
        KN21 = K+N21,
        KN22 = K+N22,
        &sus{D11*var(V11,KN11);D12*var(V12,KN12);
                -D21*var(V21,KN21); -D22*var(V22,KN22)}!=0,
        X1 = &add(&times_next(D11,N11,V11),&times_next(D12,N12,V12)),
        X2 = &add(&times_next(D21,N21,V21),&times_next(D22,N22,V22)).


% true(&leq(X1,X2),K):-
%         formula(thtc,&leq(X1,X2)), time(K),
%         KN11 = K+N11,
%         KN12 = K+N12,
%         KN21 = K+N21,
%         KN22 = K+N22,
%         &sum{D11*var(V11,KN11);D12*var(V12,KN12);
%                 -D21*var(V21,KN21); -D22*var(V22,KN22)}<=0,
%         &df{var(V11,KN11)},
%         &df{var(V12,KN12)},
%         &df{var(V21,KN21)},
%         &df{var(V22,KN22)},
%         X1 = &add(&times_next(D11,N11,V11),&times_next(D12,N12,V12)),
%         X2 = &add(&times_next(D21,N21,V21),&times_next(D22,N22,V22)).


% hi.

&sum{var(_one,T)}=1:-time(T).

% #show val/2.
% #show test/5.
% #show sum/6.
