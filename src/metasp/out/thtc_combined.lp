

%%%%%% File: ./thtc/semantics.lp %%%%%%



% #include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/meta-time.lp".
% #include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/derived.lp".
% #include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/formulas.lp".
% #include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/show-time.lp".
% #include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/reify-defined.lp".

% #const lambda= horizon+1.


% General equivalence
&sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
    -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)
    }=0 :-
            true(op(eq,X,Y),T),
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
% true(op(eq,sum(mul(1,X),mul(0,next(0,_one)))),Y) :-
%             true(op(assign,X,Y),T),
%             X = sum(mul(1,next(XN1,XA1)),mul(0,next(0,_one))),
%             Y = sum(
%                 mul(YD1,next(YN1,YA1)),
%                 mul(YD2,next(YN2,YA2))
%             ),
%             &df{var(YA1,TYN1)},
%             &df{var(YA2,TYN2)},
%             TYN1=T+YN1, TYN2=T+YN2.


hi :-
            true(op(assign,X,Y),T),
            X = sum(mul(1,next(XN1,XA1)),mul(0,next(0,_one))),
            Y = sum(
                mul(YD1,next(YN1,YA1)),
                mul(YD2,next(YN2,YA2))
            ),
            % &df{var(YA1,TYN1)},
            % &df{var(YA2,TYN2)},
            &df{var(YA2,TYN2)},
            TYN1=T+YN1, TYN2=T+YN2.
% true(op(assign,
%     sum(mul(1,next(0,s)),mul(0,next(0,_one))),
%     sum(mul(10,next(0,_one)),mul(0,next(0,_one)))),0)

% So that it can match the rules with formula((atom;simple_tel), A) as a condition where there is no number of next
formula(atom, _one).
formula(simple_tel, next(A)):-formula(atom, A).
% formula(thtc, op(eq,sum(mul(1,X),mul(0,next(0,_one))),Y)):-formula(thtc, op(assign,X,Y)).


derive(eq(X,Y),op(eq,X,Y),thtc):-formula(thtc, eq(X,Y)).
derive(assign(X,Y),op(assign,X,Y),thtc):-formula(thtc_assign, assign(X,Y)).

% Other simplifications
% derive(assign(A,X), assign(next(0,A),X),thtc_assign):-formula(atom, A), formula(thtc_assign, assign(A,X)).
% derive(assign(X,N), assign(X,sum(0,N)),thtc_assign):-formula(num, N), formula(thtc_assign, assign(X,N)).
% derive(assign(X,sum(Y, N)), assign(X,sum(Y, mul(N,_one)),thtc_assign):- formula(num,N), formula(thtc_assign, assign(X,sum(Y, N))).


derive(op(O,A,X),op(O,sum(A,0),X),thtc):-formula((atom;simple_tel;num), A), formula(thtc,op(O,A,X)).
derive(op(O,X,A),op(O,X,sum(A,0)),thtc):-formula((atom;simple_tel;num), A), formula(thtc,op(O,X,A)).

% A <-> 1*A and next(A) <-> 1*next(A)
derive(op(O,sum(A,Y),X),op(O,sum(mul(1,A),Y),X),thtc):-formula((atom;simple_tel), A), formula(thtc,op(O,sum(A,Y),X)).
derive(op(O,sum(Y,A),X),op(O,sum(Y,mul(1,A)),X),thtc):-formula((atom;simple_tel), A), formula(thtc,op(O,sum(Y,A),X)).
derive(op(O,X,sum(A,Y)),op(O,X,sum(mul(1,A),Y)),thtc):-formula((atom;simple_tel), A), formula(thtc,op(O,X,sum(A,Y))).
derive(op(O,X,sum(Y,A)),op(O,X,sum(Y,mul(1,A))),thtc):-formula((atom;simple_tel), A), formula(thtc,op(O,X,sum(Y,A))).

derive(op(O,sum(A,Y),X),op(O,sum(mul(A,_one),Y),X),thtc):-formula(num, A), formula(thtc,op(O,sum(A,Y),X)).
derive(op(O,sum(Y,A),X),op(O,sum(Y,mul(A,_one)),X),thtc):-formula(num, A), formula(thtc,op(O,sum(Y,A),X)).
derive(op(O,X,sum(A,Y)),op(O,X,sum(mul(A,_one),Y)),thtc):-formula(num, A), formula(thtc,op(O,X,sum(A,Y))).
derive(op(O,X,sum(Y,A)),op(O,X,sum(Y,mul(A,_one))),thtc):-formula(num, A), formula(thtc,op(O,X,sum(Y,A))).

% A <-> next(A)
derive(op(O,sum(mul(D,A),Y),X), op(O,sum(mul(D,next(A)),Y),X),thtc):-formula(atom, A), formula(thtc,op(O,sum(mul(D,A),Y),X)).
derive(op(O,sum(Y,mul(D,A)),X), op(O,sum(Y,mul(D,next(A))),X),thtc):-formula(atom, A), formula(thtc,op(O,sum(Y,mul(D,A)),X)).
derive(op(O,X,sum(mul(D,A),Y)), op(O,X,sum(mul(D,next(A)),Y)),thtc):-formula(atom, A), formula(thtc,op(O,X,sum(mul(D,A),Y))).
derive(op(O,X,sum(Y,mul(D,A))), op(O,X,sum(Y,mul(D,next(A)))),thtc):-formula(atom, A), formula(thtc,op(O,X,sum(Y,mul(D,A)))).

% next(A) <-> next(0,A)
derive(op(O,sum(mul(D,next(A)),Y),X), op(O,sum(mul(D,next(1,A)),Y),X),thtc):-formula(atom, A), formula(thtc,op(O,sum(mul(D,next(A)),Y),X)).
derive(op(O,sum(Y,mul(D,next(A))),X), op(O,sum(Y,mul(D,next(1,A))),X),thtc):-formula(atom, A), formula(thtc,op(O,sum(Y,mul(D,next(A))),X)).
derive(op(O,X,sum(mul(D,next(A)),Y)), op(O,X,sum(mul(D,next(1,A)),Y)),thtc):-formula(atom, A), formula(thtc,op(O,X,sum(mul(D,next(A)),Y))).
derive(op(O,X,sum(Y,mul(D,next(A)))), op(O,X,sum(Y,mul(D,next(1,A)))),thtc):-formula(atom, A), formula(thtc,op(O,X,sum(Y,mul(D,next(A))))).


&sum{var(_one,T)}=1:-time(T).



% Assign one to _one
% Always _one=1. to use in place of a 1
% assign(next(0,_one),sum(mul(1,next(0,_one)),mul(0,next(1,_one)))).

% #show formula/2.
% #show _assignment/2.
% #show true/2.
% #show derive/3.

% derive(eq(sum(mul(1,next(s)),mul(0,next(0,_one))),10),eq(sum(mul(1,next(0,s)),mul(0,next(0,_one))),10),thtc)
% derive(eq(sum(mul(1,next(s)),mul(0,next(0,_one))),10),eq(sum(mul(1,next(s)),mul(0,next(0,_one))),sum(10,_one)),thtc)
% true(initial,0) true(assign(next(s),10),0) formula(atom,_one) formula(simple_tel,next(_one)) formula(thtc_assign,assign(next(s),10))
% formula(tel,initial) formula(num,10) formula(thtc,eq(sum(mul(1,next(s)),mul(0,next(0,_one))),10)) formula(simple_tel,next(s)) formula(tel,next(s)) formula(atom,s) derive(eq(sum(mul(1,next(s)),mul(0,next(0,_one))),10),eq(sum(mul(1,next(0,s)),mul(0,next(0,_one))),10),thtc) derive(eq(sum(mul(1,next(s)),mul(0,next(0,_one))),10),eq(sum(mul(1,next(s)),mul(0,next(0,_one))),sum(10,_one)),thtc)
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

% % This might not be needed if we define prev as negative movement and the _one we give semantics
% % -------------------



%%%%%% File: ./telingo/semantics.lp %%%%%%

#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/meta-time.lp".
#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/derived.lp".
#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/formulas.lp".
#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/show-time.lp".
#include "/Users/susana/Documents/Education/PhD/Potassco/metasp/src/metasp/encodings/reify-defined.lp".

#const lambda= horizon+1.
world(W):-time(W).

% true/0
true(true,K) :- formula(tel,true), time(K).
% false/0
:- formula(tel,false), time(K), true(false,K).

% and/2
true(and(F,G),K) :- formula(tel,and(F,G)), true(F,K), true(G,K).
true((F;G),K) :- formula(tel,and(F,G)), true(and(F,G),K).

% or/2
true(or(F,G),K) :- formula(tel,or(F,G)), true((F;G),K).
true(F,K);true(G,K) :- formula(tel,or(F,G)), true(or(F,G),K).

% neg/1 (default negation)
true(neg(F),K) :- formula(tel,neg(F)), time(K), not true(F,K).
not true(F,K) :- formula(tel,neg(F)), true(neg(F),K).

% initial/0
true(initial,0) :- formula(tel,initial).
:- true(initial,K), formula(tel,initial), K!=0.

% final/0.
true(final,lambda-1) :- formula(tel,final).
:- true(final,K), formula(tel,final), K!=lambda-1.

% next/1
true(F,K+1): time(K+1) :- formula(tel,next(F)), true(next(F),K).
true(next(F),K) :- true(F,K+1), formula(tel,next(F)), time(K).

% until/2
true(until_then(L,R,J),K): K<=J, time(J)
  :- formula(tel,until(L,R)), true(until(L,R),K), time(K).
true(until(L,R),K)
  :- formula(tel,until(L,R)), true(until_then(L,R,_),K).

true(L,I) :- true(until_then(L,R,J),K), I=K..J-1.
true(R,J) :- true(until_then(L,R,J),K).
true(until_then(L,R,J),K)
  :- formula(tel,until(L,R)), time(K), time(J), K<=J, true(R,J),
     true(L,I) : I=K..J-1.

%--------- Derived

derive(wnext(F),or(next(F),final),tel) :- formula(tel,wnext(F)).
% wprev/1
derive(wprev(F),or(prev(F),initial),tel) :- formula(tel,wprev(F)).
% eventually_after/1
derive(eventually(F),until(true,F),tel) :- formula(tel,eventually(F)).
% always/1
derive(always(F),release(false,F),tel) :- formula(tel,always(F)).
% release/2
derive(release(L,R),until(R,and(R,or(L,final))),tel) :- formula(tel,release(L,R)).



%%%%%% Reified Input %%%%%%

tag(incremental).
atom_tuple(0).
atom_tuple(0,1).
literal_tuple(0).
rule(disjunction(0),normal(0)).
external(2,false).
external(3,false).
atom_tuple(1).
atom_tuple(1,4).
literal_tuple(1).
literal_tuple(1,3).
rule(disjunction(1),normal(1)).
atom_tuple(2).
atom_tuple(2,5).
rule(disjunction(2),normal(1)).
output(initial,1).
output(eq(b,s),0).
literal_tuple(2).
literal_tuple(2,2).
output(eq(b,0),2).
literal_tuple(3).
literal_tuple(3,4).
output(eq(next(3,s),99),3).
literal_tuple(4).
literal_tuple(4,5).
output(eq(next(s),10),4).