% Handle acceleration
% assign(next(s), 10):-initial.
% assign(s, 10):-initial.
% eq(next(s), 10):-initial.
% eq(next(3,s), 99):-initial.

% eq(b, s).
% ten_b:-eq(b,10).

% assign(next(a),10):- initial.
% assign(next(a),10):- initial.
__assign(a,10):- __initial.
__assign(__next(3,a),20):- __initial.

% assign(next(a),a):- not neq(next(a),a).
__assign(__next(a),a):- not __neq(__next(a),a).
% eq(next(a),a):- not initial.
% eq(next(a),a).

% a.
% next(fine):- smaller(p,rdpos), smaller_eq(rdpos, next(p)), smaller(rdlimit,next(s)),not final.
#external __initial.
#external __neq(__next(a),a).





