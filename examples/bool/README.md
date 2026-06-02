# Boolean

A Boolean extension of ASP.

## Usage

Run the test instance in `examples/bool/tests/and_not.test.lp` with the
following command:

```bash
> metasp solve clingo examples/bool/tests/and_not.test.lp --meta-config examples/bool/config.yml
Metasp (<class 'metasp.app.ClingoApp'>) version 5.8.0
Reading from examples/bool/tests/and_not.test.lp
Solving...
Answer: 1 (Time: 0.165s)
c
a
SATISFIABLE

Models       : 1+
Calls        : 1
Time         : 0.165s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.153s
```

## UI

```bash
metasp ui examples/bool/tests/and_not.test.lp --meta-config examples/bool/config.yml
```

<img src="https://github.com/potassco/metasp/blob/master/examples/bool/ui.gif?raw=true">
