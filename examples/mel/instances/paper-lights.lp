light(l1).
red(L) :- not green(L), light(L).
&eventually(&i(10,15),green(L)):- push(L).
&next(push(l1)) :- &initial. %Here we limit the time for the next otherwise clingcon never shows models

#show &eventually/2.
#show &next/2.
#show &next/1.
#show push/1.
#show green/1.
