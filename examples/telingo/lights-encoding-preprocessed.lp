next(push) :- initial.
:- red, green.
red :- not green.
eventually(always(green)):- push.


#external initial.
#external push.
#external always(green).
#external green.

% _show(push):-push.
% _show(push):-push.
