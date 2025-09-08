% Handle acceleration
assign(next(4,acc), 11):-initial.
% assign(acc, 2):-initial.
assign(next(6,acc), -2):-initial.
% assign(acc, 1):- not eq(acc,0).
% assign(acc, 1):- not eq(acc,0).

% Initial state
assign(p,0):-initial.
assign(s,80):-initial.

assign(rdlimit,90).
assign(rdpos,400).
% No restriction on final needed because it should be handled by the value of the next being
assign(next(s), sum(s,acc)).
assign(next(s), s):- not neq(next(s),s).
% assign(next(p), sum(p,s)).

% next(fine):- smaller(p,rdpos), smaller_eq(rdpos, next(p)), smaller(rdlimit,next(s)),not final.

#external initial.
#external neq(next(s),s).
#external neq(acc,0).
