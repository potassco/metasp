from collections.abc import Sequence
import sys
from typing import Callable, List, Optional
from clingo import Control
from metasp.base_solver import get_base_solver_class
from metasp.preprocess import preprocess
from clingo import Control, Symbol, Model, SymbolType
from clingox.reify import Reifier

import logging
import os
import re

log = logging.getLogger(__name__)


class MetaSystem:

    def __init__(self, name: str, solver: str, syntax_encoding: Sequence[str], semantics_encoding: Sequence[str]):
        """
        Initialize the System with its name, solver, and encodings.
        Args:
            name (str): The name of the system.
            solver (str): The solver to be used.
            syntax_encoding (Sequence[str]): The encoding for the syntax.
            semantics_encoding (Sequence[str]): The encoding for the semantics.
        """
        self.name = name
        self.solver_name = solver
        self.syntax_encoding = syntax_encoding
        self.semantics_encoding = semantics_encoding

    @classmethod
    def from_dict(cls, config: dict) -> "MetaSystem":
        """
        Create a MetaSystem instance from a configuration dictionary.
        Args:
            config (dict): The configuration dictionary containing system details.
        Returns:
            MetaSystem: An instance of the MetaSystem class.
        """
        return cls(
            name=config["name"],
            solver=config["solver"],
            syntax_encoding=config["syntax-encoding"],
            semantics_encoding=config["semantics-encoding"],
        )

    def _replace_package_includes(self, file: str) -> str:
        """
        Replace #include statements using metasp.file_name with the path of the metasp implementation.
        Args:
            file (str): The file name to be processed.
        Returns:
            str: The processed file name with package includes.
        """
        metasp_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "encodings")
        log.debug(f"Processing file: {file}")
        with open(file, "r") as f:
            file_content = f.read()
            file_content = re.sub(
                r'#include\s+"metasp\.([^"]+)"',
                lambda m: f'#include "{os.path.join(metasp_path, m.group(1))}"',
                file_content,
            )
        title = "\n\n%%%%%% File: {} %%%%%%\n\n".format(file)
        return title + file_content

    def preprocess(self, files: Sequence[str]) -> str:
        """
        Preprocess the system.
        It will do the preprocessing of the input files
        """
        preprocessed_input = preprocess(files, self.syntax_encoding)
        return preprocessed_input

    def reify(self, processed_input: str, constants: Sequence[str]) -> str:
        """
        Reify the input data with the given constants.
        It will reify the input data with the given constants.
        Args:
            processed_input (str): The input data to be reified.
            constants (Sequence[str]): The constants to be used in the reification.
        Returns:
            str: The reified input data.
        """
        symbols: List[Symbol] = []

        ctl = Control(["--warn=none"] + [f"-c {c}" for c in constants])
        reifier = Reifier(symbols.append, reify_steps=False)
        ctl.register_observer(reifier)
        ctl.add("base", [], processed_input)
        ctl.ground([("base", [])])
        reified_input = "\n".join([str(s) + "." for s in symbols])
        title = "\n\n%%%%%% Reified Input %%%%%%\n\n"
        return title + reified_input

    def print_model(self, model: Model) -> None:
        """
        Print the model.
        Args:
            model (Model): The model to be printed.
        """
        return self.base_solver.print_model(model)

    def meta_solve(self, control: Control, reified_input: str, on_model: Optional[Callable] = None) -> None:
        """
        Solve the reified input with the given control object.
        It will run the system with the given control object.
        Args:
            control (Control): The clingo control object with the command line options from the application class.
            reified_input (str): The reified input data to be solved.
        """
        reify_defined_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "encodings", "reify_defined.lp")
        semantics_with_includes = "\n".join([self._replace_package_includes(f) for f in self.semantics_encoding])
        self.base_solver.load(reified_input + semantics_with_includes, self.syntax_encoding + [reify_defined_file])
        self.base_solver.ground()
        self.base_solver.solve(on_model=self.base_solver.create_on_model(on_model=on_model))

    def main(self, control: Control, constants: Sequence[str], files: Sequence[str]) -> None:
        """
        Run the system.
        It will run the system with the given control object.
        Args:
            control: The  clingo control object with the command line options from the application class. Will be used in the last step to solve given the reified program.
            constants: The list of constants to be, tho they might have been added to the control already, we need them explicitly to use them in the reification.
            files: The list of files to process.
        """
        self.base_solver = get_base_solver_class(self.solver_name)(control, constants)
        processed_input = self.preprocess(files)
        reified_input = self.reify(processed_input, constants)
        self.meta_solve(control, reified_input)
