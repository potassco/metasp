#script (python)
from clingo import Number
def match(s, p,a):
    if s.match(str(p), a.number):
        return Number(1)
    else:
        return Number(0)
#end.

% Only explicit show
#show .

% Show signature #show p/n.
#show true(S,T) : show_signature(P,A), true(S,T), @match(S,P,A)=1.
#show true(OG,T) : show_signature(P,A), true(S,T), @match(OG,P,A)=1, original_formula(S,OG).

% Show term #show a: b.
#show true(S,T) : show_term(S,B), conjunction(B,T).

% Default show all atoms
#show true(S,T) : output(S,B), conjunction(B,T), formula(atom,S), not show_signature(_,_), not show.
