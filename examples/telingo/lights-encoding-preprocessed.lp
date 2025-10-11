__next(push) :- __initial.
:- red, green.
red :- not green.
__eventually(__and(green,__always(green))):- push.


#external __initial.
#external push.
#external __always(green).
#external green.

% _show.
% _show(push):-push.
% _show(__always(green)):-__always(green).
