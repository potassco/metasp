light(l1).
&eventually(&star(&seq(green(L),red(L))), &final) :-&initial, light(L).
% hi:-&final.

% #show &not/1.
#show &final/0.
