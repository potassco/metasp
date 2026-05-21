# Benchmarks

The instances and encodings for the benchmarks can be found in the `instances` directory.

The benchmarks were run using the [Potassco Benchmark Tool](https://potassco.org/benchmark-tool/).
To run the benchmarks for both the TEL and DEL domains, one must run the following scripts.

```bash
./gen-all.sh
./eval-all.sh
```

## Specs

- Metasp ran using [metasp v1.0.0](https://github.com/potassco/metasp/releases/tag/v1.0.0)
- Telingo ran using [telingo-lambda v2.1.3](https://github.com/krr-up/telingo-lambda/releases/tag/v2.1.3)


## TEL results

Results for 6 different domains found in [instances/tel](instances/tel).

### Metasp

| Instance | time | stime | status | rules | choices | conflicts |
|----------|------|-------|--------|-------|---------|-----------|
| hanoi/0004-hanoi_tower-60-0 | 13.85 | 8.39 | SATISFIABLE | 695,126 | 173,412 | 125,898 |
| hanoi/0005-hanoi_tower-60-0 | 796.46 | 789.99 | SATISFIABLE | 903,324 | 5,527,312 | 4,555,659 |
| hanoi/0007-hanoi_tower-60-0 | 759.31 | 752.59 | SATISFIABLE | 960,098 | 6,331,446 | 5,083,642 |
| hanoi/0008-hanoi_tower-60-0 | 268.72 | 260.71 | SATISFIABLE | 1,111,514 | 4,480,956 | 2,313,944 |
| hanoi/0013-hanoi_tower-32-0 | 9.72 | 4.58 | SATISFIABLE | 565,968 | 104,744 | 78,750 |
| hanoi/0021-hanoi_tower-40-0 | 28.81 | 24.08 | SATISFIABLE | 565,968 | 336,080 | 279,818 |
| hanoi/0022-hanoi_tower-60-0 | 7.66 | 2.63 | SATISFIABLE | 449,092 | 55,675 | 45,172 |
| hanoi/0023-hanoi_tower-60-0 | 7.13 | 2.68 | SATISFIABLE | 486,944 | 55,827 | 45,338 |
| hanoi/0025-hanoi_tower-60-0 | 10.86 | 6.15 | SATISFIABLE | 524,796 | 106,489 | 86,380 |
| hanoi/0032-hanoi_tower-60-0 | 8.26 | 3.32 | SATISFIABLE | 617,837 | 67,430 | 50,393 |
| hanoi/0036-hanoi_tower-80-0 | 7.03 | 2.30 | SATISFIABLE | 531,390 | 91,703 | 43,910 |
| hanoi/0039-hanoi_tower-80-0 | 12.26 | 7.25 | SATISFIABLE | 600,546 | 215,029 | 99,232 |
| hanoi/0040-hanoi_tower-80-0 | 13.14 | 8.19 | SATISFIABLE | 617,841 | 267,181 | 122,819 |
| hanoi/0046-hanoi_tower-100-0 | 25.89 | 20.24 | SATISFIABLE | 600,550 | 296,547 | 238,063 |
| hanoi/0047-hanoi_tower-120-0 | 6.46 | 2.33 | SATISFIABLE | 410,353 | 50,656 | 39,271 |
| hanoi/0048-hanoi_tower-120-0 | 9.13 | 4.99 | SATISFIABLE | 444,927 | 97,679 | 77,770 |
| hanoi/0050-hanoi_tower-120-0 | 10.19 | 5.79 | SATISFIABLE | 496,804 | 115,095 | 88,848 |
| hanoi/0056-hanoi_tower-120-0 | 371.20 | 366.05 | SATISFIABLE | 669,722 | 3,178,478 | 2,701,641 |
| hanoi/0059-hanoi_tower-120-0 | 1,200.00 | 1,194.34 | UNKNOWN | 756,181 | 6,508,284 | 5,554,640 |
| hanoi/0060-hanoi_tower-120-0 | 1,200.00 | 1,193.99 | UNKNOWN | 773,468 | 5,703,892 | 4,851,919 |
| labyrinth/0025-labyrinth-14-0 | 10.34 | 1.23 | SATISFIABLE | 286,046 | 6,784 | 4,753 |
| labyrinth/0045-labyrinth-11-0 | 6.76 | 0.93 | SATISFIABLE | 204,062 | 8,178 | 4,930 |
| labyrinth/0060-labyrinth-13-0 | 8.43 | 0.23 | SATISFIABLE | 246,305 | 1,409 | 950 |
| labyrinth/0075-labyrinth-13-0 | 14.54 | 6.16 | SATISFIABLE | 292,438 | 32,076 | 19,309 |
| labyrinth/0082-labyrinth-14-0 | 323.51 | 314.29 | SATISFIABLE | 342,344 | 715,383 | 604,229 |
| labyrinth/0094-labyrinth-17-0 | 52.53 | 38.59 | SATISFIABLE | 510,266 | 63,949 | 45,749 |
| labyrinth/0130-labyrinth-14-0 | 600.23 | 590.57 | SATISFIABLE | 393,248 | 961,380 | 754,933 |
| nomystery/0006-nomystery-55-0 | 10.15 | 6.73 | SATISFIABLE | 186,145 | 121,220 | 54,996 |
| nomystery/0007-nomystery-57-0 | 4.18 | 0.91 | SATISFIABLE | 162,791 | 21,734 | 9,365 |
| nomystery/0009-nomystery-63-0 | 5.10 | 1.84 | SATISFIABLE | 174,413 | 56,996 | 19,556 |
| nomystery/0012-nomystery-84-0 | 54.95 | 49.63 | SATISFIABLE | 406,463 | 891,808 | 194,549 |
| nomystery/0014-nomystery-73-0 | 185.22 | 180.62 | SATISFIABLE | 372,039 | 2,731,069 | 515,991 |
| nomystery/0024-nomystery-86-0 | 1,200.00 | 1,192.93 | UNKNOWN | 816,633 | 15,358,213 | 1,972,354 |
| nomystery/0025-nomystery-85-0 | 1,200.00 | 1,192.44 | UNKNOWN | 827,194 | 16,683,723 | 2,259,262 |
| nomystery/0031-nomystery-52-0 | 3.33 | 0.54 | SATISFIABLE | 104,771 | 16,389 | 8,181 |
| nomystery/0033-nomystery-32-0 | 3.35 | 0.12 | SATISFIABLE | 91,117 | 3,571 | 1,827 |
| nomystery/0034-nomystery-64-0 | 4.16 | 0.75 | SATISFIABLE | 108,549 | 16,445 | 8,910 |
| nomystery/0037-nomystery-36-0 | 11.62 | 8.39 | SATISFIABLE | 169,063 | 142,272 | 67,920 |
| nomystery/0038-nomystery-63-0 | 10.75 | 7.17 | SATISFIABLE | 210,467 | 119,076 | 52,847 |
| nomystery/0039-nomystery-42-0 | 4.73 | 1.75 | SATISFIABLE | 130,211 | 53,633 | 24,705 |
| nomystery/0041-nomystery-88-0 | 65.63 | 60.43 | SATISFIABLE | 423,092 | 1,145,844 | 200,045 |
| nomystery/0042-nomystery-56-0 | 86.91 | 82.75 | SATISFIABLE | 322,422 | 1,648,642 | 324,281 |
| nomystery/0045-nomystery-44-0 | 19.62 | 15.70 | SATISFIABLE | 244,564 | 245,461 | 115,203 |
| ricochetrobot/018-ricochetrobot-14-0 | 118.19 | 112.34 | SATISFIABLE | 388,580 | 425,214 | 280,395 |
| ricochetrobot/025-ricochetrobot-14-0 | 818.91 | 813.42 | SATISFIABLE | 388,580 | 5,604,581 | 1,900,678 |
| ricochetrobot/030-ricochetrobot-16-0 | 223.16 | 216.89 | SATISFIABLE | 440,228 | 3,714,881 | 633,596 |
| ricochetrobot/038-ricochetrobot-13-0 | 11.20 | 5.28 | SATISFIABLE | 362,756 | 60,181 | 23,250 |
| ricochetrobot/040-ricochetrobot-14-0 | 21.68 | 15.22 | SATISFIABLE | 388,580 | 492,284 | 63,751 |
| ricochetrobot/046-ricochetrobot-13-0 | 21.08 | 15.29 | SATISFIABLE | 362,756 | 119,192 | 57,068 |
| ricochetrobot/059-ricochetrobot-15-0 | 45.52 | 39.62 | SATISFIABLE | 414,404 | 1,052,636 | 147,840 |
| ricochetrobot/060-ricochetrobot-14-0 | 1,200.00 | 1,194.59 | UNKNOWN | 388,580 | 6,129,038 | 2,325,995 |
| ricochetrobot/061-ricochetrobot-14-0 | 62.49 | 57.05 | SATISFIABLE | 388,580 | 1,190,838 | 190,795 |
| ricochetrobot/084-ricochetrobot-15-0 | 117.21 | 111.62 | SATISFIABLE | 414,404 | 2,091,424 | 350,364 |
| ricochetrobot/230-ricochetrobot-17-0 | 319.46 | 313.07 | SATISFIABLE | 466,052 | 4,003,307 | 879,335 |
| sokoban/0096-sokoban-36-1 | 1,200.00 | 1,193.34 | UNKNOWN | 546,970 | 6,085,502 | 5,014,229 |
| sokoban/0103-sokoban-110-1 | 4.93 | 0.01 | SATISFIABLE | 132,547 | 333 | 186 |
| sokoban/0119-sokoban-42-1 | 71.24 | 66.24 | SATISFIABLE | 247,269 | 738,759 | 559,728 |
| sokoban/0128-sokoban-131-1 | 5.01 | 0.04 | SATISFIABLE | 125,276 | 1,303 | 693 |
| sokoban/0272-sokoban-135-1 | 5.21 | 0.27 | SATISFIABLE | 162,316 | 7,161 | 4,354 |
| sokoban/0428-sokoban-120-1 | 1,200.00 | 1,194.89 | UNKNOWN | 262,052 | 4,303,433 | 3,609,569 |
| sokoban/0516-sokoban-200-1 | 5.28 | 0.45 | SATISFIABLE | 198,163 | 11,595 | 7,308 |
| visitall/0009-visitall-36-1 | 199.77 | 196.45 | SATISFIABLE | 189,427 | 611,827 | 497,185 |
| visitall/0012-visitall-36-1 | 70.95 | 67.73 | SATISFIABLE | 201,762 | 364,766 | 280,799 |
| visitall/0029-visitall-39-1 | 101.42 | 98.44 | SATISFIABLE | 194,825 | 492,510 | 394,686 |
| visitall/0030-visitall-39-1 | 74.28 | 71.23 | SATISFIABLE | 189,427 | 373,581 | 294,566 |
| visitall/0031-visitall-39-1 | 34.18 | 31.16 | SATISFIABLE | 197,849 | 243,681 | 181,868 |
| visitall/0070-visitall-49-1 | 124.56 | 121.53 | SATISFIABLE | 193,313 | 489,422 | 390,100 |
| visitall/0071-visitall-49-1 | 29.72 | 26.33 | SATISFIABLE | 201,777 | 235,474 | 174,603 |
| visitall/0089-visitall-66-1 | 72.62 | 69.49 | SATISFIABLE | 190,897 | 399,617 | 314,375 |


## Telingo

# Results Table

| Instance | time | stime | status | rules | choices | conflicts |
|----------|------|-------|--------|-------|---------|-----------|
| hanoi/0004-hanoi_tower-60-0 | 193.64 | 193.22 | SATISFIABLE | 70,910 | 1,925,075 | 1,643,115 |
| hanoi/0005-hanoi_tower-60-0 | 116.93 | 116.46 | SATISFIABLE | 92,767 | 2,437,142 | 1,323,939 |
| hanoi/0007-hanoi_tower-60-0 | 863.21 | 862.70 | SATISFIABLE | 98,728 | 5,985,133 | 5,128,148 |
| hanoi/0008-hanoi_tower-60-0 | 621.66 | 621.01 | SATISFIABLE | 114,624 | 7,805,034 | 4,346,693 |
| hanoi/0013-hanoi_tower-32-0 | 14.76 | 14.37 | SATISFIABLE | 57,454 | 260,457 | 208,621 |
| hanoi/0021-hanoi_tower-40-0 | 53.80 | 53.36 | SATISFIABLE | 57,458 | 711,101 | 590,172 |
| hanoi/0022-hanoi_tower-60-0 | 2.40 | 2.05 | SATISFIABLE | 45,079 | 53,207 | 42,972 |
| hanoi/0023-hanoi_tower-60-0 | 2.47 | 2.10 | SATISFIABLE | 49,053 | 50,247 | 39,928 |
| hanoi/0025-hanoi_tower-60-0 | 5.30 | 4.91 | SATISFIABLE | 53,027 | 101,242 | 81,173 |
| hanoi/0032-hanoi_tower-60-0 | 3.73 | 3.31 | SATISFIABLE | 62,890 | 71,866 | 53,966 |
| hanoi/0036-hanoi_tower-80-0 | 3.49 | 3.15 | SATISFIABLE | 53,828 | 111,060 | 61,363 |
| hanoi/0039-hanoi_tower-80-0 | 5.08 | 4.72 | SATISFIABLE | 61,080 | 208,174 | 95,433 |
| hanoi/0040-hanoi_tower-80-0 | 12.73 | 12.18 | SATISFIABLE | 62,893 | 272,956 | 179,673 |
| hanoi/0046-hanoi_tower-100-0 | 17.99 | 17.62 | SATISFIABLE | 61,084 | 301,971 | 236,618 |
| hanoi/0047-hanoi_tower-120-0 | 2.04 | 1.67 | SATISFIABLE | 41,141 | 47,483 | 36,247 |
| hanoi/0048-hanoi_tower-120-0 | 12.07 | 11.71 | SATISFIABLE | 44,767 | 212,602 | 175,432 |
| hanoi/0050-hanoi_tower-120-0 | 13.83 | 13.43 | SATISFIABLE | 50,206 | 223,064 | 179,048 |
| hanoi/0056-hanoi_tower-120-0 | 225.04 | 224.64 | SATISFIABLE | 68,336 | 2,358,648 | 1,951,012 |
| hanoi/0059-hanoi_tower-120-0 | 1,200.00 | 1,199.55 | UNKNOWN | 77,401 | 7,840,150 | 6,407,408 |
| hanoi/0060-hanoi_tower-120-0 | 1,200.00 | 1,199.38 | UNKNOWN | 79,214 | 14,280,542 | 8,414,164 |
| labyrinth/0025-labyrinth-14-0 | 1.66 | 1.26 | SATISFIABLE | 23,668 | 9,624 | 6,775 |
| labyrinth/0045-labyrinth-11-0 | 3.66 | 3.33 | SATISFIABLE | 17,964 | 28,080 | 18,788 |
| labyrinth/0060-labyrinth-13-0 | 1.07 | 0.71 | SATISFIABLE | 20,391 | 6,035 | 4,216 |
| labyrinth/0075-labyrinth-13-0 | 26.53 | 26.08 | SATISFIABLE | 25,798 | 155,549 | 90,185 |
| labyrinth/0082-labyrinth-14-0 | 47.37 | 46.96 | SATISFIABLE | 30,218 | 231,329 | 167,717 |
| labyrinth/0094-labyrinth-17-0 | 13.43 | 12.95 | SATISFIABLE | 45,012 | 47,940 | 29,758 |
| labyrinth/0130-labyrinth-14-0 | 31.21 | 30.80 | SATISFIABLE | 36,306 | 165,717 | 99,348 |
| nomystery/0006-nomystery-55-0 | 9.70 | 9.37 | SATISFIABLE | 34,776 | 373,835 | 77,123 |
| nomystery/0007-nomystery-57-0 | 1.21 | 0.92 | SATISFIABLE | 29,242 | 18,933 | 9,785 |
| nomystery/0009-nomystery-63-0 | 3.50 | 3.21 | SATISFIABLE | 30,490 | 80,853 | 33,145 |
| nomystery/0012-nomystery-84-0 | 44.94 | 44.54 | SATISFIABLE | 86,792 | 925,576 | 175,867 |
| nomystery/0014-nomystery-73-0 | 76.59 | 76.22 | SATISFIABLE | 77,355 | 1,809,757 | 286,721 |
| nomystery/0024-nomystery-86-0 | 1,183.71 | 1,183.10 | SATISFIABLE | 175,364 | 11,914,189 | 1,686,136 |
| nomystery/0025-nomystery-85-0 | 1,200.00 | 1,199.45 | UNKNOWN | 175,473 | 17,833,958 | 2,430,827 |
| nomystery/0031-nomystery-52-0 | 1.02 | 0.74 | SATISFIABLE | 18,289 | 20,352 | 11,406 |
| nomystery/0033-nomystery-32-0 | 0.66 | 0.31 | SATISFIABLE | 15,126 | 8,399 | 4,809 |
| nomystery/0034-nomystery-64-0 | 0.62 | 0.33 | SATISFIABLE | 19,228 | 8,416 | 4,449 |
| nomystery/0037-nomystery-36-0 | 8.40 | 8.04 | SATISFIABLE | 28,778 | 151,556 | 74,844 |
| nomystery/0038-nomystery-63-0 | 5.66 | 5.35 | SATISFIABLE | 41,072 | 254,508 | 41,443 |
| nomystery/0039-nomystery-42-0 | 1.54 | 1.25 | SATISFIABLE | 23,663 | 31,728 | 16,164 |
| nomystery/0041-nomystery-88-0 | 40.02 | 39.62 | SATISFIABLE | 93,023 | 1,524,493 | 179,514 |
| nomystery/0042-nomystery-56-0 | 59.88 | 59.51 | SATISFIABLE | 63,855 | 1,188,131 | 285,787 |
| nomystery/0045-nomystery-44-0 | 11.06 | 10.73 | SATISFIABLE | 46,839 | 179,168 | 81,641 |
| ricochetrobot/018-ricochetrobot-14-0 | 40.12 | 39.68 | SATISFIABLE | 42,612 | 255,117 | 150,327 |
| ricochetrobot/025-ricochetrobot-14-0 | 380.77 | 380.39 | SATISFIABLE | 42,612 | 1,224,752 | 888,705 |
| ricochetrobot/030-ricochetrobot-16-0 | 367.69 | 367.21 | SATISFIABLE | 48,946 | 1,179,187 | 816,668 |
| ricochetrobot/038-ricochetrobot-13-0 | 6.79 | 6.43 | SATISFIABLE | 39,445 | 70,019 | 30,339 |
| ricochetrobot/040-ricochetrobot-14-0 | 38.59 | 38.15 | SATISFIABLE | 42,612 | 242,469 | 135,050 |
| ricochetrobot/046-ricochetrobot-13-0 | 7.72 | 7.31 | SATISFIABLE | 39,445 | 78,190 | 35,031 |
| ricochetrobot/059-ricochetrobot-15-0 | 82.28 | 81.89 | SATISFIABLE | 45,779 | 399,027 | 243,659 |
| ricochetrobot/060-ricochetrobot-14-0 | 52.76 | 52.39 | SATISFIABLE | 42,612 | 288,222 | 176,831 |
| ricochetrobot/061-ricochetrobot-14-0 | 15.68 | 15.24 | SATISFIABLE | 42,612 | 132,036 | 64,056 |
| ricochetrobot/084-ricochetrobot-15-0 | 21.21 | 20.82 | SATISFIABLE | 45,779 | 162,543 | 83,872 |
| ricochetrobot/230-ricochetrobot-17-0 | 1,200.00 | 1,199.62 | UNKNOWN | 52,113 | 2,571,332 | 1,899,285 |
| sokoban/0096-sokoban-36-1 | 577.75 | 576.43 | SATISFIABLE | 94,286 | 4,347,795 | 3,414,897 |
| sokoban/0103-sokoban-110-1 | 0.42 | 0.01 | SATISFIABLE | 22,790 | 734 | 363 |
| sokoban/0119-sokoban-42-1 | 48.99 | 48.26 | SATISFIABLE | 41,791 | 695,450 | 504,960 |
| sokoban/0128-sokoban-131-1 | 0.59 | 0.13 | SATISFIABLE | 22,067 | 4,546 | 2,629 |
| sokoban/0272-sokoban-135-1 | 0.65 | 0.21 | SATISFIABLE | 26,344 | 5,834 | 3,825 |
| sokoban/0428-sokoban-120-1 | 1,200.00 | 1,199.08 | UNKNOWN | 43,242 | 8,126,740 | 6,715,929 |
| sokoban/0516-sokoban-200-1 | 1.70 | 1.07 | SATISFIABLE | 35,660 | 22,668 | 15,630 |
| visitall/0009-visitall-36-1 | 46.85 | 46.42 | SATISFIABLE | 133,187 | 379,112 | 286,498 |
| visitall/0012-visitall-36-1 | 400.04 | 399.64 | SATISFIABLE | 143,615 | 1,671,487 | 1,344,737 |
| visitall/0029-visitall-39-1 | 111.20 | 110.80 | SATISFIABLE | 137,107 | 692,404 | 533,821 |
| visitall/0030-visitall-39-1 | 94.44 | 94.01 | SATISFIABLE | 133,187 | 630,304 | 490,490 |
| visitall/0031-visitall-39-1 | 164.31 | 163.88 | SATISFIABLE | 142,143 | 949,026 | 737,846 |
| visitall/0070-visitall-49-1 | 78.65 | 78.22 | SATISFIABLE | 134,589 | 545,140 | 422,832 |
| visitall/0071-visitall-49-1 | 186.93 | 186.51 | SATISFIABLE | 143,617 | 1,093,035 | 846,879 |
| visitall/0089-visitall-66-1 | 69.67 | 69.24 | SATISFIABLE | 135,633 | 483,135 | 370,546 |

## DEL results

Results for the elevator domain (DEL) are shown below.
Instances are named as `fX-nY`, where `X` is the number of floors and `Y` is the horizon.
Values are shown as **Without Control / With Control**.

### Metasp


| Instance | time | models | choices | constraints |
|----------|------|--------|---------|-------------|
| f5-n10 | 2.92/3.05 | 340/2 | 686/105 | 885/2,083 |
| f5-n11 | 2.88/3.05 | 2,618/2 | 3,332/85 | 989/2,316 |
| f5-n12 | 2.81/3.07 | 17,204/2 | 18,633/79 | 1,093/2,549 |
| f5-n8 | 2.86/3.04 | 2/2 | 75/29 | 677/1,617 |
| f5-n9 | 2.79/3.02 | 34/2 | 177/54 | 781/1,850 |
| f7-n11 | 2.72/3.12 | 2/2 | 326/101 | 1,212/2,526 |
| f7-n12 | 2.88/3.02 | 46/2 | 578/96 | 1,346/2,789 |
| f7-n13 | 2.76/3.51 | 598/2 | 1,713/80 | 1,480/3,052 |
| f7-n14 | 2.86/3.09 | 5,796/2 | 7,434/114 | 1,614/3,315 |
| f7-n15 | 3.05/3.04 | 46,690/2 | 49,756/151 | 1,748/3,578 |
| f9-n14 | 2.86/3.06 | 2/2 | 979/68 | 1,897/3,585 |
| f9-n15 | 2.80/3.07 | 58/2 | 1,237/250 | 2,061/3,878 |
| f9-n16 | 2.93/3.10 | 928/2 | 3,634/132 | 2,225/4,171 |
| f9-n17 | 3.00/3.13 | 10,846/2 | 13,862/232 | 2,389/4,464 |
| f9-n18 | 3.45/3.05 | 103,530/2 | 111,290/264 | 2,553/4,757 |
| f11-n17 | 3.00/3.06 | 2/2 | 4,127/132 | 2,732/4,794 |
| f11-n18 | 2.94/3.10 | 70/2 | 3,598/160 | 2,926/5,117 |
| f11-n19 | 3.02/2.97 | 1,330/2 | 8,214/186 | 3,120/5,440 |
| f11-n20 | 3.17/3.09 | 18,200/2 | 26,038/175 | 3,314/5,763 |
| f11-n21 | 4.39/3.08 | 200,900/2 | 214,840/192 | 3,508/6,086 |


### Telingo


| Instance | time | models | choices | constraints |
|----------|------|--------|---------|-------------|
| f5-n10 | 0.25/0.26 | 340/2 | 627/23 | 832/1,755 |
| f5-n11 | 0.26/0.26 | 2,618/2 | 3,222/27 | 924/1,932 |
| f5-n12 | 0.32/0.26 | 17,204/2 | 18,163/31 | 1,016/2,109 |
| f5-n8 | 0.24/0.29 | 2/2 | 60/20 | 648/1,401 |
| f5-n9 | 0.25/0.25 | 34/2 | 210/31 | 740/1,578 |
| f7-n11 | 0.25/0.26 | 2/2 | 330/27 | 1,131/2,132 |
| f7-n12 | 0.25/0.26 | 46/2 | 765/30 | 1,251/2,337 |
| f7-n13 | 0.26/0.26 | 598/2 | 1,729/34 | 1,371/2,542 |
| f7-n14 | 0.28/0.26 | 5,796/2 | 7,029/38 | 1,491/2,747 |
| f7-n15 | 0.45/0.27 | 46,690/2 | 48,860/40 | 1,611/2,952 |
| f9-n14 | 0.26/0.26 | 2/2 | 955/37 | 1,754/3,003 |
| f9-n15 | 0.27/0.32 | 58/2 | 1,721/38 | 1,902/3,236 |
| f9-n16 | 0.28/0.27 | 928/2 | 3,457/41 | 2,050/3,469 |
| f9-n17 | 0.36/0.27 | 10,846/2 | 15,619/42 | 2,198/3,702 |
| f9-n18 | 0.76/0.27 | 103,530/2 | 107,886/45 | 2,346/3,935 |
| f11-n17 | 0.28/0.27 | 2/2 | 1,931/41 | 2,517/4,014 |
| f11-n18 | 0.34/0.27 | 70/2 | 4,889/45 | 2,693/4,275 |
| f11-n19 | 0.44/0.27 | 1,330/2 | 11,176/46 | 2,869/4,536 |
| f11-n20 | 0.51/0.28 | 18,200/2 | 26,409/46 | 3,045/4,797 |
| f11-n21 | 1.48/0.28 | 200,900/2 | 216,908/50 | 3,221/5,058 |



