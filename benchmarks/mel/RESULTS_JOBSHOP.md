# Job-shop

Comparing with results from metric tplp paper. Still under revision.
Comparing with `clingcon` as solver for the HTc approach.
We use the relaxed version with a bound of two times the optimal makespan.

## n=20 v=110

### Metasp system

We include the semantics encoding to add an upper bound to the timing function.

```
metasp solve clingcon 1 --meta-config config.yml -c n=20 --semantics-encoding restricted-limit.lp --semantics-encoding semantics.lp instances/job-shop/encoding.lp instances/job-shop/instances/ft06.lp -c v=110 --stats
Models       : 1+
Calls        : 1
Time         : 3.549s (Solving: 2.72s 1st Model: 2.66s Unsat: 0.00s)
CPU Time     : 3.543s

Choices      : 68481
Conflicts    : 11920    (Analyzed: 11920)
Restarts     : 52       (Average: 229.23 Last: 253 Blocked: 0)
Model-Level  : 291.0
Problems     : 1        (Average Length: 1.00 Splits: 0)
Lemmas       : 28444    (Deleted: 18582)
  Binary     : 1797     (Ratio:   6.32%)
  Ternary    : 582      (Ratio:   2.05%)
  Conflict   : 11920    (Average Length:   80.3 Ratio:  41.91%)
  Loop       : 14897    (Average Length:   22.2 Ratio:  52.37%)
  Other      : 1627     (Average Length:    2.0 Ratio:   5.72%)
Backjumps    : 11920    (Average:  5.07 Max: 663 Sum:  60382)
  Executed   : 11905    (Average:  5.06 Max: 663 Sum:  60367 Ratio:  99.98%)
  Bounded    : 15       (Average:  1.00 Max:   1 Sum:     15 Ratio:   0.02%)

Rules        : 136504   (Original: 135064)
Atoms        : 78118
Disjunctions : 0        (Original: 756)
Bodies       : 72466    (Original: 71026)
Equivalences : 131578   (Atom=Atom: 28766 Body=Body: 22239 Other: 80573)
Tight        : No       (SCCs: 72 Non-Hcfs: 0 Nodes: 51030 Gammas: 0)
Variables    : 50362    (Eliminated:    0 Frozen: 48922)
Constraints  : 794721   (Binary:  17.9% Ternary:  80.2% Other:   2.0%)

```

### Memelingo system

```
memelingo mlp-tplp-htc 1 examples/job-shop/job-shop.lp examples/job-shop/instances/ft06.lp  -c lambda=20  -c v=110 --stats                                      ─╯
Memelingo (<class 'clingcon.__main__.ClingconApp'>) mlp-tplp-htc version 5.2.1
Reading from examples/job-shop/job-shop.lp ...
Reifing...
Saving refication...
Running application... with files  ['/Users/susana/Developer/anaconda3/envs/memelingotest/lib/python3.12/site-packages/memelingo/encodings/mlp-tplp-htc.lp', '/var/folders/wc/l5bhs7f96zj95mprv40my6kw0000gn/T/tmpk8duyqz1.lp']
Solving...
Answer: 1
true(start_run(0),7) true(start_run(1),9) true(start_run(2),13) true(start_run(3),14) true(start_run(4),16) true(start_run(5),18) true(start_run(6),4) true(start_run(7),8) true(start_run(8),13) true(start_run(9),14) true(start_run(10),15) true(start_run(11),18) true(start_run(12),4) true(start_run(13),6) true(start_run(14),10) true(start_run(15),13) true(start_run(16),14) true(start_run(17),15) true(start_run(18),3) true(start_run(19),5) true(start_run(20),12) true(start_run(21),13) true(start_run(22),14) true(start_run(23),17) true(start_run(24),0) true(start_run(25),9) true(start_run(26),11) true(start_run(27),15) true(start_run(28),16) true(start_run(29),17) true(start_run(30),0) true(start_run(31),4) true(start_run(32),13) true(start_run(33),14) true(start_run(34),16) true(start_run(35),18)
Assignment:
t(0)=0 t(1)=1 t(2)=2 t(3)=3 t(4)=18 t(5)=22 t(6)=24 t(7)=25 t(8)=26 t(9)=27 t(10)=29 t(11)=30 t(12)=31 t(13)=37 t(14)=72 t(15)=82 t(16)=92 t(17)=95 t(18)=96 t(19)=104
SATISFIABLE

Models       : 1+
Calls        : 1
Time         : 0.936s (Solving: 0.59s 1st Model: 0.59s Unsat: 0.00s)
CPU Time     : 0.925s

Choices      : 15320
Conflicts    : 2482     (Analyzed: 2482)
Restarts     : 14       (Average: 177.29 Last: 294)
Model-Level  : 275.0
Problems     : 1        (Average Length: 1.00 Splits: 0)
Lemmas       : 8598     (Deleted: 2879)
  Binary     : 1041     (Ratio:  12.11%)
  Ternary    : 226      (Ratio:   2.63%)
  Conflict   : 2482     (Average Length:   66.6 Ratio:  28.87%)
  Loop       : 5140     (Average Length:   21.1 Ratio:  59.78%)
  Other      : 976      (Average Length:    2.0 Ratio:  11.35%)
Backjumps    : 2482     (Average:  5.22 Max: 405 Sum:  12956)
  Executed   : 2479     (Average:  5.22 Max: 405 Sum:  12953 Ratio:  99.98%)
  Bounded    : 3        (Average:  1.00 Max:   1 Sum:      3 Ratio:   0.02%)

Rules        : 152933   (Original: 151565)
Atoms        : 96110
Disjunctions : 0        (Original: 720)
Bodies       : 82489    (Original: 81121)
Equivalences : 178439   (Atom=Atom: 43587 Body=Body: 30055 Other: 104797)
Tight        : No       (SCCs: 72 Non-Hcfs: 0 Nodes: 46944 Gammas: 0)
Variables    : 51161    (Eliminated:    0 Frozen: 49793)
Constraints  : 738663   (Binary:  18.7% Ternary:  79.3% Other:   1.9%)
```


## Analysis

- For some reason we have more choices a conflicts, I am not sure, I thought it could be due to externals but we need to investigate it further. The encodings are super similar so the overhead must be coming from somewhere in the implementation. I thought it could be the externals that it generates but I did a tests and with the original externals it is the same.
