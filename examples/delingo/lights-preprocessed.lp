__next(push) :- __initial.
:- red, green.
red :- not green.
__dia(__seq(__seq(green,__star(green)),__star(red)),__box(__step,__bot)):- push.

#show __dia/2.
#show __box/2.
#show red/0.
#show green/0.
#show push/0.

#external push.
#external red.
#external green.
#external __initial.
#external __final.
#external __box(__step,__bot).
#external __bot.
#external __top.
