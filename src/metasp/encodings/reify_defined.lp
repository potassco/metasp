%*
#atom_tuple(H)
Represents a tuple or set of atoms identified by `H`, without a specified order.

#parameters
- H: Numerical identifier unique within its class.
*%
#defined atom_tuple/1.
%*
#atom_tuple(H, A)
Atom `A` is part of the atom tuple identified by `H`.

#parameters
- H: Numerical identifier for the atom tuple.
- A: Numerical identifier for the atom.
*%
#defined atom_tuple/2.
%*
#literal_tuple(B)
Represents a tuple or set of literals identified by `B`, without a specified order.
A literal can be an atom or a negated atom.

#parameters
- B: Numerical identifier unique within its class.

*%
#defined literal_tuple/1.
%*
#literal_tuple(B, L)
Literal `L` is part of the literal tuple identified by `B`.

#parameters
- B: Numerical identifier for the literal tuple.
- L: Numerical identifier for the literal,
    it is either `-A` or `A`, where `A` is the atom, and the negative symbol represents negation.
*%
#defined literal_tuple/2.

%*
#weighted_literal_tuple(B,L,W)
Literal `L` is part of the literal tuple identified by `B` and has a weight of `W`.

#parameters
- B: Numerical identifier for the literal tuple.
- L: Numerical identifier for the literal,
    it is either `-A` or `A`, where `A` is the atom, and the negative symbol represents negation.
- W: Weight of the literal.

*%

#defined weighted_literal_tuple/3.

%*
#output(O,B)
Specifies that `O` will be output when the literal tuple `B` is true.

#parameters
- O: Value to be output.
- B: Numerical identifier of the literal tuple.

*%

#defined output/2.
%*
#rule(HEAD,BODY)
Represents a rule in ASP, with `HEAD` being either a disjunction or choice of atoms, and `BODY` a conjunction of literals.


#parameters
- HEAD: Type of rule head
    - `disjunction(H)`: Disjunction of atoms.
    - `choice(H)`: Choice among atoms.
- BODY: Conjunction of literals in the rule body.
    - `normal(B)`: Normal body with literals.
    - `sum(B,G)`: Sum body with literals and a threshold.
*%
#defined rule/2.

% #defined theory_number/2.
% #defined theory_string/2.
% #defined theory_function/3.
% #defined theory_atom/3.
% #defined theory_atom/5.
% #defined theory_tuple/1.
% #defined theory_tuple/3.
% #defined theory_sequence/3.
