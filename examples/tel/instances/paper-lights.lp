light(l1).
red(L) :- not green(L), light(L).
&next(push(l1)) :- &initial.

&next(&eventually(green(L))):- push(L).

% #show &final/0.
% #show &eventually/1.
% #show &not/1.
% #show &next/1.
% #show green(L):green(L).
% #show.
