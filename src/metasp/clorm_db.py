# -------- Clorm
from clorm import Predicate, ConstantStr, IntegerField, StringField, refine_field, ConstantField, Raw


class ExpressionID(Predicate, is_tuple=True):
    name: ConstantStr
    arity: int


ProgramAppearance = refine_field(
    ConstantField,
    ["any", "head", "body", "none"],
)


class Allow(Predicate):
    """
    Defines a type in the grammar.

    Args:
        name (const): The name of the type.
    """

    type: ConstantStr
    position: ConstantStr


class Type(Predicate):
    """
    Defines a type in the grammar.

    Args:
        name (const): The name of the type.
    """

    name: ConstantStr


class Subtype(Predicate):
    """
    Defines a subtype relationship between two types.
    Args:
        sub (const): The subtype.
        sup (const): The supertype.
    """

    sub: ConstantStr
    sup: ConstantStr


class Expression(Predicate):
    """
    Defines a expression for a type, which can be used as &name(args...) in the logic program.
    Args:
        type (const): The type this expression belongs to.
        id (tuple): The identifier of the expression (name, arity).
        kind (const): Where it might appear: any, head, body, none.
    """

    type: ConstantStr
    id: ExpressionID


class Arg(Predicate):
    """
    Argument information for a expression.

    Args:
        cons_id (tuple): The identifier of the expression this argument belongs to (name, arity).
        index (int): The index of the argument (0-based).
        key (const): The key of the argument (e.g., "type" "safety").
        value (raw): The value of the argument.
    """

    cons_id: ExpressionID
    index: int
    key: ConstantStr
    value: Raw


class Var(Predicate):
    """
    Variable declaration in the grammar to be used in macro

    Args:
        name (const): The name of the variable.
        type (const): The type of the variable, if multiple types are given then all must match.
    """

    name: ConstantStr
    type: ConstantStr


class Macro(Predicate, name="macro"):
    """
    Defines syntactic sugar in the grammar.

    Args:
        type (const): The type that the formula to replace should be in the current context.
            If a context is given then formulas appearing directly in the program are not replaced, since the context there is not known.
            To replace in any context use "any".
        lhs (raw): The pattern to be replaced. Can use any defined variable.
        rhs (raw): The expansion of the pattern. #TODO at the moment this pattern needs to use __ for expressions
    """

    type: ConstantStr
    lhs: Raw
    rhs: Raw


UNIFIERS = [Type, Subtype, Expression, Arg, Var, Macro, ExpressionID, Allow]
