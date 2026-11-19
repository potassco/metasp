"""
MetaASP formula processing module used for handling formulas, their types, and syntactic sugar removal.
"""

import logging
from collections.abc import Callable
from dataclasses import dataclass, field
from functools import wraps
from typing import ParamSpec, TypeVar

from clingo import Function, Symbol, SymbolType

from metasp.grammar import Grammar, Type
from metasp.utils.logging_utils import COLORS

log = logging.getLogger(__name__)

P = ParamSpec("P")
R = TypeVar("R")


@dataclass
class Formula:
    """
    Class representing a formula in the MetaASP system.

    Attributes:
        name (str): The name of the formula.
        symbol (Symbol): The clingo symbol representing the formula.
        type (Type): The type of the formula.
        arguments (list[Formula], optional): The arguments of the formula. Defaults to None.
        super_types (list[str], optional): The super types of the formula. Defaults to None.
    """

    name: str
    symbol: Symbol
    type: Type | None
    arguments: list["Formula"] = field(default_factory=list)
    super_types: list[str] = field(default_factory=list)

    @property
    def signature(self) -> tuple[str, int]:
        """
        Get the signature of the formula as a tuple of its name and arity.

        Returns:
            tuple[str, int]: The signature of the formula.
        """
        return (self.name, len(self.symbol.arguments))

    @property
    def used_types(self) -> list[str]:
        """
        Get the list of used types for the formula, including its super types.
        We return it sorted to ensure a consistent order.

        Returns:
            list[str]: The sorted list of used types.
        """
        types = set(([self.type.name] if self.type is not None else []) + self.super_types)
        return sorted(types)

    def symbol_with_prefix(self) -> Symbol:
        """
        Get the symbol of the formula with the appropriate prefix based on its type.
        If the formula is of a base type, the symbol is returned as is.
        Otherwise, a prefix __ is added to the symbol's name.

        Returns:
            Symbol: The symbol with the prefix applied if necessary.
        """
        if self.type is None:
            name = ""
        elif self.type.is_base_type:
            return self.symbol
        else:
            name = f"__{self.symbol.name}"
        return Function(name, [a.symbol_with_prefix() for a in self.arguments], self.symbol.positive)

    def __str__(self) -> str:
        """
        Get the string representation of the formula.

        Returns:
            str: The string representation of the formula.
        """
        return str(self.symbol)


def _print_done_decorator(func: Callable[P, R]) -> Callable[P, R]:
    """
    Decorator to print debug information before and after the execution of a function.

    Args:
        func (Callable): The function to be decorated.

    Returns:
        Callable: The decorated function.
    """

    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        try:
            log.debug("%s", "*" * 30)
            return func(*args, **kwargs)
        finally:
            log.debug("%s\n", "*" * 30)

    return wrapper


def is_tuple(s: Symbol) -> bool:
    """
    Return True if the symbol represents a tuple, False otherwise.

    Args:
        s (Symbol): The symbol to check.

    Returns:
        bool: True if the symbol is a tuple, False otherwise.
    """
    return s.type == SymbolType.Function and s.name == ""


def p(s: object) -> str:
    """
    Pretty-print the symbol with color coding.
    Used for the symbols in the formulas.

    Args:
        s (Symbol): The symbol to pretty-print.

    Returns:
        str: The pretty-printed string representation of the symbol.
    """
    s_str = str(s)
    s_str = s_str.replace("__", "&")
    return f"{COLORS['YELLOW']}{s_str}{COLORS['NORMAL']}{COLORS['GREY']}"


def t(s: object) -> str:
    """
    Pretty-print the symbol with green color coding.
    Used for the types.

    Args:
        s (Symbol): The symbol to pretty-print.

    Returns:
        str: The pretty-printed string representation of the symbol.
    """
    return f"{COLORS['GREEN']}{s!s}{COLORS['NORMAL']}{COLORS['GREY']}"


class FormulaRegistery:
    """
    Registry for managing formulas and their interactions with the grammar.
    """

    def __init__(self, grammar: Grammar):
        """
        Initialize the formula registry with the given grammar.

        Args:
            grammar (Grammar): The grammar to be used for formula processing.
        """
        self._prefix = "__"
        self.grammar = grammar
        self.formulas: dict[str, Formula] = {}

    def add_formula(self, f: Formula) -> Formula:
        """
        Add a formula to the registry. If the formula already exists, merge its super types.

        Args:
            f (Formula): The formula to add.

        Returns:
            Formula: The formula stored in the registry after addition.
        """
        if str(f) in self.formulas:
            existing_formula = self.formulas[str(f)]
            # Merge super types
            existing_formula.super_types = list(set(existing_formula.super_types + f.super_types))
        else:
            self.formulas[str(f)] = f
        return self.formulas[str(f)]

    def remove_syntactic_sugar(self, symbol: Symbol, as_type: str | None = None) -> Symbol:
        """
        Remove syntactic sugar from the given symbol using the grammar's macros.

        Args:
            symbol (Symbol): The symbol to process.
            as_type (str, optional): The type to consider for the symbol.
                    If None then any type can be matched, otherwise only the specified type will be considered.

        Returns:
            Symbol: The symbol with syntactic sugar removed.
            If no syntactic sugar is applicable, returns the original symbol.
        """
        matched_variables: dict[str, Symbol] = {}
        macro = self.grammar.find_macro(symbol, as_type, matched_variables)
        if not macro:
            return symbol
        new_symbol = self.grammar.apply_sugar_with_vars(macro.type, macro.expansion.symbol, matched_variables)
        log.debug(
            "✴️ Removing syntactic sugar of %s using rule %s -> %s",
            p(symbol),
            p(macro.pattern),
            p(macro.expansion),
        )
        log.debug("  New symbol: %s", p(new_symbol))
        return new_symbol

    def assert_type_in(self, as_type: str | None, possible_types: list[str], symbol: Symbol) -> None:
        """
        Assert that the given type is within the list of possible types for the symbol.

        Args:
            as_type (str | None): The type to check.
            possible_types (list[str]): The list of allowed types.
            symbol (Symbol): The symbol being checked.

        Raises:
            ValueError: If the type is not in the list of possible types.
        """
        if as_type is not None and as_type not in possible_types:
            m = f"Type mismatch for symbol {p(symbol)} expected {t(as_type)}, but matches only with: {possible_types}"
            # log.error(m)
            raise ValueError(m)

    def match_top_level(self, s: Symbol) -> Formula | None:
        """
        Match the given symbol at the top level against the allowed types in the grammar.

        Args:
            s (Symbol): The symbol to match.

        Returns:
            Formula: The matched formula if successful, otherwise None.
        """
        possible_types = self.grammar.allowed_types_in_position()
        errors: list[tuple[str, ValueError]] = []
        matched_formulas: dict[str, Formula] = {}
        if len(possible_types) == 0:
            log.warning(
                "No types defined in the grammar to be allowed as atoms in the program."
                "Make sure to define at least one type with allow(X,head) or allow(X,body)."
            )
            return None
        log.debug("\n\033[93m%s\033[0m", "=" * 30)
        log.debug("🟧 Matching -> %s", p(s))
        for possible_type in possible_types:
            log.debug("\033[94m%s\033[0m", "-" * 30)
            log.debug(
                "🔶 Trying to match %s as top level type %s",
                p(s),
                t(possible_type),
            )
            try:
                f = self.match(s, as_type=possible_type)
                if f is not None:
                    log.debug(
                        "✳️ Matched top-level symbol %s as type %s.",
                        p(s),
                        t(possible_type),
                    )
                    matched_formulas[possible_type] = f
            except ValueError as e:
                errors.append((possible_type, e))
                log.debug("Not possible to match with top-level type %s", t(possible_type))

        log.info("Matched %s as types: %s", p(s), list(matched_formulas.keys()))
        if len(matched_formulas) != 0:
            found_formulas = {str(f) for f in matched_formulas.values()}
            if len(found_formulas) > 1:
                log.warning(
                    "Multiple type matches but formula %s, but syntactic sugar led to different formulas: %s. "
                    "This may lead to unexpected results.",
                    p(s),
                    found_formulas,
                )
            return list(matched_formulas.values())[0]
        for type_name, error in errors:
            log.error("Could not match %s as type %s: %s", p(s), t(type_name), error)

        raise ValueError(f"Could not match top-level symbol {p(s)} as any of the allowed types: {possible_types}")

    @_print_done_decorator
    def match(self, s: Symbol, as_type: str | None = None) -> Formula:
        """
        Match the given symbol against the specified type or any compatible type in the grammar.

        Args:
            s (Symbol): The symbol to match.
            as_type (str | None, optional): The type to match against. If None, any compatible type will be considered.

        Returns:
            Formula: The matched formula.

        Raises:
            ValueError: If the symbol cannot be matched as the specified type or any compatible type.
        """
        # pylint: disable=too-many-branches
        # pylint: disable=too-many-nested-blocks
        # pylint: disable=too-many-locals
        # pylint: disable=too-many-statements
        log.debug("▶️ Trying to match symbol %s as type %s", p(s), t(as_type))

        formula_type = self.grammar.get_fl_type(s, as_type=as_type)  # Just to raise error if not valid
        if formula_type is None:
            log.debug("Symbol %s has no direct type or expression, checking syntactic sugar", p(s))
            formula_type = self.grammar.get_fl_type(s, check_sugar=True, as_type=as_type)
            found_sugar = formula_type is not None
            if not found_sugar:
                log.debug("No syntactic sugar found for %s as type %s.", p(s), t(as_type))
                if as_type is not None:
                    subtypes = self.grammar.get_type(as_type).sub_types
                    log.debug(
                        "🔳Checking if it matches subtypes %s of allowed types %s",
                        subtypes,
                        as_type,
                    )
                    for subtype in subtypes:
                        log.debug("▪️Checking if %s matches subtype %s", p(s), t(subtype))
                        try:
                            formula_from_subtype = self.match(s, as_type=subtype)
                            if formula_from_subtype is not None:
                                formula_from_subtype.super_types.append(as_type)

                                return formula_from_subtype
                        except ValueError:
                            continue
                raise ValueError(
                    f"No expression or syntactic sugar found for symbol {p(s)}. "
                    f"as type {t(as_type)} or any of its subtypes."
                )
            new_symbol = self.remove_syntactic_sugar(s, as_type=as_type)
            same_symbol = new_symbol == s
            if same_symbol:
                m = f"Symbol {p(s)} was not changed by syntactic sugar removal. This would lead to infinite recursion."
                raise ValueError(m)
            log.debug("Syntactic sugar removed for %s, matching new symbol %s", p(s), p(new_symbol))
            new_formula = self.match(new_symbol, as_type=as_type)
            return self.add_formula(new_formula)

        # try:
        #     print(f"Checking if symbol {p(s)} of type {t(as_type)} is in {self.grammar.all_types(formula_type)}")
        #     self.assert_type_in(as_type, self.grammar.all_types(formula_type), s)
        # except ValueError as e:
        #     log.debug("No match of symbol %s as type %s: %s. Will try to remove sugar.", p(s), t(as_type), e)
        #     new_symbol = self.remove_syntactic_sugar(s, as_type=as_type)
        #     if new_symbol == s:
        #         log.debug("No syntactic sugar removed for %s", p(s))
        #         raise e
        #     log.debug(
        #         "Syntactic sugar removed for %s, matching new symbol %s",
        #         p(s),
        #         p(new_symbol),
        #     )
        #     return self.match(new_symbol, as_type=as_type)

        if formula_type.is_base_type:
            log.debug("✅ Symbol %s is base type %s, returning directly", p(s), t(formula_type.name))
            # new_symbol = self.remove_syntactic_sugar(s, as_type=as_type)
            new_formula = Formula(
                name=str(s),
                symbol=s,
                type=formula_type,
                arguments=[],
                super_types=[as_type] if as_type is not None else [],
            )
            return self.add_formula(new_formula)

        # --------- Recursive case
        name = s.name[len(self._prefix) :]
        arity = len(s.arguments)
        expression = self.grammar.get_expression(name, arity)
        if expression is None:
            raise ValueError(f"No expression definition found for {name}/{arity}.")
        # --------- Match arguments
        log.debug("☑️ Matched expression %s of type %s", p(expression.name), t(expression.type_name))
        log.debug("  Trying to match arguments...")
        arguments = []
        for i, a in enumerate(s.arguments):
            arg_defs = expression.args.get(i, None)
            arg_expected_types = [arg.value for arg in arg_defs or [] if arg.key == "type"]
            if len(arg_expected_types) > 1:
                # TODO This could be a check when the grammar is created
                log.warning(
                    "Multiple expected types for argument %s of expression %s",
                    i,
                    expression.name,
                )
                raise ValueError("Multiple expected types not supported ")
            if len(arg_expected_types) == 0:
                log.warning(
                    "No fixed type for argument %s of expression %s",
                    i,
                    expression.name,
                )
                expected_type = None
            else:
                expected_type = arg_expected_types[0]
            try:
                args_to_match: list[Symbol]
                expected_types: list[Symbol | None]
                if is_tuple(a):
                    if expected_type is None:
                        raise ValueError("No expected type is defined for tuple argument")
                    if not is_tuple(expected_type.symbol):
                        log.error(
                            "Type mismatch for argument %s of expression %s in %s: expected %s, got tuple %s",
                            i,
                            expression.name,
                            s,
                            t(expected_type),
                            a,
                        )
                        raise ValueError("Type mismatch: expected non-tuple, got tuple")
                    args_to_match = a.arguments
                    expected_types = expected_type.symbol.arguments
                else:
                    args_to_match = [a]
                    expected_types = [None if expected_type is None else expected_type.symbol]
                final_args = []
                for arg, expected in zip(args_to_match, expected_types):
                    expected_type_name = None if expected is None else str(expected)
                    arg_formula = self.match(arg, as_type=expected_type_name)
                    if arg_formula is None:
                        raise ValueError("No match found for argument")
                    final_args.append(arg_formula)

                arg_formula = (
                    final_args[0]
                    if not is_tuple(a)
                    else Formula(
                        name="",
                        symbol=Function("", [f.symbol for f in final_args], True),
                        arguments=final_args,
                        type=None,
                    )
                )
                arguments.append(arg_formula)
            except ValueError as e:
                log.error("Could not match argument %s of %s: %s", p(a), p(s), e)
                raise e
        log.debug("  All arguments matched!")
        log.debug(
            "✅ Symbol %s is type %s, with expression (%s,%s)",
            p(s),
            t(formula_type.name),
            expression.name,
            expression.arity,
        )
        new_symbol_fun = Function(name, [a.symbol for a in arguments], s.positive)
        formula = Formula(
            name=name,
            symbol=new_symbol_fun,
            type=formula_type,
            arguments=arguments,
            super_types=[as_type] if as_type is not None else [],
        )
        return self.add_formula(formula)
