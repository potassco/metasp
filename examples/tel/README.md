# TEL

A Temporal Equilibrium Logic (TEL) encoding of the problem of finding a temporal stable model of a logic program.

## Usage

For the encoding in `instances/paper-lights.lp` you can run the following command to get all traces of length 3:

```bash
Getting all trances of length 3 with the `tel` extension:

```bash
> metasp solve clingo  -c n=2 instances/paper-lights.lp --syntax-encoding syntax.lp --semantics-encoding semantics.lp  -n 0
Metasp (<class 'metasp.app.ClingoApp'>) version 5.8.0
Reading from instances/paper-lights.lp
Solving...
Answer: 1 (Time: 0.128s)
true(light(l1),0) true(light(l1),1) true(light(l1),2) true(green(l1),2) true(red(l1),0) true(red(l1),1) true(push(l1),1)
SATISFIABLE

Models       : 1
Calls        : 1
Time         : 0.129s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.121s
```

### Print output

By adding the `--printer temporal_printer` argument you can get a more readable output:

```
> metasp solve clingo  -c n=2 instances/paper-lights.lp --syntax-encoding syntax.lp --semantics-encoding semantics.lp  --printer temporal_printer -n 0
Metasp (<class 'metasp.app.ClingoApp'>) version 5.8.0
Reading from instances/paper-lights.lp
Solving...
Answer: 1 (Time: 0.133s)
 State 0: light(l1) red(l1)
 State 1: light(l1) push(l1) red(l1)
 State 2: green(l1) light(l1)

SATISFIABLE

Models       : 1
Calls        : 1
Time         : 0.134s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.118s
```

### Show statements

Notice this only shows the atoms, formulas can be included by adding the corresponding `#show` directive in the input file.

For instance, adding the following code to the `instances/paper-lights.lp` file will show the atom `green` and the formula `&next` in the output:

```
#show &next/1.
#show green(L):green(L).
#show.
```

```bash
> metasp solve clingo  -c n=2 instances/paper-lights.lp --syntax-encoding syntax.lp --semantics-encoding semantics.lp  --printer temporal_printer -n 0 --log warning
Metasp (<class 'metasp.app.ClingoApp'>) version 5.8.0
Reading from instances/paper-lights.lp
Solving...
Answer: 1 (Time: 0.124s)
 State 0: &next(&eventually(green(l1))) &next(push(l1))
 State 1: &next(&eventually(green(l1)))
 State 2: green(l1)

SATISFIABLE

Models       : 1
Calls        : 1
Time         : 0.125s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.122s
```



## UI

To run the UI use the following command:

`metasp ui --meta-config config.yml --log info -c n=2 instances/paper-lights.lp`
