# -------- Clorm
from clorm import Predicate, ConstantStr, IntegerField, StringField, refine_field, ConstantField, Raw


class ConstructorID(Predicate, is_tuple=True):
    name: ConstantStr
    arity: int


ProgramAppearance = refine_field(
    ConstantField,
    ["any", "head", "body", "none"],
)


class Type(Predicate):
    name: ConstantStr


class Subtype(Predicate):
    sub: ConstantStr
    sup: ConstantStr


class Constructor(Predicate):
    type: ConstantStr
    id: ConstructorID
    kind: ConstantStr


class Arg(Predicate):
    cons_id: ConstructorID
    index: int
    key: ConstantStr
    value: ConstantStr


class Var(Predicate):
    name: ConstantStr
    type: ConstantStr


class DefinedAs(Predicate, name="defined_as"):
    type: ConstantStr
    lhs: Raw
    rhs: Raw


UNIFIERS = [Type, Subtype, Constructor, Arg, Var, DefinedAs, ConstructorID]
