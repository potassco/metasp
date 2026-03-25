# Benchmarks for DEL

Used benchmark from Implementing Dynamic Answer Set Programming over finite traces

Generated with script benchmarks/del/benchmarks.sh to imitate the original benchmakrs.
The tables below are generated with an LLM from the results in the output of the script which can be found in benchmarks/del/results_elevator_out.txt.

```

## Our results

Values shown as **no-control / with-control**.

| λ (horizon) / n (floors) |  ⌊3n+1⌋/2 |    ·+1    |    ·+2    |    ·+3     |     ·+4    | indicators  |
|:------------------------:|----------:|----------:|----------:|-----------:|-----------:|:------------|
| **5**                    |       2/2 |      34/2 |     340/2 |    2618/2  |   17204/2  | models      |
|                          |     78/29 |    245/54 |    774/105|   3747/85  |  20201/79  | choices     |
|                          | 1621/1617 | 1854/1850 | 2087/2083 | 2320/2316  |  2553/2549 | constraints |
| **7**                    |       2/2 |      46/2 |     598/2 |    5796/2  |   46690/2  | models      |
|                          |    474/101|    439/96 |   1908/80 |   8583/114 |  51499/151 | choices     |
|                          | 2530/2526 | 2793/2789 | 3056/3052 | 3319/3315  |  3582/3578 | constraints |
| **9**                    |       2/2 |      58/2 |     928/2 |   10846/2  |  103530/2  | models      |
|                          |     958/68| 2293/250  | 3711/132  |  15075/232 | 112942/264 | choices     |
|                          | 3589/3585 | 3882/3878 | 4175/4171 | 4468/4464  |  4761/4757 | constraints |
| **11**                   |       2/2 |      70/2 |    1330/2 |   18200/2  |  200900/2  | models      |
|                          |   3196/132| 4479/160  | 8131/186  |  27157/175 | 228819/192 | choices     |
|                          | 4798/4794 | 5121/5117 | 5444/5440 | 5767/5763  |  6090/6086 | constraints |


# Original results

Values shown as **no-control / with-control**.

| λ (horizon) / n (floors) |  ⌊3n+1⌋/2 |    ·+1    |    ·+2    |    ·+3     |     ·+4    | indicators  |
|:------------------------:|----------:|----------:|----------:|-----------:|-----------:|:------------|
| **5**                    |       2/2 |      34/2 |     340/2 |    2618/2  |   17204/2  | models      |
|                          |     141/2 |    295/7  |     660/7 |    3183/8  |  19209/11  | choices     |
|                          | 1119/1929 | 1402/2306 | 1717/2715 | 2064/3156  |  2443/3629 | constraints |
| **7**                    |       2/2 |      46/2 |     598/2 |    5796/2  |   46690/2  | models      |
|                          |    453/2  |    842/5  |    1758/6 |    7917/7  |  49982/8   | choices     |
|                          | 2016/3092 | 2391/3561 | 2798/4062 | 3237/4595  |  3708/5160 | constraints |
| **9**                    |       2/2 |      58/2 |     928/2 |   10846/2  |  103530/2  | models      |
|                          |   1560/2  |   2206/7  |    3437/7 |   15171/7  | 112964/9   | choices     |
|                          | 3181/4523 | 3648/5084 | 4147/5677 | 4678/6302  |  5241/6959 | constraints |
| **11**                   |       2/2 |      70/2 |    1330/2 |   18200/2  |  200900/2  | models      |
|                          |   5057/2  |   7896/6  |    7043/7 |   26276/8  | 219391/9   | choices     |
|                          | 4614/6222 | 5173/6875 | 5764/7560 | 6387/8277  |  7042/9026 | constraints |


## Analysis

- Adding the control rule does not reduce the choices and constraints as much as in the original paper, but it still reduces significantly vs no control
- Without the control rule the overall number of choices is reduced almost half with respect to the telingo+del variant
- The number of choices is also reduced by our approach but with a smaller margin.
