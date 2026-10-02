# ADEL Action Dynamic Equilibrium Logic

Inside the folder `examples/adel` you will find the instances and the semantics encoding for ADEL (Action Dynamic Equilibrium Logic).

With this command we run the example for the paper with the soup.

```
metasp solve clingo instances/paper.lp --meta-config config.yml -c n=3 0
```

## Strong negation

We get 64 models as output and it seams to be correct. Notice that the strong negation does not really impact the soup bowl example because it is due to the rules that we never get both empty and -empty.
