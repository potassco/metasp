% :- a: &eventually(a) Can we do this? is it then body or head?
% HEAD_ATOM :: TEL
% BODY_ATOM :: TEL

% TEL:: ATOM | initial | final | true | false
% 	| and TEL TEL | or TEL TEL
% 	| next TEL
% 	| until TEL TEL | release TEL TEL

% f1:= TEL
% &eventually(f1):TEL = &until(&true, f1)
% &always(f1):TEL = &release(&false, f1)
% &release(f2,f1):TEL = &until(f1, &and(f1, &or(f2, &final)))


type(tel).
allow(tel, head).
allow(tel, body).

subtype(atom, tel).
% constructor(tel, atom).
constructor(tel, (initial, 0)).
constructor(tel, (final, 0)).
constructor(tel, (true, 0)).
constructor(tel, (false, 0)).
constructor(tel, (and, 2)).
	arg((and, 2), 0, type, tel).
	arg((and, 2), 1, type, tel).
constructor(tel, (or, 2)).
	arg((or, 2), 0, type, tel).
	arg((or, 2), 1, type, tel).
constructor(tel, (next, 1)).
	arg((next, 1), 0, type, tel).
	arg((next, 1), 0, safety, unsafe).
% constructor(tel, (eventually, 1)).
% 	arg((eventually, 1), 0, type, tel).
% 	arg((eventually, 1), 0, safety, unsafe).
% constructor(tel, (always, 1)).
% 	arg((always, 1), 0, type, tel).
% 	arg((always, 1), 0, safety, unsafe).
constructor(tel, (until, 2)).
	arg((until, 2), 0, type, tel).
	arg((until, 2), 0, safety, unsafe).
	arg((until, 2), 1, type, tel).
	arg((until, 2), 1, safety, safe).
constructor(tel, (release, 2)).
	arg((release, 2), 0, type, tel).
	arg((release, 2), 0, safety, unsafe).
	arg((release, 2), 1, type, tel).
	arg((release, 2), 1, safety, safe).

var(f1, tel).
var(f2, tel).
defined_as(tel, __eventually(f1), __until(__true, f1)).
defined_as(tel, __always(f1), __release(__false, f1)).
% defined_as(tel, __release(f1,f2), __until(f2, __and(f2,__or(f1,__final)))).

% &eventually(X):-&next(X).

% type(tel).
% subtype(atom, tel).

% constructor(tel, initial, 0, ()).
% constructor(tel, final, 0, ()).
% constructor(tel, and, 2, (tel, tel)).
% constructor(tel, or, 2, (tel, tel)).
% constructor(tel, next, 1, (tel,)).
% constructor(tel, eventually, 1, (tel,)). %Derived
% constructor(tel, always, 1, (tel)). %Derived
% constructor(tel, until, 2, (tel,tel)).
% constructor(tel, release, 2, (tel,tel)). %Derived

% allow(tel, body;head).

% arg((weak;weak_next;neg),0,unsafe).
% arg((until;release),0,unsafe).
% arg(or,(0;1),unsafe).


% defined_as((tel,wnext(_formula(tel,_f))), (tel, or(next(_formula(tel,_f)), final))).
% % wprev/1
% defined_as((tel,wprev(_formula(tel,_f))), (tel, or(prev(_formula(tel,_f)), initial))).
% % eventually_after/1
% defined_as((tel,eventually(_formula(tel,_f))), (tel, until(true, _formula(tel,_f)))).
% % always/1
% defined_as((tel,always(_formula(tel,_f))), (tel, release(false, _formula(tel,_f)))).
% % release/2
% defined_as((tel,release(_formula(tel,l),_formula(tel,r))), (tel, until(_formula(tel,R), and(_formula(tel,R), or(_formula(tel,L), final))))).
