&assign(speed, 100):-&initial.
&assign(&next(acc), 10):-&initial.
&assign(&next(4,acc), 20):-&initial.

&assign(&next(speed), speed):- not &neq(&next(speed),speed).

&assign(&next(speed), &add(speed,acc)).

too_fast :-&lt(110, speed).

% #TEST
%   flingo --meta-config ../config.yml --const n=2
% - __csp(__aux(18),10) __csp(__aux(20),100) __csp(__aux(17),0) __csp(var(acc,4),20) __csp(__aux(16),20) __csp(__aux(15),0) __csp(__aux(14),100) __csp(__aux(13),0) __csp(__aux(12),100) __csp(__aux(10),110) __csp(__aux(19),0) __csp(var(acc,0),0) __csp(__aux(8),0) __csp(var(speed,3),110) __csp(var(acc,1),10) __csp(__aux(5),100) __csp(__aux(6),10) __csp(__aux(11),0) __csp(__aux(2),1) __csp(var(acc,2),0) __csp(__aux(3),110) __csp(var(speed,2),110) __csp(__aux(7),100) __csp(var(speed,0),100) __csp(__aux(4),0) __csp(var(speed,1),100) __csp(var(_one,0),1) __csp(__aux(1),1) __csp(var(_one,2),1) __csp(__aux(9),0) __csp(__aux(0),1) __csp(var(_one,1),1) __val(var(acc,4),20) __val(var(speed,3),110) __val(var(acc,1),10) __val(var(speed,2),110) __val(var(speed,0),100) __val(var(speed,1),100) __val(var(_one,0),1) __val(var(_one,2),1) __val(var(_one,1),1)
