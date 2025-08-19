from clingo import Model, SymbolType
import sys


def melingo_print_model(model: Model, system) -> None:
    """
    Prints the model as in melingo separating the states.

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    l = int(system.horizon) + 1
    table = {}
    times = {}
    for sym in model.symbols(theory=True):
        if sym.type == SymbolType.Function and sym.name == "_assignment" and len(sym.arguments) == 2:
            if (
                sym.arguments[0].type == SymbolType.Function
                and len(sym.arguments[0].arguments) > 0
                and sym.arguments[0].name == "t"
            ):
                times[sym.arguments[0].arguments[0].number] = sym.arguments[1].number

    for sym in model.symbols(shown=True):
        if sym.type == SymbolType.Function and len(sym.arguments) > 0 and sym.name == "":
            table.setdefault(sym.arguments[-1].number, []).append(sym.arguments[0])
    for step in range(l):
        symbols = table.get(step, [])
        sys.stdout.write(" State {} @{}:".format(step, times.get(step, "?")))
        sig = None
        for sym in sorted(symbols):
            if (sym.name, len(sym.arguments), sym.positive) != sig:
                sys.stdout.write("\n ")
                sig = (sym.name, len(sym.arguments), sym.positive)
            sys.stdout.write(" {}".format(sym))
        sys.stdout.write("\n")
    sys.stdout.write("\n")
