child_index(N,0) :- node(N), not next_sibling(_,N).
child_index(M,I+1) :- child_index(N,I), next_sibling(N,M).

#defined child_index/2.
