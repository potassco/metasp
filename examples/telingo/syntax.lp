type(tel).
subtype(atom, tel).

constructor(tel, initial, 0, ()).
constructor(tel, final, 0, ()).
constructor(tel, and, 2, (tel, tel)).
constructor(tel, or, 2, (tel, tel)).
constructor(tel, next, 1, (tel,)).
constructor(tel, eventually, 1, (tel,)). %Derived
constructor(tel, always, 1, (tel)). %Derived
constructor(tel, until, 2, (tel,tel)).
constructor(tel, release, 2, (tel,tel)). %Derived

allow(tel, body;head).

arg((weak;weak_next;neg),0,unsafe).
arg((until;release),0,unsafe).
arg(or,(0;1),unsafe).


% defined_as((tel,wnext(_formula(tel,_f))), (tel, or(next(_formula(tel,_f)), final))).
% % wprev/1
% defined_as((tel,wprev(_formula(tel,_f))), (tel, or(prev(_formula(tel,_f)), initial))).
% % eventually_after/1
% defined_as((tel,eventually(_formula(tel,_f))), (tel, until(true, _formula(tel,_f)))).
% % always/1
% defined_as((tel,always(_formula(tel,_f))), (tel, release(false, _formula(tel,_f)))).
% % release/2
% defined_as((tel,release(_formula(tel,l),_formula(tel,r))), (tel, until(_formula(tel,R), and(_formula(tel,R), or(_formula(tel,L), final))))).
