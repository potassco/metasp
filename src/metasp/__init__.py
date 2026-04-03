"""
The metasp project.
"""

from ast import AST
from dataclasses import dataclass
from re import match
from typing import Dict, List
from clingox.reify import Reifier
from clingo import Control, Symbol
from collections.abc import Callable, Sequence
from metasp.grammar import Grammar, Type
from clingo import SymbolType, Function
from metasp.utils.logging_utils import COLORS
import meta_tools
from meta_tools.extensions import ShowExtension
from meta_tools.extensions.base_extension import ReifyExtension
from metasp.formula_processing import FormulaRegistery
import logging
from importlib.resources import path

log = logging.getLogger(__name__)


def replace_internal_prefix(prg: str) -> str:
    """
    Replaces the __ prefix by & in the program.
    Used to show the output to the user.

    Args:
        prg (str): The program string to process.
    """
    return prg.replace("__", "&")


def replace_prefix(files: List[str], prg: str) -> str:
    """
    Replaces the & prefix by __ in the files and program.

    Args:
        files (List[str]): The list of file paths to process.
        prg (str): The program string to process.
    Returns:
        str: The program string with the replaced prefixes.
    """
    # TODO AMADE call aspen make sure all include statements are considered

    # Placeholder code:
    program_str = ""
    for file_path in files:
        with open(file_path, "r", encoding="utf-8") as f:
            program_str += f.read() + "\n"
    program_str += prg
    return program_str


RESERVED_PREDICATES = [("_show", 0), ("_show_term", 1), ("_show_atom", 1)]


def is_reserved_predicate(symbol: Symbol) -> bool:
    return any(symbol.match(p[0], p[1]) for p in RESERVED_PREDICATES)


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
        def match_output(symbol: Symbol) -> Symbol:
            if is_reserved_predicate(symbol):
                return symbol
            formula = self._formula_registery.match_top_level(symbol)
            if formula is not None:
                return formula.symbol_with_prefix()
            return symbol

        setattr(context, "match_output", match_output)

    def additional_symbols(self) -> Sequence[Symbol]:
        formula_symbols = []
        for f in self._formula_registery.formulas.values():
            used_types = f.used_types
            for s in used_types:
                formula_symbols.append(
                    Function("formula", [Function(s, [], True), f.symbol_with_prefix()]),
                )
        return formula_symbols


class MetaspProcessor:

    def __init__(self, grammar: Grammar) -> None:
        self.grammar = grammar
        self.extensions = [MetaspExtension(grammar=grammar)]

    def reify_and_extend(self, prg: str, constants: dict[str, str]) -> str:
        """
        Reify the input data with the given constants.
        The input program is expected to be first transformed.

        Args:
            prg (str): The input data to be reified.
            constants (dict[str, str]): The constants to be used in the reification.
        Returns:
            str: The reified input data.
        """
        log.debug("Reifying program...")
        rsymbols = meta_tools.classic_reify(
            ["--preserve-facts=symtab"] + [f"-c {k}={v}" for k, v in constants.items()],
            prg,
            programs=[("base", [])],
        )
        simple_reified_prg = "\n".join([f"{str(s)}." for s in rsymbols])
        log.debug("---------- Classic reification \n" + simple_reified_prg + "\n-------------------")

        reified_prg = self.grammar.asp_str

        reified_prg += "\n%%%%%%%%%% REIFIED INPUT %%%%%%%%%%%%\n"
        reified_prg += meta_tools.extend_reification(
            reified_out_prg=simple_reified_prg, extensions=self.extensions, clean_output=True
        )

        return reified_prg
