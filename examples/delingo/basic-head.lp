{a}.
{c}.

:- not next(a), initial.
:- not next(c), initial.


box(seq(test(c),step),b).


#external initial.
#external top.
#external final.
#external next(a).
#external next(c).

_show(final):-final.

