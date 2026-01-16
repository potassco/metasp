import os
import re
import logging
import importlib.util
import tempfile
from collections.abc import Sequence
from typing import Optional
from metasp.printing import __dict__ as metasp_printing_dict

log = logging.getLogger(__name__)

ENCODINGS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "encodings")


def get_clinguin_backend_control(control_name: str) -> str:
    """
    Get the Clinguin backend control for the given name.

    Args:
        control_name (str): The name of the control.
    Returns:
        str: The clinguin backend name
    """
    if control_name == "clingcon":
        return "ClingconBackend"
    elif control_name == "clingo":
        return "ClingoBackend"
    elif control_name == "fclingo":
        return "FclingoBackend"
    else:
        log.error("Control '%s' has no backend for clinguin.", control_name)
        raise ValueError(f"Control '{control_name}' is not a valid backend for clinguin.")


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
        ui_encoding: Optional[Sequence[str]] = None,
        print_model: Optional[str] = None,
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
            ui_encoding (Sequence[str]): The additional encodings for the clinguin UI.
        """
        self.name = name
        self.control_name = control_name
        self.syntax_encoding = syntax_encoding
        self.semantics_encoding = semantics_encoding
        self.ui_encoding = ui_encoding or []
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
            ui_encoding=config.get("ui-encoding", []),
            print_model=config.get("printer", None),
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
        if print_model_name is None:
            self.print_model = None
            return
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

    def get_out_dir(self) -> str:
        """Get the output directory for the system output files.

        TODO: This generates issues when we want to have include statements in the semantics encoding because we must consider the nesting.
        Raises:
            ValueError: If no semantics encoding files are specified.

        Returns:
            str: The output directory path.
        """
        if not self.semantics_encoding:
            raise ValueError("No semantics encoding files specified.")
        out_dir = os.path.join(os.path.dirname(os.path.abspath(self.semantics_encoding[0])), "out")
        os.makedirs(out_dir, exist_ok=True)
        return out_dir

    def get_files(self, reified_input: str) -> Sequence[str]:
        """
        Get the list of files to be used for the system.

        Args:
            reified_input (str): The reified input to be included in the files.

        Returns:
            Sequence[str]: The list of file paths to be used.
        """
        semantics_with_includes = "\n".join([self._replace_package_includes(f) for f in self.semantics_encoding])

        out_dir = self.get_out_dir()
        tmp_file_path = os.path.join(out_dir, f"{self.name}_combined.lp")
        with open(tmp_file_path, "w") as tmp_file:
            tmp_file.write(semantics_with_includes)
            tmp_file.write("\n")
            tmp_file.write(reified_input)

        log.info(f"Saved combined input to temporary file: {tmp_file_path}")

        return [tmp_file_path] + list(self.syntax_encoding)

    def clinguin_command(self, reified_input: str) -> Sequence[str]:
        """
        Generate the clinguin command for the system. With the given reified input.

        Args:
            reified_input (str): The reified input data to be solved.
        Returns:
            str: The clinguin command to be executed.
        """
        with tempfile.NamedTemporaryFile(mode="w", suffix=".lp", delete=False) as tmp_file:
            tmp_file.write("#external shown_type(T): type(T).\n")
            tmp_file.write("shown_type(atom).\n")
            tmp_file.write(f"metasp_system({self.name}).\n")

        files = list(self.get_files(reified_input))
        files.append(tmp_file.name)
        files.append(os.path.join(ENCODINGS_PATH, "ui-show.lp"))
        command = ["clinguin", "client-server", "--domain-files"] + files
        command += ["--ui-files", os.path.join(ENCODINGS_PATH, "ui.lp")]
        command += self.ui_encoding
        command += [f"-c {k}={v}" for k, v in self.constants.items()]
        backend_name = get_clinguin_backend_control(self.control_name)
        command += ["--backend", backend_name]
        command += ["--explicit-show"]
        # command += ["--server-log-level", "DEBUG"]
        return command
