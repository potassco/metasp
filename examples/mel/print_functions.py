from clingo import Model, SymbolType
import sys

from metasp.printing import print_symbol_str


def mel_printer(model: Model, system) -> None:
    """
    Prints the model as in mel separating the states.

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    l = int(system.constants["n"]) + 1
    table = {}
    times = {}
    extra_shown = []

    for sym in model.symbols(theory=True):
        if sym.type == SymbolType.Function and sym.name == "__csp" and len(sym.arguments) == 2:
            if (
                sym.arguments[0].type == SymbolType.Function
                and len(sym.arguments[0].arguments) > 0
                and sym.arguments[0].name == "t"
            ):
                times[sym.arguments[0].arguments[0].number] = sym.arguments[1].number
    for sym in model.symbols(shown=True):
        if sym.type == SymbolType.Function and len(sym.arguments) > 0 and sym.name == "true":
            table.setdefault(sym.arguments[-1].number, []).append(sym.arguments[0])
        else:
            extra_shown.append(sym)
    if len(extra_shown) > 0:
        sys.stdout.write(" Other shown symbols:\n")
        for sym in extra_shown:
            sys.stdout.write(" {}".format(sym))
        sys.stdout.write("\n\n")
    for step in range(l):
        symbols = table.get(step, [])
        sys.stdout.write("State {} \033[94m @{}:\033[0m".format(step, times.get(step, "?")))
        sig = None
        for sym in sorted(symbols):
            if (sym.name, len(sym.arguments), sym.positive) != sig:
                # sys.stdout.write("\n ")
                sig = (sym.name, len(sym.arguments), sym.positive)
            sys.stdout.write(" {}".format(print_symbol_str(sym)))
        sys.stdout.write("\n")
    sys.stdout.write("\n")
