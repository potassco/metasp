from importlib.metadata import files
import logging
import sys
from typing import Any, Callable, Optional, Sequence, Union, Tuple
from clingo import Control, Model, Function, Number, Symbol, SymbolType, SolveHandle, SolveResult
from clingo.script import enable_python
from clingo.theory import Theory
from clingo.ast import ProgramBuilder, parse_files, parse_string
from clingcon import ClingconTheory
from fclingo import THEORY, Translator
from fclingo.__main__ import CSP, DEF, Statistic
from fclingo.parsing import HeadBodyTransformer

log = logging.getLogger(__name__)


class ClingoControl:

    def __init__(self, ctl: Control):
        """
        Creates an approach with a control

        Args:
            ctl (Control): The clingo control
        """
        enable_python()
        self.ctl = ctl

    def __getattr__(self, name: str) -> Any:
        """
        Delegate attribute access to the underlying Control object.
        """
        if name in self.__dict__:
            return self.__dict__[name]
        log.debug("Delegating attribute access to Control: %s", name)
        return getattr(self.ctl, name)

    def solve(
        self,
        **kwargs: Any,
    ) -> Union[SolveHandle, SolveResult]:
        """
        Calls the solve method

        Args:
            on_model (Optional[Callable], optional): A possible callback. Defaults to None.
        """

        original_on_model = kwargs.get("on_model", None)

        def on_model_function(mdl: Model) -> None:
            self.custom_on_model(mdl)
            if original_on_model is not None:
                original_on_model(mdl)

        kwargs["on_model"] = on_model_function
        self.ctl.solve(**kwargs)

    def custom_on_model(self, model: Model) -> None:
        pass


class TheoryControl(ClingoControl):

    def __init__(self, ctl: Control, theory_class: Theory):
        """
        Creates an approach with a control

        Args:
            ctl (Control): The clingo control
            theory_class (Theory): The theory class to be used.
        """
        super().__init__(ctl)
        self.theory_class = theory_class
        self.theory = self.theory_class()
        self.theory.register(self.ctl)

    def load(self, path: str) -> None:
        """
        Loads and adds needed info.

        Args:
            path (str): The path to the file to load.
        """
        with ProgramBuilder(self.ctl) as pb:
            log.debug("Loading and transforming files: %s", path)
            parse_files(
                [path],
                lambda ast: self.theory.rewrite_ast(ast, pb.add),
            )

    def add(self, name: str, parameters: Sequence[str], program: str) -> None:
        """
        Loads and adds needed info.

        Args:
            name (str): The name of the program.
            parameters (Sequence[str]): The parameters for the program.
            program (str): The program to add.
        """
        assert name == "base", "Only the base program can be added in this way."
        with ProgramBuilder(self.ctl) as pb:
            parse_string(
                program,
                lambda ast: self.theory.rewrite_ast(ast, pb.add),
            )

    def custom_on_model(self, model: Model) -> None:
        self.theory.on_model(model)
        for key, val in self.theory.assignment(model.thread_id):
            f = Function("_assignment", [key, Number(int(str(val)))])
            model.extend([f])
        return super().custom_on_model(model)

    def solve(
        self,
        **kwargs: Any,
    ) -> Union[SolveHandle, SolveResult]:
        """
        Calls the solve method

        Args:
            on_model (Optional[Callable], optional): A possible callback. Defaults to None.
        """
        self.theory.prepare(self.ctl)
        super().solve(**kwargs)


class ClingconControl(TheoryControl):

    def __init__(self, ctl: Control):
        """
        Creates a Clingcon control wrapper with a control.

        Args:
            ctl (Control): The clingo control.
        """
        super().__init__(ctl, ClingconTheory)


class Config:
    def __init__(self, max_int, min_int, print_trans, defined) -> None:
        self.max_int = max_int
        self.min_int = min_int
        self.print_trans = print_trans
        self.defined = defined


class FclingoControl(TheoryControl):

    def __init__(self, ctl: Control):
        """
        Creates a Fclingo control wrapper with a control.

        Args:
            ctl (Control): The clingo control.
        """
        super().__init__(ctl, ClingconTheory)
        ctl.add("base", [], THEORY)
        # self.translator = Translator(ctl, Config(self.maxint, self.minint, False, DEF),Statistic())
        self.translator = Translator(ctl, Config(100, -100, False, DEF), Statistic())

        self.hbt = HeadBodyTransformer()

    def load(self, path: str) -> None:
        """
        Loads and adds needed info.

        Args:
            path (str): The path to the file to load.
        """
        with ProgramBuilder(self.ctl) as pb:
            log.debug("Loading and transforming files: %s", path)

            parse_files(
                [path],
                lambda ast: self.theory.rewrite_ast(ast, lambda stm: pb.add(self.hbt.visit(stm))),
            )

    def add(self, name: str, parameters: Sequence[str], program: str) -> None:
        """
        Adds a program to the control.

        Args:
            name (str): The name of the program.
            parameters (Sequence[str]): The parameters for the program.
            program (str): The program to add.
        """
        assert name == "base", "Only the base program can be added in this way."
        with ProgramBuilder(self.ctl) as pb:
            parse_string(
                program,
                lambda ast: self.theory.rewrite_ast(ast, lambda stm: pb.add(self.hbt.visit(stm))),
            )

    def custom_on_model(self, model: Model) -> None:
        self.theory.on_model(model)

        # m = []
        # for sym in model.symbols(shown=True):
        #     s = str(sym)
        #     if not s.startswith("_"):
        #         m.append(s)
        # a = [
        #     (str(assignment.arguments[0]), assignment.arguments[1].number)
        #     for assignment in model.symbols(theory=True)
        #     if assignment.name == CSP
        #     and len(assignment.arguments) == 2
        #     and not assignment.arguments[0].name.startswith("_")
        # ]

        print(model.symbols(theory=True))
        # ret.append((sorted(m), sorted(a)))
        # print((sorted(m), sorted(a)))

    def solve(self, **kwargs: Any) -> Union[SolveHandle, SolveResult]:
        """
        Calls the solve method

        Args:
            on_model (Optional[Callable], optional): A possible callback. Defaults to None.
        """

        self.translator.translate(self.ctl.theory_atoms)

        self.theory.prepare(self.ctl)
        super().solve(**kwargs)


CONTROL_WRAPPERS = {
    "clingo": ClingoControl,
    "clingcon": ClingconControl,
    "fclingo": FclingoControl,
}


def get_control_wrapper_cls(control_name: str) -> Optional[ClingoControl]:
    """
    Get the control wrapper for the given name.

    Args:
        control_name (str): The name of the control.
    Returns:
        Optional[ClingoControl]: The control wrapper or None if not found.
    """
    if control_name not in CONTROL_WRAPPERS:
        log.error("Control '%s' not found. Available controls: %s", control_name, list(CONTROL_WRAPPERS.keys()))
        raise ValueError(f"Control '{control_name}' not found.")
    return CONTROL_WRAPPERS.get(control_name, None)


def get_clinguin_backend_control(control_name: str) -> str:
    """
    Get the Clinguin backend control for the given name.

    Args:
        control_name (str): The name of the control.
    Returns:
        str: The clinguin backend name
    """
    if control_name not in CONTROL_WRAPPERS:
        log.error("Control '%s' not found. Available controls: %s", control_name, list(CONTROL_WRAPPERS.keys()))
        raise ValueError(f"Control '{control_name}' not found.")
    if control_name == "clingcon":
        return "ClingconBackend"
    elif control_name == "clingo":
        return "ClingoBackend"
    elif control_name == "fclingo":
        return "FclingoBackend"
    else:
        log.error("Control '%s' is not a valid backend for clinguin.", control_name)
        raise ValueError(f"Control '{control_name}' is not a valid backend for clinguin.")
