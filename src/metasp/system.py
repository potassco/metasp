from collections.abc import Sequence
import sys
import importlib.util
from typing import Callable, List, Optional
from clingo import Control
from metasp.base_solver import get_base_solver_class
from metasp.preprocess import preprocess
from clingo import Control, Symbol, Model, SymbolType
from clingox.reify import Reifier

import logging
import os
import re
from metasp.printing import __dict__ as metasp_printing_dict

log = logging.getLogger(__name__)


class MetaSystem:

    def __init__(
        self,
        name: str,
        solver: str,
        syntax_encoding: Sequence[str],
        semantics_encoding: Sequence[str],
        print_model: str = "default_print_model",
        constants: Optional[Sequence[str]] = None,
        python_scripts: Optional[Sequence[str]] = None,
    ):
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
        self.print_model_name = print_model
        self.constants = constants or []
        self.python_scripts = python_scripts or []

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
            print_model=config.get("print-model", "default_print_model"),
            constants=config.get("constants", []),
            python_scripts=config.get("python-scripts", []),
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

    def preprocess(self, files: Sequence[str], constants: Sequence[str]) -> str:
        """
        Preprocess the system.
        It will do the preprocessing of the input files
        """
        preprocessed_input = preprocess(files, constants, self.syntax_encoding)
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
        log.debug("Printing model using '%s' function", self.print_model_name)
        script_functions = {}
        for script_path in self.python_scripts:
            log.debug(f"Loading python script: {script_path}")
            module_name = os.path.splitext(os.path.basename(script_path))[0]
            spec = importlib.util.spec_from_file_location(module_name, script_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            for attr in dir(module):
                obj = getattr(module, attr)
                if callable(obj):
                    script_functions[attr] = obj
        log.debug(f"Available print functions: {list(script_functions.keys()) + list(metasp_printing_dict.keys())}")
        if self.print_model_name in script_functions:
            script_functions[self.print_model_name](model, self)
            return
        printing_func = metasp_printing_dict.get(self.print_model_name)
        if printing_func is not None:
            printing_func(model, self)
        else:
            log.error(f"Print model function '{self.print_model_name}' not found")
            raise ValueError(f"Print model function '{self.print_model_name}' not found")

    def parse_constants(self, constants: Sequence[str]) -> None:
        """
        Parse the constants and add them to the system.
        Args:
            constants (Sequence[str]): The constants to be added to the system.
        """
        input_consts = {c.split("=")[0]: c.split("=")[1] for c in constants}
        for const in self.constants:
            if const not in input_consts:
                log.error(f"You must provide the constant {const} to run the system.")
                raise ValueError(f"You must provide the constant {const} to run the system.")
            # Create a new attribute in the class with this constant
            setattr(self, const, input_consts[const])

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
        self.parse_constants(constants)
        log.info("Running system with base solver %s", self.solver_name)
        self.base_solver = get_base_solver_class(self.solver_name)(control, constants)
        processed_input = self.preprocess(files, constants)
        reified_input = self.reify(processed_input, constants)
        self.meta_solve(control, reified_input)
