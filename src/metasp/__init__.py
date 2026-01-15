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
from metasp.utils.logging import COLORS
import meta_tools
from meta_tools.extensions import ShowExtension
from meta_tools.extensions.base_extension import ReifyExtension
from metasp.formula_processing import FormulaRegistery
import logging
from importlib.resources import path

from metasp.preprocess import preprocess

log = logging.getLogger(__name__)


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


RESERVED_PREDICATES = [("_show", 0), ("_show", 1)]


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

    def transform(self, file_paths: List[str], program_string: str) -> str:
        """
        Transforms a list of files and a program string and returns a string with the transformation

        Note: I have it as a general function so that it can use something other than a transformer, like ASPEN
        Note: Having it like this implies multiple passes over the program

        Args:
            file_paths (List[str]): The list of file paths to process.
            program_string (str): The program string to process.

        Returns:
            str: The transformed program string.
        """
        prg = preprocess(file_paths, program_string, self._grammar)
        return prg

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
        self.extensions = [ShowExtension(), MetaspExtension(grammar=grammar)]

    def fo_transform(self, files: List[str], prg: str) -> str:
        """
        Transforms a list of files and a program string and returns a string with the transformation.
        The input program should not contain &-prefixed atoms.

        Runs the extensions defined in the processor for Show statements, introduction of externals, safety checks and occurrence checks.

        Args:
            files (List[str]): The list of file paths to process.
            prg (str): The program string to process.
        """
        program_str = meta_tools.transform(files, prg, self.extensions)
        return program_str

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
        rsymbols = meta_tools.classic_reify(
            ["--preserve-facts=symtab"] + [f"-c {k}={v}" for k, v in constants.items()],
            prg,
            programs=[("base", [])],
        )
        simple_reified_prg = "\n".join([f"{str(s)}." for s in rsymbols])
        log.debug("---------- Classic reification \n" + simple_reified_prg + "\n-------------------")
        reified_prg = "\n%%%%%%%%%% REIFIED INPUT %%%%%%%%%%%%\n"
        reified_prg += meta_tools.extend_reification(
            reified_out_prg=simple_reified_prg, extensions=self.extensions, clean_output=True
        )

        reified_prg += self.grammar.asp_str

        return reified_prg
