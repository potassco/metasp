import sys

from clingo import Model, SymbolType
from clingo.symbol import Function

from metasp.printing import colored_symbol_str

from flingo.translator import AUX

CSP = "__csp"
DEF = "__def"
FVAL = "__val"


def thtc_printer(model: Model, system) -> None:
    """
    Prints the model as in thtc separating the states.

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    l = int(system.constants["n"]) + 1
    table = {}
    assignments = {}

    symbols = model.symbols(theory=True)
    for symbol in sorted(symbols):
        if symbol.match(FVAL, 2):
            name, value = symbol.arguments
            time = name.arguments[1].number
            variable = str(name.arguments[0])
            value = value.number
            if variable == "_one":
                continue
            assignments.setdefault(time, []).append((variable, value))

    for sym in model.symbols(shown=True):
        if sym.type == SymbolType.Function and len(sym.arguments) > 0 and sym.name == "true":
            table.setdefault(sym.arguments[-1].number, []).append(sym.arguments[0])

    for step in range(l):
        symbols = table.get(step, [])
        sys.stdout.write("State {}:\n".format(step))
        for sym in sorted(symbols):
            sys.stdout.write(" {}\n".format(colored_symbol_str(sym)))

        if step in assignments:
            for x, v in sorted(assignments[step]):
                sys.stdout.write(" \033[94m{}={}\033[0m\n".format(x, v))

        sys.stdout.write("\n")
    sys.stdout.write("\n")
