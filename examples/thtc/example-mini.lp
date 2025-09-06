% Handle acceleration
% assign(next(s), 10):-initial.
% assign(s, 10):-initial.
eq(next(s), 10):-initial.
eq(next(3,s), 99):-initial.

eq(b, s).

% next(fine):- smaller(p,rdpos), smaller_eq(rdpos, next(p)), smaller(rdlimit,next(s)),not final.
#external initial.
