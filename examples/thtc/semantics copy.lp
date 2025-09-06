

% #include "metasp.meta-time.lp".
% #include "metasp.derived.lp".
% #include "metasp.formulas.lp".
% #include "metasp.show-time.lp".
% #include "metasp.reify-defined.lp".

% #const lambda= horizon+1.


% General equivalence
&sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
    -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)
    }=0 :-
            true(eq(X,Y),T),
            X = sum(
                mul(XD1,next(XN1,XA1)),
                mul(XD2,next(XN2,XA2))
            ),
            Y = sum(
                mul(YD1,next(YN1,YA1)),
                mul(YD2,next(YN2,YA2))
            ),
            TXN1=T+XN1, TXN2=T+XN2,
            TYN1=T+YN1, TYN2=T+YN2.


% ---- Assign
% &sum{var(XA1,T+XN1);
%     -YD1*var(YA1,T+YN1); -YD2*var(YA2,T+YN2)
%     }=0 :-
%             true(assign(X,Y),T),
%             X = next(XN1,XA1),
%             Y = sum(
%                 mul(YD1,next(YN1,YA1)),
%                 mul(YD2,next(YN2,YA2)),
%             ),
%             &def(var(YA1,T+YN1)),
%             &def(var(YA2,T+YN2)).


% Alternative mapping back to eq and we dont need the other side since assign is only in head
true(eq(sum(mul(1,X),mul(0,next(0,neutral))),Y)) :-
            true(assign(X,Y),T),
            X = next(XN1,XA1),
            Y = sum(
                mul(YD1,next(YN1,YA1)),
                mul(YD2,next(YN2,YA2))
            ),
            &df{var(YA1,TYN1)},
            &df{var(YA2,TYN2)},
            TYN1=T+YN1, TYN2=T+YN2.

% So that it can match the rules with formula((atom;simple_tel), A) as a condition where there is no number of next
formula(atom, neutral).
formula(simple_tel, next(A)):-formula(atom, A).
formula(thtc, eq(sum(mul(1,X),mul(0,next(0,neutral))),Y)):-formula(thtc_assign, assign(X,Y)).

% Other simplifications
derive(assign(A,X), assign(next(0,A),X),thtc_assign):-formula(atom, A), formula(thtc_assign, assign(A,X)).
% derive(assign(X,N), assign(X,sum(0,N)),thtc_assign):-formula(num, N), formula(thtc_assign, assign(X,N)).
% derive(assign(X,sum(Y, N)), assign(X,sum(Y, mul(N,neutral)),thtc_assign):- formula(num,N), formula(thtc_assign, assign(X,sum(Y, N))).


derive(eq(A,X),eq(sum(A,neutral),X),thtc):-formula((atom;simple_tel;num), A), formula(thtc,eq(A,X)).
derive(eq(X,A),eq(X,sum(A,neutral)),thtc):-formula((atom;simple_tel;num), A), formula(thtc,eq(X,A)).

% A <-> 1*A and next(A) <-> 1*next(A)
derive(eq(sum(A,Y),X),eq(sum(mul(1,A),Y),X),thtc):-formula((atom;simple_tel), A), formula(thtc,eq(sum(A,Y),X)).
derive(eq(sum(Y,A),X),eq(sum(Y,mul(1,A)),X),thtc):-formula((atom;simple_tel), A), formula(thtc,eq(sum(Y,A),X)).
derive(eq(X,sum(A,Y)),eq(X,sum(mul(1,A),Y)),thtc):-formula((atom;simple_tel), A), formula(thtc,eq(X,sum(A,Y))).
derive(eq(X,sum(Y,A)),eq(X,sum(Y,mul(1,A))),thtc):-formula((atom;simple_tel), A), formula(thtc,eq(X,sum(Y,A))).

derive(eq(sum(A,Y),X),eq(sum(mul(A,neutral),Y),X),thtc):-formula(num, A), formula(thtc,eq(sum(A,Y),X)).
derive(eq(sum(Y,A),X),eq(sum(Y,mul(A,neutral)),X),thtc):-formula(num, A), formula(thtc,eq(sum(Y,A),X)).
derive(eq(X,sum(A,Y)),eq(X,sum(mul(A,neutral),Y)),thtc):-formula(num, A), formula(thtc,eq(X,sum(A,Y))).
derive(eq(X,sum(Y,A)),eq(X,sum(Y,mul(A,neutral))),thtc):-formula(num, A), formula(thtc,eq(X,sum(Y,A))).

% A <-> next(A)
derive(eq(sum(mul(D,A),Y),X), eq(sum(mul(D,next(A)),Y),X),thtc):-formula(atom, A), formula(thtc,eq(sum(mul(D,A),Y),X)).
derive(eq(sum(Y,mul(D,A)),X), eq(sum(Y,mul(D,next(A))),X),thtc):-formula(atom, A), formula(thtc,eq(sum(Y,mul(D,A)),X)).
derive(eq(X,sum(mul(D,A),Y)), eq(X,sum(mul(D,next(A)),Y)),thtc):-formula(atom, A), formula(thtc,eq(X,sum(mul(D,A),Y))).
derive(eq(X,sum(Y,mul(D,A))), eq(X,sum(Y,mul(D,next(A)))),thtc):-formula(atom, A), formula(thtc,eq(X,sum(Y,mul(D,A)))).

% next(A) <-> next(0,A)
derive(eq(sum(mul(D,next(A)),Y),X), eq(sum(mul(D,next(0,A)),Y),X),thtc):-formula(atom, A), formula(thtc,eq(sum(mul(D,next(A)),Y),X)).
derive(eq(sum(Y,mul(D,next(A))),X), eq(sum(Y,mul(D,next(0,A))),X),thtc):-formula(atom, A), formula(thtc,eq(sum(Y,mul(D,next(A))),X)).
derive(eq(X,sum(mul(D,next(A)),Y)), eq(X,sum(mul(D,next(0,A)),Y)),thtc):-formula(atom, A), formula(thtc,eq(X,sum(mul(D,next(A)),Y))).
derive(eq(X,sum(Y,mul(D,next(A)))), eq(X,sum(Y,mul(D,next(0,A)))),thtc):-formula(atom, A), formula(thtc,eq(X,sum(Y,mul(D,next(A))))).



% Assign one to neutral
% Always neutral=1. to use in place of a 1
assign(next(0,neutral),sum(mul(1,next(0,neutral)),mul(0,next(1,neutral)))).

#show formula/2.
#show _assignment/2.
#show true/2.
% #show derive/3.

% derive(eq(sum(mul(1,next(s)),mul(0,next(0,neutral))),10),eq(sum(mul(1,next(0,s)),mul(0,next(0,neutral))),10),thtc)
% derive(eq(sum(mul(1,next(s)),mul(0,next(0,neutral))),10),eq(sum(mul(1,next(s)),mul(0,next(0,neutral))),sum(10,neutral)),thtc)
% true(initial,0) true(assign(next(s),10),0) formula(atom,neutral) formula(simple_tel,next(neutral)) formula(thtc_assign,assign(next(s),10))
% formula(tel,initial) formula(num,10) formula(thtc,eq(sum(mul(1,next(s)),mul(0,next(0,neutral))),10)) formula(simple_tel,next(s)) formula(tel,next(s)) formula(atom,s) derive(eq(sum(mul(1,next(s)),mul(0,next(0,neutral))),10),eq(sum(mul(1,next(0,s)),mul(0,next(0,neutral))),10),thtc) derive(eq(sum(mul(1,next(s)),mul(0,next(0,neutral))),10),eq(sum(mul(1,next(s)),mul(0,next(0,neutral))),sum(10,neutral)),thtc)
% % -------------------
% % Could generalize for like:
% interp(next(XN1,XA1),T,var(XA1,T+XN1)):- formula(simple_tel, next(XN1,XA1)), time(T).
% interp(prev(XN1,XA1),T,var(XA1,T-XN1)):- formula(simple_tel, prev(XN1,XA1)), time(T).

% &sum{XD1*XI1;  XD2*XI2;
%     -YD1*YI1; -YD2*YI2
%     }=0 :-
%             true(eq(X,Y),T),
%             X = sum(
%                 mul(XD1,X1),
%                 mul(XD2,X2),
%             ),
%             Y = sum(
%                 mul(YD1,Y1),
%                 mul(YD2,Y2),
%             ),
%             interp(X1,XI1), interp(X2,XI2),
%             interp(Y1,YI1), interp(Y2,YI2).

% % This might not be needed if we define prev as negative movement and the neutral we give semantics
% % -------------------
