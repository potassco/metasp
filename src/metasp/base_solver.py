import logging
import sys
from typing import Any, Callable, Optional, Sequence
from clingo import Control, Model, Function, Number, Symbol, SymbolType
from clingo.script import enable_python
from clingo.theory import Theory
from clingo.ast import ProgramBuilder, parse_files, parse_string
from clingcon import ClingconTheory
from clingox.reify import Reifier
from metasp.preprocess import preprocess

log = logging.getLogger(__name__)


class ClingoBaseSolver:

    def __init__(self, ctl: Control, constants: Sequence[str]):
        """
        Creates an approach with a control
        Args:
            ctl (Control): The clingo control
        """
        enable_python()
        self.ctl = ctl
        self.constants = constants

    def load(self, prg: str, files: Optional[Sequence[str]] = None) -> None:
        """
        Loads and adds needed info.
        Args:
            prg (str): Input program
            files (Optional[Sequence[str]], optional): Additional files. Defaults to None.
        """
        for f in files or []:
            log.debug("Loading file: %s", f)
            self.ctl.load(f)
        log.debug("Adding base program\n%s", prg)
        self.ctl.add("base", [], prg)

    def ground(self):
        """
        Grounds the base program and adds a program observer to print such program
        """
        log.info("Grounding...")
        self.ctl.ground([("base", [])])

    def solve(self, on_model: Optional[Callable] = None):
        """
        Calls the solve method
        Args:
            on_model (Optional[Callable], optional): A possible callback. Defaults to None.
        """
        log.info("Solving...")
        self.ctl.solve(on_model=on_model)  # nocoverage

    def print_model(self, model: Model) -> None:
        """
        Print the model.
        Args:
            model (Model): The clingo model to be printed.
        """
        sys.stdout.write(" ".join([str(sym) for sym in model.symbols(shown=True)]))
        sys.stdout.write("\n")

    def create_on_model(self, on_model: Optional[Callable[..., Any]] = None) -> Callable:
        return on_model


class TemporalClingoBaseSolver(ClingoBaseSolver):

    def __init__(self, ctl: Control, constants: Sequence[str]):
        """
        Creates a TemporalClingo base solver with a control.
        Args:
            ctl (Control): The clingo control.
            constants (Sequence[str]): The constants to be used in the reification.
        """
        super().__init__(ctl, constants)
        self._assert_lambda_constant()

    def _assert_lambda_constant(self) -> None:
        """
        Assert that there is a constant in the form lambda=<num>.
        """
        if not any(c.startswith("lambda=") for c in self.constants):
            log.error(
                "You must provide a constant in the form lambda=<num> to run the system. Add -c lambda=N to the command line."
            )
            raise ValueError("You must provide a constant in the form lambda=<num> to run the system.")
        else:
            self.lambda_constant = int(next(c.split("=", 1)[1] for c in self.constants if c.startswith("lambda=")))

    def print_model(self, model: Model) -> None:
        """
        Prints the model as in telingo separating the states.
        Args:
            model (Model): The clingo model to be printed.
        """
        l = int(str(self.ctl.get_const("lambda")))
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


class TheoryBaseSolver(TemporalClingoBaseSolver):

    def __init__(self, ctl: Control, constants: Sequence[str], theory_class: Theory):
        """
        Creates an approach with a control
        Args:
            ctl (Control): The clingo control
            theory_class (Theory): The theory class to be used.
        """
        super().__init__(ctl, constants)
        self.theory_class = theory_class

    def load(self, prg: str, files: Optional[Sequence[str]] = None) -> None:
        """
        Loads and adds needed info.
        Args:
            prg (str): Input program
            files (Optional[Sequence[str]], optional): Additional files. Defaults to None.
        """
        self.theory = self.theory_class()
        self.theory.register(self.ctl)
        with ProgramBuilder(self.ctl) as pb:
            log.debug("Loading and transforming files: %s", files)
            parse_files(
                files,
                lambda ast: self.theory.rewrite_ast(ast, pb.add),
            )
            parse_string(
                prg,
                lambda ast: self.theory.rewrite_ast(ast, pb.add),
            )
        # super().load(prg, [])
        # super().load("a.", [])

    def create_on_model(self, on_model: Optional[Callable] = None) -> Callable:
        """
        Custom on_model that takes care of assignments
        Args:
            on_model (Callable[..., Any] | None, optional): A possible callback. Defaults to None.

        Returns:
            : A function that can be passed to the on_model in solve
        """

        def on_model_function(mdl: Model):
            if on_model is not None:
                on_model(mdl)

        return on_model_function

    def solve(self, on_model: Optional[Callable] = None):
        """
        Calls the solve method
        Args:
            on_model (Optional[Callable], optional): A possible callback. Defaults to None.
        """
        self.theory.prepare(self.ctl)
        super().solve(on_model)


class ClingconBaseSolver(TheoryBaseSolver):

    def __init__(self, ctl: Control, constants: Sequence[str]):
        """
        Creates a Clingcon base solver with a control.
        Args:
            ctl (Control): The clingo control.
        """
        super().__init__(ctl, constants, ClingconTheory)

    def create_on_model(self, on_model: Optional[Callable[..., Any]] = None) -> Callable:
        """
        Custom on_model that takes care of assignments
        Args:
            on_model (Callable[..., Any] | None, optional): A possible callback. Defaults to None.

        Returns:
            _type_: A function that can be passed to the on_model in solve
        """
        super_f = super().create_on_model(on_model)

        def on_model_function(mdl: Model) -> None:
            for key, val in self.theory.assignment(mdl.thread_id):
                f = Function("assignment", [key.arguments[0], Number(int(str(val)))])
                mdl.extend([f])
            super_f(mdl)

        return on_model_function

    def print_model(self, model: Model) -> None:
        super().print_model(model)
        sys.stdout.write("\nAssignment:\n\n")
        sys.stdout.write("\n".join([f"{key}={val}" for key, val in self.theory.assignment(model.thread_id)]))
        sys.stdout.write("\n\n")


BASE_SOLVERS = {
    "clingo": ClingoBaseSolver,
    "tclingo": TemporalClingoBaseSolver,
    "clingcon": ClingconBaseSolver,
}


def get_base_solver_class(solver_name: str) -> Optional[ClingoBaseSolver]:
    """
    Get the base solver for the given name.
    Args:
        solver_name (str): The name of the solver.
    Returns:
        Optional[ClingoBaseSolver]: The base solver or None if not found.
    """
    if solver_name not in BASE_SOLVERS:
        log.error("Solver '%s' not found. Available solvers: %s", solver_name, list(BASE_SOLVERS.keys()))
        raise ValueError(f"Solver '{solver_name}' not found.")
    return BASE_SOLVERS.get(solver_name, None)
