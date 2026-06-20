light(l1).
red(L) :- not green(L), light(L).
&next(push(l1)) :- &initial.

&next(&eventually(green(L))):- push(L).

#show red/1.
#show green/1.
#show push/1.

% #TEST
% clingo --meta-config ../config.yml -c n=2
% -  true(red(l1),0) true(push(l1),1) true(red(l1),1) true(green(l1),2)

% #TEST
% clingo --meta-config ../config.yml -c n=3
% -  true(red(l1),0)  true(push(l1),1) true(red(l1),1) true(green(l1),2) true(red(l1),3)
% -  true(red(l1),0)  true(push(l1),1) true(red(l1),1) true(red(l1),2)  true(green(l1),3)
