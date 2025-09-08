from clingo import Model, SymbolType, Function
import sys
from fclingo.translator import AUX

CSP = "__csp"
DEF = "__def"


def thtc_print_model(model: Model, system) -> None:
    """
    Prints the model as in melingo separating the states.

    Args:
        model (Model): The clingo model to be printed.
        system (MetaSystem): The metasp system.
    """
    l = int(system.constants["horizon"]) + 1
    table = {}
    assignments = {}
    # shown = [str(atom) for atom in model.symbols(shown=True) if not (atom.name == DEF and len(atom.arguments) == 1)]
    valuation = [
        (assignment.arguments[0], assignment.arguments[1])
        for assignment in model.symbols(theory=True)
        if assignment.name == CSP
        and len(assignment.arguments) == 2
        and model.contains(Function(DEF, [assignment.arguments[0]]))
        and not assignment.arguments[0].name == AUX
    ]
    # valuation_val_symbols = [f"val({str(x)},{str(v)})" for (x, v) in valuation]
    # shown.extend(valuation_val_symbols)
    # print(valuation_val_symbols)
    for x, v in valuation:
        if x.type == SymbolType.Function and x.name == "var" and len(x.arguments) == 2:
            time = x.arguments[1].number
            variable = str(x.arguments[0])
            value = v.number
            if variable == "_one":
                continue
            assignments.setdefault(time, []).append((variable, value))

    for sym in model.symbols(shown=True):
        if sym.type == SymbolType.Function and len(sym.arguments) > 0 and sym.name == "true":
            table.setdefault(sym.arguments[-1].number, []).append(sym.arguments[0])

    for step in range(l):
        symbols = table.get(step, [])
        sys.stdout.write("State {}:\n".format(step))
        # sig = None
        for sym in sorted(symbols):
            # if (sym.name, len(sym.arguments), sym.positive) != sig:
            #     sys.stdout.write("\n ")
            #     sig = (sym.name, len(sym.arguments), sym.positive)
            sys.stdout.write(" {}\n".format(sym))

        if step in assignments:
            for x, v in sorted(assignments[step]):
                sys.stdout.write(" \033[94m{}={}\033[0m\n".format(x, v))

        sys.stdout.write("\n")
    sys.stdout.write("\n")
