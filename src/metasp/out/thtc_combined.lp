

%%%%%% File: ./thtc/semantics.lp %%%%%%

% No needed since it includes the tel semantics

%# Operator for equivalence '='
&sus{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
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
% true(op(eq,sum(mul(1,next(1,a)),mul(0,next(0,_one))),sum(mul(1,next(0,a)),mul(0,next(0,_one)))),1).
% true(op(eq,sum(mul(1,next(1,a)),mul(0,next(0,_one))),sum(mul(1,next(0,a)),mul(0,next(0,_one)))),1)

true(op(eq,X,Y),T):-
        formula(thtc, op(eq,X,Y)),
        time(T),
        &sus{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
            -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)}=0,
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


%# Operator for difference '!='
&sus{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
    -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)
    }!=0 :-
            true(op(neq,X,Y),T),
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

true(op(neq,X,Y),T):-
        formula(thtc, op(neq,X,Y)),
        time(T),
        &sus{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
            -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)}!=0,
        X = sum(
            mul(XD1,next(XN1,XA1)),
            mul(XD2,next(XN2,XA2))
        ),
        Y = sum(
            mul(YD1,next(YN1,YA1)),
            mul(YD2,next(YN2,YA2))
        ),
        % &df{var(XA1,TXN1)},%TODO check if this is right
        % &df{var(XA2,TXN2)},%TODO check if this is right
        % &df{var(YA1,TYN1)},%TODO check if this is right
        % &df{var(YA2,TYN2)},%TODO check if this is right
        TXN1=T+XN1, TXN2=T+XN2,
        TYN1=T+YN1, TYN2=T+YN2.


%# Operator for lower than '<'
&sus{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
    -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)
    }<0 :-
            true(op(lt,X,Y),T),
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

true(op(lt,X,Y),T):-
        formula(thtc, op(lt,X,Y)),
        time(T),
        &sus{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
            -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)}<0,
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


%# Operator for lower or equal than '<='
&sus{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
    -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)
    }<=0 :-
            true(op(leq,X,Y),T),
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

true(op(leq,X,Y),T):-
        formula(thtc, op(leq,X,Y)),
        time(T),
        &sus{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
            -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)}<=0,
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

% Other side not needed since assign is only in the head
true(op(eq,X,Y),T):-
            true(op(assign,X,Y),T), % Assign operation is true
            X = sum(mul(1,next(XN1,XA1)),mul(0,next(0,_one))),
            Y = sum(
                mul(YD1,next(YN1,YA1)),
                mul(YD2,next(YN2,YA2))
            ),
            &df{var(YA1,TYN1)}, %With defined body
            % &sus{var(YA1,TYN1)}=var(YA1,TYN1), %With defined body
            &df{var(YA2,TYN2)}, %With defined body
            % &sus{var(YA2,TYN2)}=var(YA2,TYN2), %With defined body
            TYN1=T+YN1, TYN2=T+YN2.

% So that it can match the rules with formula((atom;simple_tel), A) as a condition where there is no number of next
formula(atom, _one).
&sus{var(_one,T)}=1:-time(T).

formula(simple_tel, next(A)):-formula(atom, A).
% formula(thtc, op(eq,sum(mul(1,X),mul(0,next(0,_one))),Y)):-formula(thtc, op(assign,X,Y)).

% #show true/2.

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

% &sus{XD1*XI1;  XD2*XI2;
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





% ---- Assign
% &sus{var(XA1,T+XN1);
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
atom_tuple(1).
atom_tuple(1,2).
rule(disjunction(1),normal(0)).
atom_tuple(2).
atom_tuple(2,3).
rule(disjunction(2),normal(0)).
atom_tuple(3).
atom_tuple(3,4).
rule(disjunction(3),normal(0)).
external(5,false).
external(6,false).
external(7,false).
external(8,false).
external(9,false).
external(10,false).
external(11,false).
external(12,false).
atom_tuple(4).
atom_tuple(4,13).
literal_tuple(1).
literal_tuple(1,-11).
literal_tuple(1,5).
literal_tuple(1,6).
literal_tuple(1,7).
rule(disjunction(4),normal(1)).
atom_tuple(5).
atom_tuple(5,14).
literal_tuple(2).
literal_tuple(2,-9).
rule(disjunction(5),normal(2)).
atom_tuple(6).
atom_tuple(6,15).
literal_tuple(3).
literal_tuple(3,12).
rule(disjunction(6),normal(3)).
atom_tuple(7).
atom_tuple(7,16).
rule(disjunction(7),normal(3)).
atom_tuple(8).
atom_tuple(8,17).
rule(disjunction(8),normal(3)).
atom_tuple(9).
atom_tuple(9,18).
rule(disjunction(9),normal(3)).
output(initial,3).
output(assign(next(s),sum(s,acc)),0).
output(assign(next(p),sum(p,s)),0).
output(assign(rdlimit,9000),0).
output(assign(rdpos,40000),0).
literal_tuple(4).
literal_tuple(4,14).
output(assign(next(s),s),4).
literal_tuple(5).
literal_tuple(5,15).
output(assign(s,8000),5).
literal_tuple(6).
literal_tuple(6,16).
output(assign(p,0),6).
literal_tuple(7).
literal_tuple(7,17).
output(assign(next(6,acc),-230),7).
literal_tuple(8).
literal_tuple(8,18).
output(assign(next(4,acc),1135),8).
literal_tuple(9).
literal_tuple(9,8).
output(neq(acc,0),9).
literal_tuple(10).
literal_tuple(10,9).
output(neq(next(s),s),10).
literal_tuple(11).
literal_tuple(11,11).
output(final,11).
literal_tuple(12).
literal_tuple(12,5).
output(lt(rdlimit,next(s)),12).
literal_tuple(13).
literal_tuple(13,7).
output(lt(p,rdpos),13).
literal_tuple(14).
literal_tuple(14,6).
output(leq(rdpos,next(p)),14).
literal_tuple(15).
literal_tuple(15,13).
output(next(fine),15).
literal_tuple(16).
literal_tuple(16,10).
output(not_yet,16).