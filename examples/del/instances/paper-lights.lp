light(l1).
% __eventually(__star(__seq(green(L),red(L))), __final) :-__initial, light(L).

__true:-__initial.


&not(&true).

&not/1{
    type: temporal
}

#type temporal:{
    subtypes: {del;tel;}
}

#external green(L):light(L).
#external red(L):light(L).
#external __initial.


% #show __box/2.
% #show __dfinal/0.
% #external __dfinal.
% #external __box(__step,__bot).
