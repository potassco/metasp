next((5,6),push) :- initial.
:- red, green.
red :- not green.
eventually((1,15),always((0,30),green)):- push.

#external initial.
#external push.
#external green.
