light(l1).
&eventually(&star(&seq(green(L),red(L))), &final) :-&initial, light(L).

#show green/1.
#show red/1.

% #TEST
% clingo --meta-config ../config.yml -c n=4
% - true(green(l1),0) true(red(l1),1) true(green(l1),2) true(red(l1),3)
