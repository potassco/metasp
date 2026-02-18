# DEL

A Dynamic Equilibrium Logic (DEL) encoding of the problem of finding a dynamic stable model of a logic program.

## Usage

For the encoding in `instances/paper-lights.lp` you can run the following command to get all traces of length 3:

```
> metasp solve clingo --meta-config config.yml --log info -c n=2 instances/paper-lights.lp
```
