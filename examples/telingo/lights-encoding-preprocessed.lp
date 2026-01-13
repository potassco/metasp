light(l1).
red(L) :- not green(L), light(L).
__next(push(l1)) :- __initial.

__next(__eventually(green(L))):- push(L).

#external __eventually(green(L)):push(L).
#external green(L):push(L).
#external __initial.
#external push(l1).

#show __next/1.
