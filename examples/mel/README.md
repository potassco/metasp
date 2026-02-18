# MEL

This folder contains an example of how to use the `mel` (Modal Equilibrium Logic) extension to solve a problem.

We can solve the metric problem from `instances/paper-lights-constraint.lp` with the following command:

```
> metasp solve clingcon  -c n=2 instances/paper-lights-constraint.lp --syntax-encoding syntax.lp --semantics-encoding semantics.lp  --printer mel_printer --python-scripts print_functions.py -n 0 --log warning
Metasp (<class 'clingcon.__main__.ClingconApp'>) version 5.2.1
Reading from instances/paper-lights-constraint.lp
Solving...
Answer: 1 (Time: 0.199s)
State 0  @0: light(l1) red(l1)
State 1  @5: light(l1) push(l1) red(l1)
State 2  @15: green(l1) light(l1)

Answer: 2 (Time: 0.199s)
State 0  @0: light(l1) red(l1)
State 1  @5: light(l1) push(l1) red(l1)
State 2  @16: green(l1) light(l1)

Answer: 3 (Time: 0.200s)
State 0  @0: light(l1) red(l1)
State 1  @5: light(l1) push(l1) red(l1)
State 2  @17: green(l1) light(l1)

Answer: 4 (Time: 0.200s)
State 0  @0: light(l1) red(l1)
State 1  @5: light(l1) push(l1) red(l1)
State 2  @18: green(l1) light(l1)

Answer: 5 (Time: 0.201s)
State 0  @0: light(l1) red(l1)
State 1  @5: light(l1) push(l1) red(l1)
State 2  @19: green(l1) light(l1)

SATISFIABLE

Models       : 5
Calls        : 1
Time         : 0.201s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.200s
```

Notice the use of a custom temporal printer that enhances the temporal printer with the time via @T.

## UI

To run the UI use the following command:

`metasp ui --meta-config config.yml --log info -c n=2 instances/paper-lights-constraint.lp`
