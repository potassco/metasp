


% Start by waking up
wake_up:-initial.
% Once I wake up then I work and eat multiple times, then I sleep
dia(seq(step,seq(star(seq(work,eat)),sleep)),rested):-wake_up.
% If I work I either program read or write
1{program;read;write}1:-work.
% When I sleep next I am rested
dia(step,rested):-sleep.
% I eventually have to work in the day
:- initial, not dia(star(step),work).


#external top.
#external box(star(step),top).
#external dia(test(top),top).
#external dia(star(top),top).
#external dia(star(step),work).
#external eventually(top).
#external initial.
#external work.
#external eat.
#external sleep.


