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
Models       : 1+
Calls        : 1
Time         : 14.380s (Solving: 0.26s 1st Model: 0.20s Unsat: 0.00s)
CPU Time     : 14.208s

Choices      : 440
Conflicts    : 85       (Analyzed: 85)
Restarts     : 0
Stab. Tests  : 1248     (Full: 624 Partial: 624)
Model-Level  : 19.0
Problems     : 1        (Average Length: 1.00 Splits: 0)
Lemmas       : 1579     (Deleted: 0)
  Binary     : 25       (Ratio:   1.58%)
  Ternary    : 47       (Ratio:   2.98%)
  Conflict   : 85       (Average Length:   37.4 Ratio:   5.38%)
  Loop       : 1493     (Average Length:   24.1 Ratio:  94.55%)
  Other      : 1        (Average Length:    2.0 Ratio:   0.06%)
Backjumps    : 85       (Average:  4.98 Max:  37 Sum:    423)
  Executed   : 84       (Average:  4.96 Max:  37 Sum:    422 Ratio:  99.76%)
  Bounded    : 1        (Average:  1.00 Max:   1 Sum:      1 Ratio:   0.24%)

Rules        : 1769445
Atoms        : 1300339
Disjunctions : 7704     (Original: 7704)
Bodies       : 1527308  (Original: 1481111)
Equivalences : 767385   (Atom=Atom: 164561 Body=Body: 118653 Other: 484171)
Tight        : No       (SCCs: 624 Non-Hcfs: 624 Nodes: 197882 Gammas: 46197)
Variables    : 173687   (Eliminated:    0 Frozen: 127490)
Constraints  : 804011   (Binary:  84.0% Ternary:   9.7% Other:   6.3%)
```


## Analysis

- As in Job-Shop we have more choices and conflicts. This needs further investigation.
