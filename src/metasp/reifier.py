from ast import List
from clingox.reify import Reifier
from clingo import Control, Symbol
from collections.abc import Callable, Sequence
from metasp.grammar import Grammar
from clingo import SymbolType, Function

import logging

log = logging.getLogger(__name__)


class FormulaRegistery:

    def __init__(self, grammar: Grammar):
        self._prefix = "__"
        self.grammar = grammar
        self.formulas = {}  # maps formula string to types

    def add_formula(self, f: Symbol, t: str):
        formula_type = self.grammar.types.get(t, None)
        supertypes = formula_type.super_types + [formula_type.name]

        #     f2, t = g.remove_syntactic_sugar(f, supertypes)
        #     supertypes = g.get_super_types(t) # includes t
        #     %% Not sure if this is ok %%
        formula_info = {"symbol": f, "supertypes": supertypes}
        # log.info(f"Registered formula `{f}` of type `{t}` with supertypes {supertypes}")
        self.formulas[str(f)] = formula_info
        return formula_info

    def match(self, s: Symbol, level=0):
        print(level * "\t" + "----------------------------")
        print(level * "\t" + f"Matching symbol {s}")
        if s.type != SymbolType.Function:
            log.error(level * "\t" + "Ignored")
            return None
        if s.name == "_show":
            log.error(level * "\t" + "Ignored")
            return None
        if not s.name.startswith(self._prefix):
            log.info(level * "\t" + f"Matched atom {s}")
            # TODO check the list of constructors and if one of them matches then print a warning of a possible missing &
            return self.add_formula(s, "atom")

        name = s.name[len(self._prefix) :]
        arity = len(s.arguments)
        for t in self.grammar.types.values():
            # print(level*"\t"+f"Checking type {t.name} with constructors {t.constructors.keys()}")
            c = t.constructors.get((name, arity), None)
            if c is not None:
                log.info(level * "\t" + f"Matched constructor {c.name} of type {t.name}")
                arguments = []
                for i, a in enumerate(s.arguments):
                    arg_def = c.args.get(i, None)
                    print(level * "\t" + f"Matching argument {i}: {a}")
                    matched_type = self.match(a, level + 1)
                    if matched_type is None:
                        log.error(level * "\t" + f"Could not match argument {a} of {s}")
                        return None
                    if arg_def is None:
                        log.warning(level * "\t" + f"No argument definition for argument {i} of constructor {c.name}")
                    else:
                        log.warning(level * "\t" + "Here I should check the argument types")
                    arguments.append(matched_type["symbol"])
                    # if matched_type["supertypes"] is not None and arg_def.type not in matched_type["supertypes"]:
                    #     log.error(
                    #         f"Type mismatch for argument {i} of constructor {c.name}: expected {arg_def.type}, got {matched_type['supertypes']}"
                    #     )
                    #     return None

                new_symbol = Function(name, arguments, True)
                return self.add_formula(new_symbol, t.name)

        log.error(f"Could not match symbol {s}")
        return None


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
        formula_info = self._formula_registery.match(symbol)
        # print("=====\nCurrent formulas:")
        # print(self._formula_registery.formulas)
        if formula_info is not None:
            symbol = formula_info["symbol"]
        self._output("output", [symbol, self._lit_tuple([] if atom == 0 else [atom])])

    def output_term(self, symbol: Symbol, condition: Sequence[int]) -> None:
        print(f"----------Output term: {symbol} with condition {condition}")
        self._output("output", [symbol, self._lit_tuple(condition)])

    def cb_formulas(self) -> None:
        print("----------End step")
        for f in self._formula_registery.formulas.values():
            print(f"----------Formula: {f}")
            for s in f["supertypes"]:
                self._output(
                    "formula",
                    [Function(s, [], True), f["symbol"]],
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
