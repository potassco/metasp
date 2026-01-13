light(l1).
red(L) :- not green(L), light(L).
__next((5,6),push(l1)) :- __initial. %Here we limit the time for the next otherwise clingcon never shows models

__eventually((1,15),__always((0,30),green(L))):- push(L).

#external __initial.
#external green(L):push(L).
#external __always((0,30),green(L)):push(L).
#external push(l1).


% Trick just to force the states and see the behaviour
% __next((2,3),__next((5,6),__top)):- push(L).
% #external top:push(L).


