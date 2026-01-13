light(l1).
red(L) :- not green(L), light(L).
__next(push(l1)) :- __initial.

% Once pushed green once then many times green and then red until the end
__dia(__seq(__seq(green(L),__star(green(L))),__star(red(L))),__box(__step,__bot)):- push(L).

% #show __dia/2.
% #show __box/2.
% #show red/0.
% #show green/0.
% #show push/0.

#external push(l1).
#external green(L):push(L).
#external __box(__step,__bot).
#external __bot.
#external __initial.
#external __top.
