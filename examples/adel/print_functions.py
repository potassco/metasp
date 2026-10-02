import sys

from clingo import Model, SymbolType

from metasp.printing import colored_symbol_str


def adel_printer(model: Model, system) -> None:
    """
    Prints the model as in ADEL with the labels

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    l = int(system.constants["n"]) + 1
    table = {}
    labels = {}
    extra_shown = []
    for sym in model.symbols(shown=True):
        if sym.type == SymbolType.Function and sym.name == "label" and len(sym.arguments) == 2:
            i, j = sym.arguments[1].arguments
            labels.setdefault(i.number, []).append(sym.arguments[0])
        elif sym.type == SymbolType.Function and len(sym.arguments) > 0 and sym.name == "true":
            table.setdefault(sym.arguments[-1].number, []).append(sym.arguments[0])
        else:
            extra_shown.append(sym)
    if len(extra_shown) > 0:
        sys.stdout.write(" Other shown symbols:\n")
        for sym in extra_shown:
            sys.stdout.write(f" {sym}")
        sys.stdout.write("\n\n")
    for step in range(l):
        symbols = table.get(step, [])
        sys.stdout.write(f"State {step}:\033[92m")
        sig = None
        for sym in sorted(symbols):
            if (sym.name, len(sym.arguments), sym.positive) != sig:
                sig = (sym.name, len(sym.arguments), sym.positive)
            sys.stdout.write(f" {colored_symbol_str(sym)}")
        sys.stdout.write("\033[0m\n")
        if step + 1 < l:
            label = labels.get(step, [])
            sys.stdout.write("\033[94m↓  ")
            for sym in sorted(label):
                sys.stdout.write(f" {colored_symbol_str(sym)}")
            sys.stdout.write("\033[0m\n")
    sys.stdout.write("\n")
