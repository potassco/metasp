light(l1).
red(L) :- not green(L), light(L).
&next(push(l1)) :- &initial.

&next(&eventually(green(L))):- push(L).

% #show &next/1.
% #show green(L):green(L).
% #show.
