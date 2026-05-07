"""
The metasp project.
"""

from ast import AST
from dataclasses import dataclass
from re import match
import sys
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
from importlib.resources import files

log = logging.getLogger(__name__)


def replace_internal_prefix(prg: str) -> str:
    """
    Replaces the __ prefix by & in the program.
    Used to show the output to the user.

    Args:
        prg (str): The program string to process.
    """
    return prg.replace("__", "&")


RESERVED_PREDICATES = [("_show", 0), ("_show_term", 1), ("_show_atom", 1)]


def is_reserved_predicate(symbol: Symbol) -> bool:
    """
    Checks if a symbol is a reserved predicate.

    Args:
        symbol (Symbol): The symbol to check.

    Returns:
        bool: True if the symbol is a reserved predicate, False otherwise.
    """
    return any(symbol.match(p[0], p[1]) for p in RESERVED_PREDICATES)


class MetaspExtension(ReifyExtension):
    """
    Metasp Extension for the reification process.
    It uses ASPEN to transform the input program and then reifies it with the help of the FormulaRegistery to keep track of the formulas and their types.
    """

    def __init__(
        self,
        grammar: Grammar,
    ) -> None:
        super().__init__()
        self._grammar = grammar
        self._formula_registery = FormulaRegistery(grammar)

    def add_extension_encoding(self, ctl: Control) -> None:
        """
        Adds the extension encoding to the control object.
        Args:
            ctl (Control): The clingo control object to which the encoding will be added.
        """
        base_encoding = files("metasp.encodings").joinpath("reify-extension.lp")
        log.debug("Loading encoding: %s", base_encoding)
        ctl.load(str(base_encoding))

    def update_context(self, context: object) -> None:
        """
        Updates the context object with the necessary functions for the extension.

        Args:
            context (object): The clingo context object to be updated.
        """

        def match_output(symbol: Symbol) -> Symbol:
            if is_reserved_predicate(symbol):
                return symbol
            formula = self._formula_registery.match_top_level(symbol)
            if formula is not None:
                return formula.symbol_with_prefix()
            return symbol  # nocoverage

        setattr(context, "match_output", match_output)

    def additional_symbols(self) -> Sequence[Symbol]:
        """
        Provides additional symbols to be added to the reified program.
        In this case, it provides the symbols for the formulas in the formula registery.
        """

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
        try:
            rsymbols = meta_tools.classic_reify(
                ["--preserve-facts=symtab"] + [f"-c {k}={v}" for k, v in constants.items()],
                prg,
                programs=[("base", [])],
            )
        except RuntimeError as e:
            log.error("Error during grounding of the transformed input:\n%s", prg)
            log.error("Error: %s", e)
            raise e
        simple_reified_prg = "\n".join([f"{str(s)}." for s in rsymbols])
        log.debug("---------- Classic reification \n" + simple_reified_prg + "\n-------------------")

        reified_prg = self.grammar.asp_str

        reified_prg += "\n%%%%%%%%%% REIFIED INPUT %%%%%%%%%%%%\n"
        reified_prg += meta_tools.extend_reification(
            reified_out_prg=simple_reified_prg, extensions=self.extensions, clean_output=True
        )

        return reified_prg
