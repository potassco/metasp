%*
atom_tuple(H)
.............
Represents a tuple or set of atoms identified by `H`, without a specified order.

Args:
    H (int): Numerical identifier unique within its class.
*%
#defined atom_tuple/1.

%*
atom_tuple(H, A)
................
Atom `A` is part of the atom tuple identified by `H`.

Args:
    H (int): Numerical identifier for the atom tuple.
    A (int): Numerical identifier for the atom.
*%
#defined atom_tuple/2.

%*
literal_tuple(B)
................
Represents a tuple or set of literals identified by `B`, without a specified order.
A literal can be an atom or a negated atom.

Args:
    B (int): Numerical identifier unique within its class.
*%
#defined literal_tuple/1.

%*
literal_tuple(B, L)
...................
Literal `L` is part of the literal tuple identified by `B`.

Args:
    B (int): Numerical identifier for the literal tuple.
    L (int): Numerical identifier for the literal,
        it is either `-A` or `A`, where `A` is the atom, and the negative symbol represents negation.
*%
#defined literal_tuple/2.

%*
weighted_literal_tuple(B, L, W)
...............................
Literal `L` is part of the literal tuple identified by `B` and has a weight of `W`.

Args:
    B (int): Numerical identifier for the literal tuple.
    L (int): Numerical identifier for the literal,
        it is either `-A` or `A`, where `A` is the atom, and the negative symbol represents negation.
    W (int): Weight of the literal.
*%
#defined weighted_literal_tuple/3.

%*
output(O, B)
............
Specifies that `O` will be output when the literal tuple `B` is true.

Args:
    O (atom): Value to be output.
    B (int): Numerical identifier of the literal tuple.
*%
#defined output/2.

%*
rule(HEAD, BODY)
................
Represents a rule in ASP, with `HEAD` being either a disjunction or choice of atoms, and `BODY` a conjunction of literals.

Args:
    HEAD (atom): Type of rule head

     - `disjunction(H)`: Disjunction of atoms.
     - `choice(H)`: Choice among atoms.
    BODY (atom): Conjunction of literals in the rule body.

     - `normal(B)`: Normal body with literals.
     - `sum(B, G)`: Sum body with literals and a threshold.
*%
#defined rule/2.
%*
theory_number(ID, N)
....................
Represents a theory number symbol.

Args:
    ID (int): Unique identifier for the theory symbol.
    N (int): Integer value of the number.
*%
#defined theory_number/2.

%*
theory_string(ID, STR)
......................
Represents a theory string symbol.

Args:
    ID (int): Unique identifier for the theory symbol.
    STR (string): String value. Used for function names, operators, or string content.
*%
#defined theory_string/2.

%*
theory_function(ID, ID_STR, ID_TUPLE)
.....................................
Represents a theory function symbol.

Args:
    ID (int): Unique identifier for the theory symbol.
    ID_STR (int): Identifier of the theory_string for the function name.
    ID_TUPLE (int): Identifier of the theory_tuple for the function arguments.
*%
#defined theory_function/3.

%*
theory_atom(ID, ID_STR, ID_ET)
..............................
Represents a theory atom without a guard.

Args:
    ID (int): Unique identifier for the theory atom.
    ID_STR (int): Identifier of the theory_string for the atom name.
    ID_ET (int): Identifier of the theory_element_tuple for the elements inside the brackets.
*%
#defined theory_atom/3.

%*
theory_atom(ID, ID_STR, ID_ET, ID_GUARD, ID_SYMBOL)
...................................................
Represents a theory atom with a guard.

Args:
    ID (int): Unique identifier for the theory atom.
    ID_STR (int): Identifier of the theory_string for the atom name.
    ID_ET (int): Identifier of the theory_element_tuple for the elements inside the brackets (left-hand side).
    ID_GUARD (int): Identifier of the theory_string for the guard name (e.g., "=").
    ID_SYMBOL (int): Identifier of the theory symbol for the right-hand side of the guard.
*%
#defined theory_atom/5.

%*
theory_tuple(ID)
................
Defines a theory tuple.

Args:
    ID (int): Unique identifier for the theory tuple.
*%
#defined theory_tuple/1.

%*
theory_tuple(ID, POS, ID_SYMBOL)
...............................
Specifies the symbol at a position in a theory tuple.

Args:
    ID (int): Identifier of the theory tuple.
    POS (int): Position index (integer).
    ID_SYMBOL (int): Identifier of the theory symbol at this position.
*%
#defined theory_tuple/3.

%*
theory_sequence(ID, tuple, ID_TUPLE)
....................................
Represents a theory function without a name (tuple).

Args:
    ID (int): Unique identifier for the theory symbol.
    tuple (atom): Constant atom indicating this is a tuple (function without name).
    ID_TUPLE (int): Identifier of the theory_tuple for the arguments.
*%
#defined theory_sequence/3.
