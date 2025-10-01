
type(thtc). type(thtc_assign).type(linear_temp_cons_atom). type(m). type(simple_tel).

% Used to limit the constructor below
type(operator_name).
constructor(operator_name, (eq;assign;neq;lt;leq), 0, ()).


constructor(thtc, op, 3, (operator_name,linear_temp_cons_atom,linear_temp_cons_atom)).
constructor(thtc, (eq;neq;lt;leq), 2, (linear_temp_cons_atom,linear_temp_cons_atom)).
constructor(thtc_assign, assign, 2, (linear_temp_cons_atom,linear_temp_cons_atom)).

constructor(linear_temp_cons_atom, sum, 2, (m,m)).
constructor(mul, mul, 2, (num,simple_tel)).
constructor(simple_tel, next, 2, (num,atom)).
constructor(simple_tel, next, 1, (atom,)).


allow(thtc, (body;head)).
allow(thtc_assign, head).

subtype(simple_tel,linear_temp_cons_atom).
subtype(simple_tel,m).
subtype(atom,simple_tel).


% -----------------------------
% Syntactic sugar
% -----------------------------

% From simpler syntax to generic operator
derive(eq(X,Y),op(eq,X,Y),thtc):-formula(thtc, eq(X,Y)).
derive(neq(X,Y),op(neq,X,Y),thtc):-formula(thtc, neq(X,Y)).
derive(leq(X,Y),op(leq,X,Y),thtc):-formula(thtc, leq(X,Y)).
derive(lt(X,Y),op(lt,X,Y),thtc):-formula(thtc, lt(X,Y)).
derive(assign(X,Y),op(assign,X,Y),thtc):-formula(thtc_assign, assign(X,Y)).

% Atoms directly in the operator.
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
derive(op(O,sum(mul(D,A),Y),X), op(O,sum(mul(D,next(0,A)),Y),X),thtc):-formula(atom, A), formula(thtc,op(O,sum(mul(D,A),Y),X)).
derive(op(O,sum(Y,mul(D,A)),X), op(O,sum(Y,mul(D,next(0,A))),X),thtc):-formula(atom, A), formula(thtc,op(O,sum(Y,mul(D,A)),X)).
derive(op(O,X,sum(mul(D,A),Y)), op(O,X,sum(mul(D,next(0,A)),Y)),thtc):-formula(atom, A), formula(thtc,op(O,X,sum(mul(D,A),Y))).
derive(op(O,X,sum(Y,mul(D,A))), op(O,X,sum(Y,mul(D,next(0,A)))),thtc):-formula(atom, A), formula(thtc,op(O,X,sum(Y,mul(D,A)))).

% next(A) <-> next(0,A)
derive(op(O,sum(mul(D,next(A)),Y),X), op(O,sum(mul(D,next(1,A)),Y),X),thtc):-formula(atom, A), formula(thtc,op(O,sum(mul(D,next(A)),Y),X)).
derive(op(O,sum(Y,mul(D,next(A))),X), op(O,sum(Y,mul(D,next(1,A))),X),thtc):-formula(atom, A), formula(thtc,op(O,sum(Y,mul(D,next(A))),X)).
derive(op(O,X,sum(mul(D,next(A)),Y)), op(O,X,sum(mul(D,next(1,A)),Y)),thtc):-formula(atom, A), formula(thtc,op(O,X,sum(mul(D,next(A)),Y))).
derive(op(O,X,sum(Y,mul(D,next(A)))), op(O,X,sum(Y,mul(D,next(1,A)))),thtc):-formula(atom, A), formula(thtc,op(O,X,sum(Y,mul(D,next(A))))).

