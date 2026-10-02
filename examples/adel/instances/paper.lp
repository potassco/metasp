
&action(ll).
&action(lr).
% Handle as directive
% &action{ll(R):robot(R)}.

% First need to have the direction for the operators in the head
&sneg(empty):- &initial.
&always(&aand(ll,lr),&sneg(empty)) :- &sneg(empty).
&always(&aor(&aand(ll,&aneg(lr) ), &aand(&aneg(ll),lr)),empty).
&wnext(empty) :- empty, not &next(&sneg(empty)).
&wnext(&sneg(empty)) :- &sneg(empty), not &next(empty).


#show &sneg/1.
#show empty/0.
