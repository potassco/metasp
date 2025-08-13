from typing import Callable, Optional, Sequence
import logging
from clingo import Control
from clingo.script import enable_python

log = logging.getLogger(__name__)


class ClingoBaseSolver:

    def __init__(self, ctl: Control):
        """
        Creates an approach with a control
        Args:
            ctl (Control): The clingo control
        """
        enable_python()
        self.ctl = ctl

    def load(self, prg: str, files: Optional[Sequence[str]] = None):
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


BASE_SOLVERS = {
    "clingo": ClingoBaseSolver,
}
