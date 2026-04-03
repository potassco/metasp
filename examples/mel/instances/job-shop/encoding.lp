wait(O);start_run(O) :- operation(O), not has_run(O).

&always(&i(0,D),run(O))  :- start_run(O), duration(O,D).
&always(&i(D,#sup),has_run(O)):- start_run(O), duration(O,D).

:- run(O), run(O'), O'>O, machine(O, M), machine(O', M).
:- job(O+1,J), job(O,J), machine(O+1, M),
   start_run(O+1), not has_run(O).

:- operation(O), not has_run(O), &final.


#show start_run/1.
