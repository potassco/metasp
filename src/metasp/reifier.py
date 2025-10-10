from dataclasses import dataclass
from typing import Dict, List
from clingox.reify import Reifier
from clingo import Control, Symbol
from collections.abc import Callable, Sequence
from metasp.grammar import Grammar
from clingo import SymbolType, Function

import logging

log = logging.getLogger(__name__)


@dataclass
class Formula:
    name: str
    symbol: Symbol
    supertypes: Sequence[str]
    arguments: List["Formula"] = None

    @property
    def signature(self) -> tuple[str, int]:
        return (self.name, len(self.symbol.arguments))

    def symbol_with_prefix(self) -> Symbol:
        if "atom" in self.supertypes:
            return self.symbol
        return Function(f"__{self.symbol.name}", [a.symbol_with_prefix() for a in self.arguments], self.symbol.positive)

    def __str__(self) -> str:
        return str(self.symbol)


def is_tuple(s: Symbol) -> bool:
    return s.type == SymbolType.Function and s.name == ""


class FormulaRegistery:

    def __init__(self, grammar: Grammar):
        self._prefix = "__"
        self._reserved_names = {"_show"}  # Should not be considered atoms or constructors
        self.grammar = grammar
        self.formulas: dict[str, Formula] = {}

    def add_formula(self, f: Formula):
        self.formulas[str(f)] = f
        return self.formulas[str(f)]

    def match_sugar_pattern(
        self, pattern_symbol: Symbol, formula: Formula, matched_variables: Dict[str, Symbol]
    ) -> bool:
        # print("Matching sugar pattern:")
        # print(f"  Pattern: {pattern_symbol}")
        # print(f"  Formula: {str(formula)}")
        # print(f"  Matµched variables so far: {matched_variables}")
        if self.grammar.is_variable(pattern_symbol):
            # print(f"  Pattern Is variable")
            variables = self.grammar.variables[pattern_symbol.name]
            if all(t in formula.supertypes for t in [v.type.name for v in variables]):
                matched_variables[pattern_symbol.name] = formula
                # print(f"  ->Matched variable {pattern_symbol.name} to {formula}")
                return True
            # print(f"  ->Variable {pattern_symbol.name} type mismatch")
            return False
        if (formula.name, len(formula.arguments)) != (pattern_symbol.name, len(pattern_symbol.arguments)):
            return False
        for p_arg, f_arg in zip(pattern_symbol.arguments, formula.arguments):
            # print(f"  ->Matching argument {p_arg} with {f_arg}")
            if not self.match_sugar_pattern(p_arg, f_arg, matched_variables):
                return False
        return True

    def replace(self, pattern_symbol: Symbol, matched_variables: Dict[str, Formula]) -> Symbol:
        # print(f"Replacing pattern symbol {pattern_symbol} with matched variables {matched_variables}")
        if pattern_symbol.type != SymbolType.Function:
            return pattern_symbol
        if self.grammar.is_variable(pattern_symbol):
            # print(
            # f"  Pattern is variable {pattern_symbol.name}, replaced with {matched_variables[pattern_symbol.name]}"
            # )
            # variable = self.grammar.variables[pattern_symbol.name]
            # print(str(matched_variables[pattern_symbol.name].symbol))
            return matched_variables[pattern_symbol.name].symbol_with_prefix()
        new_args = [self.replace(arg, matched_variables) for arg in pattern_symbol.arguments]
        return Function(pattern_symbol.name, new_args, True)

    def remove_syntactic_sugar(self, f: Formula, as_type=None) -> Formula:
        for sugar in self.grammar.syntactic_sugar:
            matched_variables = {}
            if sugar.type != "any":
                if as_type is None:
                    # print(f"Skipping sugar because as_type is None and sugar.type is {sugar.type}")
                    continue
                if as_type != sugar.type:
                    # print(f"Skipping sugar because as_type {as_type} != sugar.type {sugar.type}")
                    continue
            if self.match_sugar_pattern(sugar.pattern.symbol, f, matched_variables):
                log.info(
                    f"----------- Removing syntactic sugar of `{str(f)}` using rule`{sugar.pattern}` -> `{sugar.expansion}`"
                )
                new_symbol = self.replace(sugar.expansion.symbol, matched_variables)
                log.info(f"New symbol: `{new_symbol}`")
                return self.match(new_symbol, as_type=as_type)
        return f

    def is_atom(self, s: Symbol) -> bool:
        if s.type != SymbolType.Function or s.name.startswith(self._prefix):
            return False
        # log.info( f"Matched atom {s}")
        constructor_keys = self.grammar.get_constructors_keys()
        if (s.name, len(s.arguments)) in constructor_keys:
            log.warning(
                f"Symbol `{s}` looks like a constructor but is missing the & prefix. Did you forget it?. Considered as atom."
            )
        return True

    def assert_type_in(self, as_type: str | None, possible_types: List[str], symbol: Symbol) -> None:
        if as_type is not None and as_type not in possible_types:
            m = f"Type mismatch for symbol {symbol} expected {as_type}, but matches only with: {possible_types}"
            log.error(m)
            raise ValueError(m)

    def match(self, s: Symbol, as_type: str | None = None) -> Formula | None:

        # --------- Base cases
        # print( "----------------------------")
        # print( f"Matching symbol {s} as type {as_type}")
        if s.type == SymbolType.Number:
            formula_type = self.grammar.types.get("number", None)
            f = Formula(name=str(s), symbol=s, supertypes=formula_type.all_types, arguments=[])
            self.assert_type_in(as_type, formula_type.all_types, s)
            new_f = self.remove_syntactic_sugar(f, as_type=as_type)
            return self.add_formula(new_f)
        if s.type != SymbolType.Function:
            log.warn("Ignored")
            return None
        if s.name in self._reserved_names:
            return None
        if self.is_atom(s):
            formula_type = self.grammar.types.get("atom", None)
            f = Formula(name=s.name, symbol=s, supertypes=formula_type.all_types, arguments=[])
            self.assert_type_in(as_type, formula_type.all_types, s)
            new_f = self.remove_syntactic_sugar(f, as_type=as_type)
            return self.add_formula(new_f)

        # --------- Recursive case
        name = s.name[len(self._prefix) :]
        arity = len(s.arguments)
        constructor = self.grammar.get_constructor(name, arity)
        if constructor is None:
            log.error(f"No constructor found for {s}.")
            raise ValueError(f"No constructor found for {s}.")

        formula_type = self.grammar.types.get(constructor.type_name, None)
        supertypes = formula_type.all_types

        self.assert_type_in(as_type, supertypes, s)
        # --------- Match arguments
        # log.info( f"Matched constructor {constructor.name} of type {constructor.type_name}")
        arguments = []
        for i, a in enumerate(s.arguments):
            arg_defs = constructor.args.get(i, None)
            arg_expected_types = [arg.value for arg in arg_defs or [] if arg.key == "type"]
            if len(arg_expected_types) > 1:
                log.warning(f"Multiple expected types for argument {i} of constructor {constructor.name}")
                raise ValueError("Multiple expected types not supported ")
            if len(arg_expected_types) == 0:
                log.warning(f"No fixed type for argument {i} of constructor {constructor.name}")
                expected_type = None
            else:
                expected_type = arg_expected_types[0]
            # print( f"Matching argument {i}: {a}")
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
                        supertypes=[],
                    )
                )
                arguments.append(arg_formula)
            except ValueError as e:
                log.error(f"Could not match argument {a} of {s}: {e}")
                raise e

        new_symbol_fun = Function(name, [a.symbol for a in arguments], True)
        formula = Formula(
            name=name,
            symbol=new_symbol_fun,
            supertypes=supertypes,
            arguments=arguments,
        )
        new_f = self.remove_syntactic_sugar(formula, as_type=as_type)
        return self.add_formula(new_f)


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
        # print(f"----------Output atom: {symbol} with atom {atom}")
        formula = self._formula_registery.match(symbol)
        # print("=====\nCurrent formulas:")
        # print(self._formula_registery.formulas)
        if formula is not None:
            symbol = formula.symbol
        self._output("output", [symbol, self._lit_tuple([] if atom == 0 else [atom])])

    def output_term(self, symbol: Symbol, condition: Sequence[int]) -> None:
        # print(f"----------Output term: {symbol} with condition {condition}")
        self._output("output", [symbol, self._lit_tuple(condition)])

    def cb_formulas(self) -> None:
        for f in self._formula_registery.formulas.values():
            for s in f.supertypes:
                self._output(
                    "formula",
                    [Function(s, [], True), f.symbol],
                )


def reify(prg: str, constants: dict[str, str], syntax_encoding: Sequence[str]) -> str:
    """
    Reify the input data with the given constants.
    The input predicate is expected to have the required externals
    which can be achieved by calling preprocess first.

    Args:
        prg (str): The input data to be reified.
        constants (Sequence[str]): The constants to be used in the reification.
        syntax_encoding (Sequence[str]): The syntax encoding defining the grammar
    Returns:
        str: The reified input data.
    """
    symbols: Sequence[Symbol] = []

    ctl = Control(["--warn=none"] + [f"-c {k}={v}" for k, v in constants.items()])
    grammar = Grammar.from_asp_files(syntax_encoding)
    fr = FormulaRegistery(grammar)
    reifier = MetaReifier(symbols.append, reify_steps=False, formula_registery=fr)
    ctl.register_observer(reifier)
    ctl.add("base", [], prg)
    ctl.ground([("base", [])])
    reifier.cb_formulas()
    reified_input = "\n".join([str(s) + "." for s in symbols])
    title = "\n\n%%%%%% Reified Input %%%%%%\n\n"
    return title + reified_input
