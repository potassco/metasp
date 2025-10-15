from dataclasses import dataclass
from re import match
from typing import Dict, List
from clingox.reify import Reifier
from clingo import Control, Symbol
from collections.abc import Callable, Sequence
from metasp.grammar import Grammar, Type
from clingo import SymbolType, Function

import logging

log = logging.getLogger(__name__)


@dataclass
class Formula:
    name: str
    symbol: Symbol
    type: Type
    arguments: List["Formula"] = None

    @property
    def signature(self) -> tuple[str, int]:
        return (self.name, len(self.symbol.arguments))

    def symbol_with_prefix(self) -> Symbol:
        if self.type.is_base_type():
            return self.symbol
        return Function(f"__{self.symbol.name}", [a.symbol_with_prefix() for a in self.arguments], self.symbol.positive)

    def __str__(self) -> str:
        return str(self.symbol)


def is_tuple(s: Symbol) -> bool:
    return s.type == SymbolType.Function and s.name == ""


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
        log.debug(f"✴️Removing syntactic sugar of `{str(symbol)}` using rule`{sugar.pattern}` -> `{sugar.expansion}`")
        log.debug(f"  New symbol: `{new_symbol}`")
        return new_symbol

    def assert_type_in(self, as_type: str | None, possible_types: List[str], symbol: Symbol) -> None:
        if as_type is not None and as_type not in possible_types:
            m = f"Type mismatch for symbol {symbol} expected {as_type}, but matches only with: {possible_types}"
            log.error(m)
            raise ValueError(m)

    def match_top_level(self, s: Symbol) -> Formula:
        possible_types = self.grammar.allowed_types_in_position()
        errors = []
        if len(possible_types) == 0:
            log.warn(
                "No types defined in the grammar to be allowed as atoms in the program. Make sure to define at least one type with allow(X,head) or allow(X,body)."
            )
            return None
        for possible_type in possible_types:
            log.debug(f"\033[94m{'=' * 30}\033[0m")
            log.debug(f"1️⃣ Trying to match `{s}` as top level type `{possible_type}`")
            try:
                f = self.match(s, as_type=possible_type)
                if f is not None:
                    log.debug(
                        "✳️ Matched top-level symbol `%s` as type `%s`. (Types that were not checked: %s)",
                        s,
                        possible_type,
                        possible_types[possible_types.index(possible_type) + 1 :],
                    )
                    return f
            except ValueError as e:
                errors.append((possible_type, e))
        for t, e in errors:
            log.error(f"Could not match {s} as type {t}: {e}")

        raise ValueError(f"Could not match top-level symbol {s} as any of the allowed types: {possible_types}")

    def _print_done_decorator(func):
        def wrapper(self, *args, **kwargs):
            try:
                log.debug("*" * 30)
                return func(self, *args, **kwargs)
            finally:
                log.debug("*" * 30 + "\n")

        return wrapper

    @_print_done_decorator
    def match(self, s: Symbol, as_type: str | None = None) -> Formula:
        log.debug(f"▶️ Trying to match symbol {s} as type {as_type}")
        formula_type = self.grammar.get_fl_type(s)  # Just to raise error if not valid
        if formula_type is None:
            log.debug(f"Symbol {s} has no direct type or constructor, checking syntactic sugar")
            formula_type = self.grammar.get_fl_type(s, check_sugar=True)  # Just to raise error if not valid
            if formula_type is None:
                # TODO print without the __
                log.debug(f"No type or constructor found for symbol {s}, even after checking syntactic sugar.")
                raise ValueError(f"No constructor or syntactic sugar found for symbol {s}.")
            new_symbol = self.remove_syntactic_sugar(s, as_type=as_type)
            new_formula = self.match(new_symbol, as_type=as_type)
            return self.add_formula(new_formula)
        self.assert_type_in(as_type, formula_type.all_types, s)
        if formula_type.is_base_type:
            log.debug(f"✅ Symbol {s} is base type {formula_type.name}, returning directly")
            new_symbol = self.remove_syntactic_sugar(s, as_type=as_type)
            new_formula = Formula(
                name=str(new_symbol),
                symbol=new_symbol,
                type=formula_type,
                arguments=[],
            )
            return self.add_formula(new_formula)

        # --------- Recursive case
        name = s.name[len(self._prefix) :]
        arity = len(s.arguments)
        constructor = self.grammar.get_constructor(name, arity)

        # --------- Match arguments
        log.debug(f"☑️ Matched constructor `{constructor.name}` of type `{constructor.type_name}`")
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
                            f"Type mismatch for argument {i} of constructor {constructor.name} in {s}: expected {expected_type}, got tuple {a}"
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
                log.error(f"Could not match argument {a} of {s}: {e}")
                raise e
        log.debug(f"  All arguments matched!")
        log.debug(
            f"✅ Symbol `{s}` is type `{formula_type.name}`, with constructor ({constructor.name},{constructor.arity})"
        )
        new_symbol_fun = Function(name, [a.symbol for a in arguments], True)
        formula = Formula(
            name=name,
            symbol=new_symbol_fun,
            type=formula_type,
            arguments=arguments,
        )
        return self.add_formula(formula)


class MetaReifier(Reifier):
    """
    A reifier that extends the clingox Reifier to handle meta-specific constructs.
    """

    def __init__(
        self,
        cb: Callable[[Symbol], None],
        calculate_sccs: bool = False,
        reify_steps: bool = False,
        formula_registery: FormulaRegistery = None,
    ):
        super().__init__(cb, calculate_sccs, reify_steps)
        self._formula_registery = formula_registery

    def output_atom(self, symbol: Symbol, atom: int) -> None:
        # TODO check not a reserved name like _show before matching
        formula = self._formula_registery.match_top_level(symbol)
        if formula is not None:
            symbol = formula.symbol
        self._output("output", [symbol, self._lit_tuple([] if atom == 0 else [atom])])

    def output_term(self, symbol: Symbol, condition: Sequence[int]) -> None:
        self._output("output", [symbol, self._lit_tuple(condition)])

    def cb_formulas(self) -> None:
        for f in self._formula_registery.formulas.values():
            # TODO only use types that were actually matched.
            for s in f.type.all_types:
                self._output(
                    "formula",
                    [Function(s, [], True), f.symbol],
                )


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
    symbols: Sequence[Symbol] = []

    ctl = Control(["--warn=none"] + [f"-c {k}={v}" for k, v in constants.items()])
    fr = FormulaRegistery(grammar)
    reifier = MetaReifier(symbols.append, reify_steps=False, formula_registery=fr)
    ctl.register_observer(reifier)
    ctl.add("base", [], prg)
    ctl.ground([("base", [])])
    reifier.cb_formulas()
    reified_input = "\n".join([str(s) + "." for s in symbols])
    title = "\n\n%%%%%% Reified Input %%%%%%\n\n"
    return title + reified_input
