&next(push) :- &initial.
:- red, green.
red :- not green.
&eventually(&and(green,&next(green))):- push.

#show push/0.
