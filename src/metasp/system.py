"""
MetaASP system module used as the main interface for configuring and running MetaASP systems.
"""

import importlib.util
import logging
import os
import re
import shutil
import tempfile
from collections.abc import Callable, Sequence
from datetime import datetime
from io import StringIO
from pathlib import Path
from typing import Any

import tree_sitter_metasp as ts_metasp
from aspen.tree import AspenTree
from clingo import Function, Model
from tree_sitter import Language

import metasp.printing as metasp_printing

log = logging.getLogger(__name__)

ENCODINGS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "encodings")

clingo_lang = Language(ts_metasp.language())


def get_clinguin_backend_control(control_name: str) -> str:  # nocoverage
    """
    Get the Clinguin backend control for the given name.

    Args:
        control_name (str): The name of the control.
    Returns:
        str: The clinguin backend name
    """
    if control_name == "clingcon":
        return "ClingconBackend"
    if control_name == "clingo":
        return "ClingoBackend"
    if control_name == "flingo":
        return "FlingoBackend"

    log.error("Control '%s' has no backend for clinguin.", control_name)
    raise ValueError(f"Control '{control_name}' is not a valid backend for clinguin.")


class MetaSystem:  # pylint: disable=too-many-instance-attributes
    """
    Class representing a MetaASP system with its configurations and methods to run it.
    """

    def __init__(
        self,
        name: str,
        control_name: str,
        syntax_encoding: Sequence[str],
        semantics_encoding: Sequence[str],
        *,
        ui_encoding: Sequence[str] | None = None,
        print_model: str | None = None,
        constants: Sequence[str] | None = None,
        python_scripts: Sequence[str] | None = None,
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
        self.syntax_encoding = list(syntax_encoding)
        self.semantics_encoding = list(semantics_encoding)
        self.ui_encoding = list(ui_encoding or [])
        self.required_constants = list(constants or [])
        self.constants: dict[str, str] = {}
        self.python_scripts = list(python_scripts or [])
        self.print_model: Callable[[Model], Any] | None = None
        self._set_printing_function(print_model)

        out_dir = Path.cwd() / "out"
        if out_dir.exists():  # nocoverage
            for item in out_dir.iterdir():
                if item.is_file() or item.is_symlink():
                    item.unlink()
                elif item.is_dir():
                    shutil.rmtree(item)
        else:
            out_dir.mkdir(exist_ok=True)  # nocoverage
        self.out_dir = out_dir

    @classmethod
    def from_dict(cls, config: dict[str, Any]) -> "MetaSystem":
        """
        Create a MetaSystem instance from a configuration dictionary.

        Args:
            config (dict): The configuration dictionary containing system details.
        Returns:
            MetaSystem: An instance of the MetaSystem class.
        """
        log.debug("Creating MetaSystem from config: %s", config)
        if not "semantics_encoding" in config:
            log.warning(
                "The 'semantics_encoding' field is required if you attempt to solve using metasp."
                "Provided via --meta-config or directly."
            )
            # raise ValueError("Missing semantics encoding")
        return cls(
            name=config.get("name", "metasp"),
            control_name=config.get("control_name", "clingo"),
            syntax_encoding=config.get("syntax_encoding", []),
            semantics_encoding=config.get("semantics_encoding", []),
            ui_encoding=config.get("ui_encoding", []),
            print_model=config.get("printer", None),
            constants=config.get("required_constants", []),
            python_scripts=config.get("python_scripts", []),
        )

    def fo_transform(self, files: Sequence[str], prg: str) -> str:
        """
        Transforms a list of files and a program string and returns a string with the transformation.

        Rewrites show statements, generates externals, and performs safety and occurrence checks.

        Args:
            files (List[str]): The list of file paths to process.
            prg (str): The program string to process.
        """
        # #TODO Separate this function to have something that gets the grammar from the syntax
        out_dir = Path(self.out_dir)

        tree = AspenTree(default_language=clingo_lang)
        if self.syntax_encoding is None or len(self.syntax_encoding) == 0:
            log.warning("No syntax encoding files provided.")
            self.syntax_encoding = []
        for encoding_file in self.syntax_encoding:
            tree.parse(Path(encoding_file))
        input_file_symbols = [tree.parse(Path(i)) for i in files]
        str_input_symb = tree.parse(prg)

        syntax_fact_file = out_dir / "syntax_facts.lp"
        with StringIO() as buf:
            tree.textio_symbols[Function("fact_file", [])] = buf
            try:
                tree.transform(
                    meta_files=[Path(ENCODINGS_PATH) / "aspen" / "all.lp"], initial_program=("metasp_preprocess", ())
                )
            except Exception as e:
                if len(self.syntax_encoding) == 0:
                    log.error("No syntax encoding files provided is likely the cause of the error.")
                log.error("Error transforming input.\n Error: %s", e)
                raise e
            facts_str = buf.getvalue().strip().replace("&", "__")
        with open(syntax_fact_file, "w", encoding="utf-8") as fact_file:
            fact_file.write(facts_str)
        self.syntax_encoding = [str(syntax_fact_file)]

        rewritten_program_str = ""
        for i in input_file_symbols:
            source = tree.sources[i]
            rewritten_program_str += str(source.source_bytes, encoding=source.encoding)

        str_input_source = tree.sources[str_input_symb]
        rewritten_program_str += str(str_input_source.source_bytes, encoding=str_input_source.encoding)
        if len(files) > 0:
            fname = "_".join([Path(f).stem for f in files]) + "_stdin.lp"
        else:
            fname = "stdin.lp"
        with open(out_dir / fname, "w", encoding="utf-8") as f:
            f.write(rewritten_program_str)

        tree = AspenTree(default_language=clingo_lang)
        semantic_enc_symbols = [tree.parse(Path(e)) for e in self.semantics_encoding]
        tree.transform(
            meta_files=[Path(ENCODINGS_PATH) / "aspen" / "remove_ampersand.lp"],
            initial_program=("metasp_remove_ampersand", ()),
        )
        for s in semantic_enc_symbols:
            source = tree.sources[s]
            p = source.path
            assert p is not None
            out_file = out_dir / ("semantics_rewritten.lp")
            # TODO: Fix this better, because at the moment if you have different paths
            # it uses a single file name and replaces things
            with open(out_file, "a", encoding="utf-8") as sem_file:
                sem_file.write(str(source.source_bytes, encoding=source.encoding))
        self.semantics_encoding = [str(out_dir / "semantics_rewritten.lp")]
        return rewritten_program_str

    def _replace_package_includes(self, file: str) -> str:
        """
        Replace #include statements using metasp.file_name with the path of the metasp implementation.

        Args:
            file (str): The file name to be processed.
        Returns:
            str: The processed file name with package includes.
        """
        log.debug("Processing file: %s", file)
        with open(file, "r", encoding="utf-8") as f:
            file_content = f.read()
            has_other_includes = re.search(r'#include\s+"(?!metasp\.)[^"]+"', file_content) is not None
            if has_other_includes:  # nocoverage
                log.warning(
                    "File %s contains #include statements that do not use the 'metasp.' prefix. "
                    "The use of & in these files will not be properly handled. "
                    "Add the file to the semantics_encoding instead for the system to properly handle them.",
                    file,
                )
            file_content = re.sub(
                r'#include\s+"metasp\.([^"]+)"',
                lambda m: f'#include "{os.path.join(ENCODINGS_PATH, m.group(1))}"',
                file_content,
            )
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        title = f"\n%%%%%% Created: {timestamp} \n%%%%%% File: {file} \n\n"
        return title + file_content

    def _set_printing_function(self, print_model_name: str | None) -> None:
        """
        Set the printing function for the system.

        Raises:
            ValueError: If the printing function is not found.
        """
        if print_model_name is None:
            self.print_model = None
            return
        script_functions: dict[str, Callable[..., Any]] = {}
        for script_path in self.python_scripts:
            log.debug("Loading python script: %s", script_path)
            module_name = os.path.splitext(os.path.basename(script_path))[0]
            spec = importlib.util.spec_from_file_location(module_name, script_path)
            if spec is None or spec.loader is None:
                raise ImportError(f"Could not load Python script '{script_path}'.")
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            for attr in dir(module):
                obj = getattr(module, attr)
                if callable(obj):
                    script_functions[attr] = obj
        if print_model_name in script_functions:
            self.print_model = lambda model: script_functions[print_model_name](model, self)
            return

        printing_func = vars(metasp_printing).get(print_model_name)
        if printing_func is None:  # nocoverage
            log.error(
                "Print model function '%s' not found.\n"
                "Available print functions: %s",
                print_model_name,
                list(script_functions.keys()) + list(vars(metasp_printing).keys()),
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
                log.error("You must provide the constant %s  to run the system, using -c %s=<val>.", const, const)
                raise ValueError(f"You must provide the constant  {const} to run the system, using -c {const}=<val>.")
        self.constants = constants.copy()

    def get_files(self, reified_input: str) -> Sequence[str]:
        """
        Get the list of files to be used for the system.

        Args:
            reified_input (str): The reified input to be included in the files.

        Returns:
            Sequence[str]: The list of file paths to be used.
        """
        semantics_with_includes = "\n".join([self._replace_package_includes(f) for f in self.semantics_encoding])

        tmp_file_path = os.path.join(self.out_dir, f"{self.name}_combined.lp")
        with open(tmp_file_path, "w", encoding="utf-8") as tmp_file:
            tmp_file.write(semantics_with_includes)
            tmp_file.write("\n")
            tmp_file.write(reified_input)

        log.info("Saved combined input to temporary file: %s", tmp_file_path)

        return [tmp_file_path] + list(self.syntax_encoding)

    def clinguin_command(self, reified_input: str) -> Sequence[str]:  # nocoverage
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
        command += ["--server-log-level", logging.getLevelName(log.getEffectiveLevel())]
        return command
