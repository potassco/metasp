% -empty.
% &always(&aand(ll,lr),&not(empty)) :- -empty.
% &always(&aor(&aand(ll,&aneg(lr) ), &aand(&aneg(ll),lr)),&not(empty)).
% empty, not &next(&not(empty)) :- &wnext(empty).
% -empty, not &next(empty) :- &wnext(&not(empty)).
a.
