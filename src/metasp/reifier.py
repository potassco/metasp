from dataclasses import dataclass
from re import match
from typing import Dict, List
from clingox.reify import Reifier
from clingo import Control, Symbol
from collections.abc import Callable, Sequence
from metasp.grammar import Grammar, Type
from clingo import SymbolType, Function
from metasp.utils.logging import COLORS
from meta_tools import classic_reify, extend_reification, transform
from meta_tools.extensions import ShowExtension
from meta_tools.extensions.base_extension import ReifyExtension
import logging
from importlib.resources import path

log = logging.getLogger(__name__)

RESERVED_NAMES = {"_show"}


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
        if self.type.is_base_type:
            return self.symbol
        return Function(f"__{self.symbol.name}", [a.symbol_with_prefix() for a in self.arguments], self.symbol.positive)

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
        sugar = self.grammar.find_sugar(symbol, as_type, matched_variables)
        if not sugar:
            return symbol
        new_symbol = self.grammar.apply_sugar_with_vars(sugar.expansion.symbol, matched_variables)
        log.debug(f"✴️ Removing syntactic sugar of {p(symbol)} using rule {p(sugar.pattern)} -> {p(sugar.expansion)}")
        log.debug(f"  New symbol: {p(new_symbol)}")
        return new_symbol

    def assert_type_in(self, as_type: str | None, possible_types: List[str], symbol: Symbol) -> None:
        if as_type is not None and as_type not in possible_types:
            m = f"Type mismatch for symbol {p(symbol)} expected {t(as_type)}, but matches only with: {possible_types}"
            # log.error(m)
            raise ValueError(m)

    def is_reserved(self, s: Symbol) -> bool:
        return s.type == SymbolType.Function and s.name in RESERVED_NAMES

    def match_top_level(self, s: Symbol) -> Formula:
        if self.is_reserved(s):
            # log.debug(f"Symbol {p(s)} is reserved, skipping.")
            return None
        possible_types = self.grammar.allowed_types_in_position()
        errors = []
        if len(possible_types) == 0:
            log.warn(
                "No types defined in the grammar to be allowed as atoms in the program. Make sure to define at least one type with allow(X,head) or allow(X,body)."
            )
            return None
        for possible_type in possible_types:
            log.debug(f"\033[94m{'=' * 30}\033[0m")
            log.debug(f"1️⃣ Trying to match {p(s)} as top level type {t(possible_type)}")
            try:
                f = self.match(s, as_type=possible_type)
                if f is not None:
                    log.debug(
                        "✳️ Matched top-level symbol %s as type %s.",
                        p(s),
                        t(possible_type),
                    )
                    return f
            except ValueError as e:
                errors.append((possible_type, e))
                log.debug("Not possible to match with top-level type %s", t(possible_type))
        for type_name, e in errors:
            log.error(f"Could not match {p(s)} as type {t(type_name)}: {e}")

        raise ValueError(f"Could not match top-level symbol {p(s)} as any of the allowed types: {possible_types}")

    @_print_done_decorator
    def match(self, s: Symbol, as_type: str | None = None) -> Formula:
        log.debug(f"▶️ Trying to match symbol {p(s)} as type {t(as_type)}")
        formula_type = self.grammar.get_fl_type(s)  # Just to raise error if not valid
        if formula_type is None:
            log.debug(f"Symbol {p(s)} has no direct type or constructor, checking syntactic sugar")
            formula_type = self.grammar.get_fl_type(
                s, check_sugar=True, as_type=as_type
            )  # Just to raise error if not valid
            if formula_type is None:
                log.debug(f"No syntactic sugar found for {p(s)} as type {t(as_type)}.")
                raise ValueError(f"No constructor or syntactic sugar found for symbol {s}.")
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
        constructor = self.grammar.get_constructor(name, arity)

        # --------- Match arguments
        log.debug(f"☑️ Matched constructor {p(constructor.name)} of type {t(constructor.type_name)}")
        log.debug(f"  Trying to match arguments...")
        arguments = []
        for i, a in enumerate(s.arguments):
            arg_defs = constructor.args.get(i, None)
            arg_expected_types = [arg.value for arg in arg_defs or [] if arg.key == "type"]
            if len(arg_expected_types) > 1:
                # TODO This could be a check when the grammar is created
                log.warning(f"Multiple expected types for argument {i} of constructor {constructor.name}")
                raise ValueError("Multiple expected types not supported ")
            if len(arg_expected_types) == 0:
                log.warning(f"No fixed type for argument {i} of constructor {constructor.name}")
                expected_type = None
            else:
                expected_type = arg_expected_types[0]
            try:
                if is_tuple(a):
                    if not is_tuple(expected_type.symbol):
                        log.error(
                            f"Type mismatch for argument {i} of constructor {constructor.name} in {s}: expected {t(expected_type)}, got tuple {a}"
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
            f"✅ Symbol {p(s)} is type {t(formula_type.name)}, with constructor ({constructor.name},{constructor.arity})"
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


class MetaspExtension(ReifyExtension):

    def __init__(
        self,
        grammar: Grammar,
    ) -> None:
        super().__init__()
        self._grammar = grammar
        self._formula_registery = FormulaRegistery(grammar)

    def add_extension_encoding(self, ctl: Control) -> None:
        """ """
        with path("metasp.encodings", "reify-extension.lp") as base_encoding:
            log.debug("Loading encoding: %s", base_encoding)
            ctl.load(str(base_encoding))

    def update_context(self, context: object) -> None:
        def process_output(symbol: Symbol) -> Symbol:
            formula = self._formula_registery.match_top_level(symbol)
            if formula is not None:
                return formula.symbol_with_prefix()
            return symbol

        setattr(context, "process_output", process_output)

    def additional_symbols(self) -> Sequence[Symbol]:
        formula_symbols = []
        for f in self._formula_registery.formulas.values():
            used_types = f.used_types
            for s in used_types:
                formula_symbols.append(
                    Function("formula", [Function(s, [], True), f.symbol_with_prefix()]),
                )
        return formula_symbols


def reify(prg: str, constants: dict[str, str], grammar: Grammar) -> str:
    """
    Reify the input data with the given constants.
    The input predicate is expected to have the required externals
    which can be achieved by calling preprocess first.

    Args:
        prg (str): The input data to be reified.
        constants (Sequence[str]): The constants to be used in the reification.
        grammar (Grammar): The grammar defining the syntax and safety.
    Returns:
        str: The reified input data.
    """
    extensions = [ShowExtension(), MetaspExtension(grammar=grammar)]
    program_str = transform([], prg, extensions)
    rsymbols = classic_reify(
        [f"-c {k}={v}" for k, v in constants.items()],
        program_str,
        programs=[("base", [])],
    )
    reified_prg = "\n".join([f"{str(s)}." for s in rsymbols])
    reified_prg = extend_reification(reified_out_prg=reified_prg, extensions=extensions, clean_output=True)
    return reified_prg
