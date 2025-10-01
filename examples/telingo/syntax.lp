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
