&assign(speed, 100):-&initial.
&assign(&next(acc), 10):-&initial.
&assign(&next(4,acc), 20):-&initial.

&assign(&next(speed), speed):- not &neq(&next(speed),speed).

&assign(&next(speed), &add(speed,acc)).

too_fast :-&lt(110, speed).

% #TEST
%   flingo --meta-config ../config.yml --const n=2
% - __csp(speed,100) __val(speed,100)
