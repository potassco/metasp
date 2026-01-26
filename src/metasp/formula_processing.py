from dataclasses import dataclass
from re import match
from typing import Dict, List
from clingox.reify import Reifier
from clingo import Control, Symbol
from collections.abc import Callable, Sequence
from metasp.grammar import Grammar, Type
from clingo import SymbolType, Function
from metasp.utils.log import COLORS
from meta_tools import classic_reify, extend_reification, transform
from meta_tools.extensions import ShowExtension
from meta_tools.extensions.base_extension import ReifyExtension
import logging
from importlib.resources import path

log = logging.getLogger(__name__)


@dataclass
class Formula:
    name: str
    symbol: Symbol
    type: Type
    arguments: List["Formula"] = None
    super_types: List[str] = None

    @property
    def signature(self) -> tuple[str, int]:
        return (self.name, len(self.symbol.arguments))

    @property
    def used_types(self) -> List[str]:
        types = set([self.type.name] + (self.super_types or []))
        return list(types)

    def symbol_with_prefix(self) -> Symbol:
        is_tuple = self.type is None
        if is_tuple:
            name = ""
        else:
            if self.type.is_base_type:
                return self.symbol
            name = f"__{self.symbol.name}"
        return Function(name, [a.symbol_with_prefix() for a in self.arguments], self.symbol.positive)

    def __str__(self) -> str:
        return str(self.symbol)


def _print_done_decorator(func):
    def wrapper(self, *args, **kwargs):
        try:
            log.debug("*" * 30)
            return func(self, *args, **kwargs)
        finally:
            log.debug("*" * 30 + "\n")

    return wrapper


def is_tuple(s: Symbol) -> bool:
    return s.type == SymbolType.Function and s.name == ""


def p(s) -> str:
    s_str = str(s)
    s_str = s_str.replace("__", "&")
    return f"{COLORS['YELLOW']}{s_str}{COLORS['NORMAL']}{COLORS['GREY']}"


def t(s) -> str:
    return f"{COLORS['GREEN']}{str(s)}{COLORS['NORMAL']}{COLORS['GREY']}"


class FormulaRegistery:

    def __init__(self, grammar: Grammar):
        self._prefix = "__"
        self.grammar = grammar
        self.formulas: dict[str, Formula] = {}

    def add_formula(self, f: Formula):
        self.formulas[str(f)] = f
        return self.formulas[str(f)]

    def remove_syntactic_sugar(self, symbol: Symbol, as_type=None) -> Symbol:
        matched_variables = {}
        macro = self.grammar.find_macro(symbol, as_type, matched_variables)
        if not macro:
            return symbol
        new_symbol = self.grammar.apply_sugar_with_vars(macro.type, macro.expansion.symbol, matched_variables)
        log.debug(f"✴️ Removing syntactic sugar of {p(symbol)} using rule {p(macro.pattern)} -> {p(macro.expansion)}")
        log.debug(f"  New symbol: {p(new_symbol)}")
        return new_symbol

    def assert_type_in(self, as_type: str | None, possible_types: List[str], symbol: Symbol) -> None:
        if as_type is not None and as_type not in possible_types:
            m = f"Type mismatch for symbol {p(symbol)} expected {t(as_type)}, but matches only with: {possible_types}"
            # log.error(m)
            raise ValueError(m)

    def match_top_level(self, s: Symbol) -> Formula:
        possible_types = self.grammar.allowed_types_in_position()
        errors = []
        matched_formulas = {}
        if len(possible_types) == 0:
            log.warn(
                "No types defined in the grammar to be allowed as atoms in the program. Make sure to define at least one type with allow(X,head) or allow(X,body)."
            )
            return None
        log.debug(f"\n\033[93m{'=' * 30}\033[0m")
        log.debug(f"🟧 Matching -> {p(s)}")
        for possible_type in possible_types:
            log.debug(f"\033[94m{'-' * 30}\033[0m")
            log.debug(f"🔶 Trying to match {p(s)} as top level type {t(possible_type)}")
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

        log.info(f"Matched {p(s)} as types: {matched_formulas.keys()}")
        if len(matched_formulas) != 0:
            found_formulas = set([str(f) for f in matched_formulas.values()])
            if len(found_formulas) > 1:
                log.warning(
                    "Multiple type matches but formula %s, but syntactic sugar led to different formulas: %s. "
                    "This may lead to unexpected results.",
                    p(s),
                    found_formulas,
                )
            return list(matched_formulas.values())[0]
        for type_name, e in errors:
            log.error(f"Could not match {p(s)} as type {t(type_name)}: {e}")

        raise ValueError(f"Could not match top-level symbol {p(s)} as any of the allowed types: {possible_types}")

    @_print_done_decorator
    def match(self, s: Symbol, as_type: str | None = None) -> Formula:
        log.debug(f"▶️ Trying to match symbol {p(s)} as type {t(as_type)}")
        formula_type = self.grammar.get_fl_type(s)  # Just to raise error if not valid
        if formula_type is None:
            log.debug(f"Symbol {p(s)} has no direct type or expression, checking syntactic sugar")
            formula_type = self.grammar.get_fl_type(
                s, check_sugar=True, as_type=as_type
            )  # Just to raise error if not valid
            if formula_type is None:
                log.debug(f"No syntactic sugar found for {p(s)} as type {t(as_type)}.")
                raise ValueError(f"No expression or syntactic sugar found for symbol {s}.")
            new_symbol = self.remove_syntactic_sugar(s, as_type=as_type)
            same_symbol = new_symbol == s
            if same_symbol:
                m = f"Symbol {p(s)} was not changed by syntactic sugar removal. This would lead to infinite recursion."
                raise ValueError(m)
            new_formula = self.match(new_symbol, as_type=as_type)
            return self.add_formula(new_formula)
        try:
            self.assert_type_in(as_type, formula_type.all_types, s)
        except ValueError as e:
            log.debug(f"No match of symbol {p(s)} as type {t(as_type)}: {e}. Will try to remove sugar.")
            new_symbol = self.remove_syntactic_sugar(s, as_type=as_type)
            if new_symbol == s:
                log.debug(f"No syntactic sugar removed for {p(s)}")
                raise e
            log.debug(f"Syntactic sugar removed for {p(s)}, matching new symbol {p(new_symbol)}")
            return self.match(new_symbol, as_type=as_type)

        if formula_type.is_base_type:
            log.debug(f"✅ Symbol {p(s)} is base type {t(formula_type.name)}, returning directly")
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

        # --------- Match arguments
        log.debug(f"☑️ Matched expression {p(expression.name)} of type {t(expression.type_name)}")
        log.debug(f"  Trying to match arguments...")
        arguments = []
        for i, a in enumerate(s.arguments):
            arg_defs = expression.args.get(i, None)
            arg_expected_types = [arg.value for arg in arg_defs or [] if arg.key == "type"]
            if len(arg_expected_types) > 1:
                # TODO This could be a check when the grammar is created
                log.warning(f"Multiple expected types for argument {i} of expression {expression.name}")
                raise ValueError("Multiple expected types not supported ")
            if len(arg_expected_types) == 0:
                log.warning(f"No fixed type for argument {i} of expression {expression.name}")
                expected_type = None
            else:
                expected_type = arg_expected_types[0]
            try:
                if is_tuple(a):
                    if not is_tuple(expected_type.symbol):
                        log.error(
                            f"Type mismatch for argument {i} of expression {expression.name} in {s}: expected {t(expected_type)}, got tuple {a}"
                        )
                        raise ValueError("Type mismatch: expected non-tuple, got tuple")
                    args_to_match = a.arguments
                    expected_types = expected_type.symbol.arguments
                else:
                    args_to_match = [a]
                    expected_types = [expected_type]
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
                log.error(f"Could not match argument {p(a)} of {p(s)}: {e}")
                raise e
        log.debug(f"  All arguments matched!")
        log.debug(
            f"✅ Symbol {p(s)} is type {t(formula_type.name)}, with expression ({expression.name},{expression.arity})"
        )
        new_symbol_fun = Function(name, [a.symbol for a in arguments], True)
        formula = Formula(
            name=name,
            symbol=new_symbol_fun,
            type=formula_type,
            arguments=arguments,
            super_types=[as_type] if as_type is not None else [],
        )
        return self.add_formula(formula)
