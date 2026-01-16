"""
Module with all printing functions that will be available for the print_model
Custom printing functions can be provided by adding the script in the configuration
"""

import logging
from typing import Callable, Optional
from clingo import Model, Symbol, SymbolType, Function, Number
from metasp.utils.logging import COLORS
import sys

log = logging.getLogger(__name__)


def default_print_model(model: Model, system) -> None:
    """
    Print the model.

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    sys.stdout.write("\n".join([str(sym) for sym in model.symbols(shown=True)]))
    sys.stdout.write("\n")


def print_symbol_str(s: Symbol) -> str:
    if s.type == SymbolType.Function and s.name.startswith("__"):
        s_str = str(s)
        s_str = s_str.replace("__", "&")
        return f"{COLORS['YELLOW']}{s_str}{COLORS['NORMAL']}"
    return str(s)


def temporal_printer(model: Model, system) -> None:
    """
    Prints the model as in telingo, separating the states.

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    assert "n" in system.constants, "system must have a 'n' property for the trace length to use temporal_printer"
    l = int(system.constants["n"]) + 1
    table = {}
    extra_shown = []
    for sym in model.symbols(shown=True):
        if sym.type == SymbolType.Function and len(sym.arguments) > 0 and sym.name == "true":
            formula = sym.arguments[0]
            table.setdefault(sym.arguments[-1].number, []).append(formula)
        else:
            extra_shown.append(sym)
    if len(extra_shown) > 0:
        sys.stdout.write(" Other shown symbols:\n")
        for sym in extra_shown:
            sys.stdout.write(" {}".format(sym))
        sys.stdout.write("\n\n")
    for step in range(l):
        symbols = table.get(step, [])
        sys.stdout.write(" State {}:".format(step))
        sig = None
        for sym in sorted(symbols):
            if (sym.name, len(sym.arguments), sym.positive) != sig:
                # sys.stdout.write("\n ")
                sig = (sym.name, len(sym.arguments), sym.positive)
            sys.stdout.write(" {}".format(print_symbol_str(sym)))
        sys.stdout.write("\n")
    sys.stdout.write("\n")
