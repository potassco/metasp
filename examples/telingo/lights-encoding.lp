next(push) :- initial.
:- red, green.
red :- not green.
eventually(always(green)):- push.

#show push/0.
