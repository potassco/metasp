# MAPF

Comparing with results from metric tplp paper. Still under revision.
Comparing with `clingcon` as solver for the HTc approach.
We use the the empty 6x6 grid with 4 agents and a factor of 1.

## n=10 v=15

### Metasp system

We include the semantics encoding to add an upper bound to the timing function.

```
metasp solve clingcon 1 --meta-config config.yml -c n=10 --semantics-encoding restricted-limit.lp --semantics-encoding semantics.lp instances/mapf/encoding.lp instances/mapf/instances/empty_x6_y6.lp -c v=15 --stats

Models       : 1+
Calls        : 1
Time         : 10.124s (Solving: 0.85s 1st Model: 0.57s Unsat: 0.00s)
CPU Time     : 10.036s

Choices      : 1028
Conflicts    : 355      (Analyzed: 355)
Restarts     : 2        (Average: 177.50 Last: 123 Blocked: 0)
Stab. Tests  : 1248     (Full: 624 Partial: 624)
Model-Level  : 22.0
Problems     : 1        (Average Length: 1.00 Splits: 0)
Lemmas       : 6388     (Deleted: 0)
  Binary     : 81       (Ratio:   1.27%)
  Ternary    : 170      (Ratio:   2.66%)
  Conflict   : 355      (Average Length:   41.5 Ratio:   5.56%)
  Loop       : 6024     (Average Length:   25.0 Ratio:  94.30%)
  Other      : 9        (Average Length:    2.0 Ratio:   0.14%)
Backjumps    : 355      (Average:  2.84 Max:  35 Sum:   1008)
  Executed   : 348      (Average:  2.82 Max:  35 Sum:   1001 Ratio:  99.31%)
  Bounded    : 7        (Average:  1.00 Max:   1 Sum:      7 Ratio:   0.69%)

Rules        : 1972664
Atoms        : 1433283
Disjunctions : 8560     (Original: 8560)
Bodies       : 1757610  (Original: 1701997)
Equivalences : 732820   (Atom=Atom: 129087 Body=Body: 110474 Other: 493259)
Tight        : No       (SCCs: 624 Non-Hcfs: 624 Nodes: 232370 Gammas: 55613)
Variables    : 202923   (Eliminated:    0 Frozen: 147310)
Constraints  : 951280   (Binary:  84.3% Ternary:   9.5% Other:   6.2%)

```

### Memelingo system

```
memelingo mlp-tplp-htc 1 examples/mapf/mapf_javier.lp examples/mapf/instances/x6_y6_a4_f1.lp  -c lambda=10  -c v=15 --stats -q                                  ─╯
Memelingo (<class 'clingcon.__main__.ClingconApp'>) mlp-tplp-htc version 5.2.1
Reading from examples/mapf/mapf_javier.lp ...
Reifing...
Saving refication...
Running application... with files  ['/Users/susana/Developer/anaconda3/envs/memelingotest/lib/python3.12/site-packages/memelingo/encodings/mlp-tplp-htc.lp', '/var/folders/wc/l5bhs7f96zj95mprv40my6kw0000gn/T/tmpj9jo05km.lp']
Solving...
SATISFIABLE

Models       : 1+
Calls        : 1
Time         : 11.524s (Solving: 4.10s 1st Model: 4.10s Unsat: 0.00s)
CPU Time     : 11.361s

Choices      : 18382
Conflicts    : 1515     (Analyzed: 1515)
Restarts     : 9        (Average: 168.33 Last: 118)
Stab. Tests  : 74202    (Full: 5874 Partial: 68328)
Model-Level  : 17.0
Problems     : 1        (Average Length: 1.00 Splits: 0)
Lemmas       : 10999    (Deleted: 0)
  Binary     : 171      (Ratio:   1.55%)
  Ternary    : 272      (Ratio:   2.47%)
  Conflict   : 1515     (Average Length:   49.5 Ratio:  13.77%)
  Loop       : 9473     (Average Length:   26.6 Ratio:  86.13%)
  Other      : 11       (Average Length:    2.0 Ratio:   0.10%)
Backjumps    : 1515     (Average:  5.65 Max: 101 Sum:   8560)
  Executed   : 1494     (Average:  5.64 Max: 101 Sum:   8539 Ratio:  99.75%)
  Bounded    : 21       (Average:  1.00 Max:   1 Sum:     21 Ratio:   0.25%)

Rules        : 1769445
Atoms        : 1300339
Disjunctions : 7704     (Original: 7704)
Bodies       : 1527308  (Original: 1481111)
Equivalences : 767385   (Atom=Atom: 164561 Body=Body: 118653 Other: 484171)
Tight        : No       (SCCs: 624 Non-Hcfs: 624 Nodes: 197882 Gammas: 0)
Variables    : 173687   (Eliminated:    0 Frozen: 127490)
Constraints  : 804011   (Binary:  84.0% Ternary:   9.7% Other:   6.3%)

Clingcon
  Init time in seconds
    Total    : 0.0212087
    Simplify : 0.00677183
    Translate: 0.00237533
  Problem
    Constraints: 0
    Variables: 10
    Clauses  : 7803
    Literals : 90
  Translate
    Constraints removed: 1329
    Constraints added: 0
    Clauses  : 7543
    Weight constraints: 9
    Literals : 90
  [Thread 0]
    Time in seconds
      Total  : 0.00310161
      Propagation: 0.00247467
      Check  : 0.000483132
      Undo   : 0.000143802
    Refined reason: 0
    Introduced reason: 0
    Literals introduced: 0
```


## Analysis

- As in Job-Shop we have more choices and conflicts. This needs further investigation.
