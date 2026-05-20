light(l1).
red(L) :- not green(L), light(L).
&next(push(l1)) :- &initial.

&next(&eventually(green(L))):- push(L).

#show &next/1.

% #TEST
% clingo --meta-config ../config.yml -c n=2
% -  true(__next(push(l1)),0)  true(__next(__eventually(green(l1))),1) true(__next(__eventually(green(l1))),0)
