"""
Module with all printing functions that will be available for the print_model
Custom printing functions can be provided by adding the script in the configuration
"""

from typing import Callable, Optional
from clingo import Model, Symbol, SymbolType, Function, Number
import sys


def default_print_model(model: Model, system) -> None:
    """
    Print the model.

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    sys.stdout.write(" ".join([str(sym) for sym in model.symbols(shown=True)]))
    sys.stdout.write("\n")


def telingo_print_model(model: Model, system) -> None:
    """
    Prints the model as in telingo, separating the states.

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    assert hasattr(system, "horizon"), "system must have a 'horizon' property to use telingo_print_model"
    l = int(system.horizon) + 1
    table = {}
    for sym in model.symbols(shown=True):
        if sym.type == SymbolType.Function and len(sym.arguments) > 0 and sym.name == "":
            table.setdefault(sym.arguments[-1].number, []).append(sym.arguments[0])
    for step in range(l):
        symbols = table.get(step, [])
        sys.stdout.write(" State {}:".format(step))
        sig = None
        for sym in sorted(symbols):
            if (sym.name, len(sym.arguments), sym.positive) != sig:
                sys.stdout.write("\n ")
                sig = (sym.name, len(sym.arguments), sym.positive)
            sys.stdout.write(" {}".format(sym))
        sys.stdout.write("\n")
    sys.stdout.write("\n")
