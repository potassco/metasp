% No needed since it includes the tel semantics

%# Operator for equivalence '='
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
% true(op(eq,sum(mul(1,next(1,a)),mul(0,next(0,_one))),sum(mul(1,next(0,a)),mul(0,next(0,_one)))),1).
% true(op(eq,sum(mul(1,next(1,a)),mul(0,next(0,_one))),sum(mul(1,next(0,a)),mul(0,next(0,_one)))),1)

true(op(eq,X,Y),T):-
        formula(thtc, op(eq,X,Y)),
        time(T),
        &sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
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
&sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
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
        &sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
            -YD1*var(YA1,TYN1); -YD2*var(YA2,TYN2)}!=0,
        X = sum(
            mul(XD1,next(XN1,XA1)),
            mul(XD2,next(XN2,XA2))
        ),
        Y = sum(
            mul(YD1,next(YN1,YA1)),
            mul(YD2,next(YN2,YA2))
        ),
        &df{var(XA1,TYN1)},%TODO check if this is right
        &df{var(XA2,TYN2)},%TODO check if this is right
        &df{var(YA1,TYN1)},%TODO check if this is right
        &df{var(YA2,TYN2)},%TODO check if this is right
        TXN1=T+XN1, TXN2=T+XN2,
        TYN1=T+YN1, TYN2=T+YN2.


%# Operator for lower than '<'
&sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
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
        &sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
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
&sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
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
        &sum{XD1*var(XA1,TXN1);  XD2*var(XA2,TXN2);
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
            &df{var(YA2,TYN2)}, %With defined body
            TYN1=T+YN1, TYN2=T+YN2.

% So that it can match the rules with formula((atom;simple_tel), A) as a condition where there is no number of next
formula(atom, _one).
&sum{var(_one,T)}=1:-time(T).

formula(simple_tel, next(A)):-formula(atom, A).
% formula(thtc, op(eq,sum(mul(1,X),mul(0,next(0,_one))),Y)):-formula(thtc, op(assign,X,Y)).

#show true/2.

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
