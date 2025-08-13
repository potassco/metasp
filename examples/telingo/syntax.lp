modality(tel, atom).
modality(tel, initial, 0, ()).
modality(tel, final, 0, ()).
modality(tel, and, 2, (tel, tel)).
modality(tel, or, 2, (tel, tel)).
modality(tel, next, 1, (tel,)).
modality(tel, eventually, 1, (tel,)). %Derived
modality(tel, always, 1, (tel)). %Derived
modality(tel, since, 2, (tel,tel)). %Derived
modality(tel, until, 2, (tel,tel)).


occurrence(tel, body;head).

arg((weak;weak_next;neg),0,unsafe).
arg((until;since),0,unsafe).
arg(or,(0;1),unsafe).
