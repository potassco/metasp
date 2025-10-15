
type(thtc).
allow(thtc, body).
allow(thtc, head).
constructor(thtc, (op, 3)).
    arg((op, 3), 0, type, atom).
    arg((op, 3), 1, type, linear_temp_cons_atom).
    arg((op, 3), 2, type, linear_temp_cons_atom).

type(linear_temp_cons_atom).
constructor(linear_temp_cons_atom, (sum, 2)).
    arg((sum, 2), 0, type, mul).
    arg((sum, 2), 1, type, mul).

type(mul).
constructor(mul, (mul, 2)).
    arg((mul, 2), 0, type, number).
    arg((mul, 2), 1, type, simple_tel).

type(simple_tel).
constructor(simple_tel, (next, 2)).
    arg((next, 2), 0, type, number).
    arg((next, 2), 1, type, atom).


% -----------------------------
% Syntactic sugar
% -----------------------------

% From simpler syntax to generic operator
var(x, any).
var(y, any).
defined_as(thtc, __eq(x,y), __op(eq,x,y)).
defined_as(thtc, __neq(x,y), __op(neq,x,y)).
defined_as(thtc, __lt(x,y), __op(lt,x,y)).
defined_as(thtc, __leq(x,y), __op(leq,x,y)).
defined_as(thtc, __assign(x,y), __op(assign,x,y)).

% Atoms directly in the operator.
var(c, atom).
var(c, simple_tel).
var(c, number).
defined_as(linear_temp_cons_atom, c, __sum(c,0)).

% A <-> 1*A and next(A) <-> 1*next(A)
var(b, atom).
var(b, simple_tel).
defined_as(mul, b, __mul(1,b)).

% A number N  instead of &mul is the same of N*1 (N*_one)
var(n, number).
defined_as(mul, n, __mul(n,_one)).

% A <-> next(0,A)
var(a, atom).
defined_as(simple_tel, a, __next(0,a)).
defined_as(mul, a, __next(0,a)).
defined_as(linear_temp_cons_atom, a, __next(0,a)).

% next(A) <-> next(1,A)
defined_as(mul, __next(a), __next(1,a)).
defined_as(simple_tel, __next(a), __next(1,a)).
defined_as(linear_temp_cons_atom, __next(a), __next(1,a)).

