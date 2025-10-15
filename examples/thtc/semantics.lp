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

