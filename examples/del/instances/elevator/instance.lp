% Base instance, the DEL paper varies nfloors 5,7,9,11
#const nfloors = 5.
floor(1..nfloors).
at((nfloors+1)/2):-&initial.
called(1;nfloors):-&initial.
