&action(ll).
&action(lr).

% First need to have the direction for the operators in the head
-empty:- &initial.
&always(&aand(ll,lr),&not(empty)) :- -empty.
&always(&aor(&aand(ll,&aneg(lr) ), &aand(&aneg(ll),lr)),empty).
&wnext(empty) :- empty, not &next(&not(empty)).
&wnext(&not(empty)) :- -empty, not &next(empty).

