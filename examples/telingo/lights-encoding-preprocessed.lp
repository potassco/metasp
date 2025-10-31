light(l1).
red(L) :- not green(L), light(L).
__next(__eventually(green(L))):- push(L).
__next(push(l1)) :- __initial.

#external __eventually(green(L)):push(L).
#external green(L):push(L).
#external __initial.
#external push(l1).
