import os
import re
import logging
import importlib.util
from collections.abc import Sequence
from typing import Callable, Optional
from clingo import Control
from metasp.controls import get_clinguin_backend_control, get_control_wrapper_cls
from metasp.printing import __dict__ as metasp_printing_dict
import tempfile

log = logging.getLogger(__name__)

ENCODINGS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "encodings")


class MetaSystem:
    """
    Class representing a MetaASP system with its configurations and methods to run it.
    """

    def __init__(
        self,
        name: str,
        control_name: str,
        syntax_encoding: Sequence[str],
        semantics_encoding: Sequence[str],
        print_model: str = "default_print_model",
        constants: Optional[Sequence[str]] = None,
        python_scripts: Optional[Sequence[str]] = None,
    ):
        """
        Initialize the System with its name, control_name, and encodings.

        Args:
            name (str): The name of the system.
            control_name (str): The control wrapper to be used.
            syntax_encoding (Sequence[str]): The encoding for the syntax.
            semantics_encoding (Sequence[str]): The encoding for the semantics.
        """
        self.name = name
        self.control_name = control_name
        self.syntax_encoding = syntax_encoding
        self.semantics_encoding = semantics_encoding
        self.required_constants = constants or []
        self.constants = {}
        self.python_scripts = python_scripts or []
        self._set_printing_function(print_model)

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
            control_name=config["control-name"],
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
        log.debug(f"Processing file: {file}")
        with open(file, "r") as f:
            file_content = f.read()
            file_content = re.sub(
                r'#include\s+"metasp\.([^"]+)"',
                lambda m: f'#include "{os.path.join(ENCODINGS_PATH, m.group(1))}"',
                file_content,
            )
        title = "\n\n%%%%%% File: {} %%%%%%\n\n".format(file)
        return title + file_content

    def _set_printing_function(self, print_model_name: str) -> None:
        """
        Set the printing function for the system.

        Raises:
            ValueError: If the printing function is not found.
        """
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
        if print_model_name in script_functions:
            self.print_model = lambda model: script_functions[print_model_name](model, self)
            return

        printing_func = metasp_printing_dict.get(print_model_name)
        if printing_func is None:
            log.error(
                f"Print model function '{print_model_name}' not found. Available print functions: {list(script_functions.keys()) + list(metasp_printing_dict.keys())}"
            )
            raise ValueError(f"Print model function '{print_model_name}' not found")

        self.print_model = lambda model: printing_func(model, self)

    def set_constants(self, constants: dict[str, str]) -> None:
        """
        Parse the constants and add them to the system.

        Args:
            constants (dict[str, str]): The constants to be added to the system.
        Raises:
            ValueError: If a required constant is not provided.
        """
        for const in self.required_constants:
            if const not in constants:
                log.error(f"You must provide the constant {const} to run the system.")
                raise ValueError(f"You must provide the constant {const} to run the system.")
            # Create a new attribute in the class with this constant
            self.constants[const] = constants[const]

    def set_control(self, control: Control) -> None:
        """
        Set the control object for the system.

        Args:
            control (Control): The clingo control object.
        """
        self.ctl = get_control_wrapper_cls(self.control_name)(control)
        log.info("Control set to %s", self.control_name)

    def meta_compute(self, reified_input: str, on_model: Optional[Callable] = None) -> None:
        """
        Last step where using the control object from the application class
        it will ground and solve with reified input and the program semantics.
        The semantics are transformed to allow the include statements for metasp files.
        The methods set_control and set_constants should be called before this method.

        Args:
            control (Control): The clingo control object with the command line options from the application class.
            reified_input (str): The reified input data to be solved.
            on_model (Optional[Callable]): Optional callback function to be called on each model found. Useful for testing and custom API usage.
        """
        assert hasattr(self, "ctl"), "Control must be set before calling meta_compute"
        # Program to avoid warnings
        semantics_with_includes = "\n".join([self._replace_package_includes(f) for f in self.semantics_encoding])
        self.ctl.add("base", [], reified_input)
        self.ctl.add("base", [], semantics_with_includes)
        for file in self.syntax_encoding:
            self.ctl.load(file)
        self.ctl.ground([("base", [])])
        self.ctl.solve(on_model=on_model)

    def clinguin_command(self, reified_input: str) -> Sequence[str]:
        """
        Generate the clinguin command for the system. With the given reified input.

        Args:
            reified_input (str): The reified input data to be solved.
        Returns:
            str: The clinguin command to be executed.
        """
        semantics_with_includes = "\n".join([self._replace_package_includes(f) for f in self.semantics_encoding])

        log.warning("Show statements removed. Can be fixed when we decide if we want tuples or not")
        semantics_with_includes = "\n".join(
            line for line in semantics_with_includes.splitlines() if not line.rstrip().endswith('show-time.lp".')
        )

        with tempfile.NamedTemporaryFile(mode="w", suffix=".lp", delete=False) as tmp_file:
            tmp_file.write(semantics_with_includes)
            tmp_file.write("\n")
            tmp_file.write(reified_input)
            tmp_file.write("#external shown_modality(M): modality(M,_,_,_).\n")
            tmp_file.write(f"metasp_system({self.name}).\n")

            tmp_file_path = tmp_file.name
        command = ["clinguin", "client-server", "--domain-files", tmp_file_path] + self.syntax_encoding
        command += ["--ui-files", os.path.join(ENCODINGS_PATH, "ui.lp")]
        command += [f"-c {k}={v}" for k, v in self.constants.items()]
        backend_name = get_clinguin_backend_control(self.control_name)
        command += [f"--backend {backend_name}"]
        # command += ["--server-log-level", "DEBUG"]
        return command

    # def main(self, control: Control, constants: Sequence[str], files: Sequence[str]) -> None:
    #     """
    #     Run the system. It will create the control wrapper, preprocess the input files,
    #     reify the input and call the meta_compute method to solve the reified input
    #     using the semantics encoding.

    #     Args:
    #         control: The  clingo control object with the command line options from the application class.
    #         Will be used in the last step to solve given the reified program.
    #         constants: The list of constants to be, tho they might have been added to the control already,
    #         we need them explicitly to use them in the reification.
    #         files: The list of files to process.
    #     """
    #     self.set_constants(constants)
    #     processed_input = preprocess(files, constants, self.syntax_encoding)
    #     reified_input = reify(processed_input, constants)
    #     self.set_control(control)
    #     self.meta_compute(reified_input)
