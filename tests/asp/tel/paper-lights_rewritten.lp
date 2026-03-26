light(l1).
red(L) :- not green(L), light(L).
__next(push(l1)) :- __initial.

__next(__eventually(green(L))):- push(L).

_show_atom(__next(A)) :- __next(A).
_show_term(green(L)) :- green(L).
_show.
#external push(l1).
#external __initial.
#external green(L): push(L).
