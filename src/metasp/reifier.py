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


class FormulaRegistery:

    def __init__(self, grammar: Grammar):
        self._prefix = "__"
        self._reserved_names = {"_show"}  # Should not be considered atoms or constructors
        self.grammar = grammar
        self.formulas: dict[str, Formula] = {}

    def add_formula(self, f: Formula):
        formula_type = self.grammar.types.get(f.supertypes[0], None)
        supertypes = formula_type.super_types + [formula_type.name]

        #     f2, t = g.remove_syntactic_sugar(f, supertypes)
        #     supertypes = g.get_super_types(t) # includes t
        #     %% Not sure if this is ok %%
        f.supertypes = supertypes
        # log.info(f"Registered formula `{f}` of type `{t}` with supertypes {supertypes}")

        self.formulas[str(f)] = self.remove_syntactic_sugar(f)
        return self.formulas[str(f)]

    def match_sugar_pattern(
        self, pattern_symbol: Symbol, formula: Formula, matched_variables: Dict[str, Symbol]
    ) -> bool:
        print("Matching sugar pattern:")
        print(f"  Pattern: {pattern_symbol}")
        print(f"  Formula: {formula}")
        # print(f"  Matµched variables so far: {matched_variables}")
        if self.grammar.is_variable(pattern_symbol):
            print(f"  Pattern Is variable")
            variables = self.grammar.variables[pattern_symbol.name]
            if all(t in formula.supertypes for t in [v.type.name for v in variables]):
                matched_variables[pattern_symbol.name] = formula
                print(f"  ->Matched variable {pattern_symbol.name} to {formula}")
                return True
            print(
                f"  ->Variable {pattern_symbol.name} type mismatch: {[v.type for v in variables]} vs {formula.supertypes}"
            )
            return False
        if (formula.name, len(formula.arguments)) != (pattern_symbol.name, len(pattern_symbol.arguments)):
            return False
        for p_arg, f_arg in zip(pattern_symbol.arguments, formula.arguments):
            print(f"  ->Matching argument {p_arg} with {f_arg}")
            if not self.match_sugar_pattern(p_arg, f_arg, matched_variables):
                return False
        return True

    def replace(self, pattern_symbol: Symbol, matched_variables: Dict[str, Formula]) -> Symbol:
        print(f"Replacing pattern symbol {pattern_symbol} with matched variables {matched_variables}")
        if self.grammar.is_variable(pattern_symbol):
            print(
                f"  Pattern is variable {pattern_symbol.name}, replaced with {matched_variables[pattern_symbol.name]}"
            )
            # variable = self.grammar.variables[pattern_symbol.name]
            print(str(matched_variables[pattern_symbol.name].symbol))
            return matched_variables[pattern_symbol.name].symbol_with_prefix()
        new_args = [self.replace(arg, matched_variables) for arg in pattern_symbol.arguments]
        print(str(Function(pattern_symbol.name, new_args, True)))
        return Function(pattern_symbol.name, new_args, True)

    def remove_syntactic_sugar(self, f: Formula) -> Formula:
        for sugar in self.grammar.syntactic_sugar:
            matched_variables = {}
            if self.match_sugar_pattern(sugar.pattern.symbol, f, matched_variables):
                log.info(f"----------- Removing syntactic sugar `{sugar.pattern}` -> `{sugar.expansion}`")
                new_symbol = self.replace(sugar.expansion.symbol, matched_variables)
                log.info(f"New symbol: `{new_symbol}`")
                return self.match(new_symbol)
        return f

    def is_atom(self, s: Symbol, level=0) -> bool:
        if s.type != SymbolType.Function or s.name.startswith(self._prefix):
            return False
        # log.info(level * "\t" + f"Matched atom {s}")
        constructor_keys = self.grammar.get_constructors_keys()
        if (s.name, len(s.arguments)) in constructor_keys:
            log.warning(
                level * "\t"
                + f"Symbol {s} looks like a constructor but is missing the & prefix. Did you forget it?. Considered as atom."
            )
        return True

    def match(self, s: Symbol, level=0) -> Formula | None:

        # --------- Base cases
        # print(level * "\t" + "----------------------------")
        # print(level * "\t" + f"Matching symbol {s}")
        if s.type == SymbolType.Number:
            # TODO fix
            return self.add_formula(s, "number")
        if s.type != SymbolType.Function:
            log.warn(level * "\t" + "Ignored")
            return None
        if s.name in self._reserved_names:
            return None
        if self.is_atom(s):
            return self.add_formula(Formula(name=s.name, symbol=s, supertypes=["atom"], arguments=[]))

        # --------- Recursive case
        name = s.name[len(self._prefix) :]
        arity = len(s.arguments)
        constructor = self.grammar.get_constructor(name, arity)
        if constructor is None:
            log.error(level * "\t" + f"No constructor found for {s}.")
            raise ValueError(f"No constructor found for {s}.")

        # --------- Match arguments
        # log.info(level * "\t" + f"Matched constructor {constructor.name} of type {constructor.type_name}")
        arguments = []
        for i, a in enumerate(s.arguments):
            # print(level * "\t" + f"Matching argument {i}: {a}")
            try:
                arg_formula = self.match(a, level + 1)
            except ValueError as e:
                log.error(level * "\t" + f"Could not match argument {a} of {s}: {e}")
                raise e

            # Additional checks (Like subtypes)
            arg_defs = constructor.args.get(i, None)
            for arg in arg_defs or []:
                if arg.key == "type":
                    # print(level * "\t" + f"Checking type {arg.value} in {matched_type['supertypes']}")
                    if arg.value not in arg_formula.supertypes:
                        log.error(
                            level * "\t"
                            + f"Type mismatch for argument {i} of constructor {constructor.name}: expected {arg.value}, got {arg_formula.supertypes}"
                        )
                        return None

            arguments.append(arg_formula)
            # if arg_formula.supertypes is not None and arg_def.type not in arg_formula.supertypes:
            #     log.error(
            #         f"Type mismatch for argument {i} of constructor {c.name}: expected {arg_def.type}, got {arg_formula.supertypes}"
            #     )
            #     return None

        new_symbol_fun = Function(name, [a.symbol for a in arguments], True)
        formula = Formula(name=name, symbol=new_symbol_fun, supertypes=[constructor.type_name], arguments=arguments)
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
