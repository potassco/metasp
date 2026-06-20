light(l1).
red(L) :- not green(L), light(L).
&next(push(l1)) :- &initial.
&next(&eventually(green(L))):- push(L).

% #TEST
% clingo --meta-config ../config.yml -c n=2
% - true(light(l1),0) true(red(l1),0) true(light(l1),1) true(push(l1),1) true(red(l1),1) true(green(l1),2) true(light(l1),2)
