# DEL

A Dynamic Equilibrium Logic (DEL) encoding of the problem of finding a dynamic stable model of a logic program.

## Usage

For the encoding in `instances/paper-lights.lp` you can run the following command to get all traces of length 5 which alternates green and red using the `del` extension:

```
> metasp solve clingo --meta-config config.yml -c n=4 instances/paper-lights.lp                                                                                   ─╯
Metasp (<class 'metasp.app.ClingoApp'>) version 5.8.0
Reading from instances/paper-lights.lp
Solving...
Answer: 1 (Time: 0.621s)
 State 0: green(l1) light(l1)
 State 1: light(l1) red(l1)
 State 2: green(l1) light(l1)
 State 3: light(l1) red(l1)
 State 4: light(l1)

SATISFIABLE

Models       : 1+
Calls        : 1
Time         : 0.621s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.611s
```
