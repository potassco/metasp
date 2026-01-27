import os
import re
import logging
import importlib.util
import tempfile
from collections.abc import Sequence
from typing import Optional, List
from pathlib import Path
from io import StringIO

from aspen.tree import AspenTree
from tree_sitter import Language
import tree_sitter_clingo as ts_clingo
from clingo import Function

from metasp.printing import __dict__ as metasp_printing_dict

log = logging.getLogger(__name__)

ENCODINGS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "encodings")

clingo_lang = Language(ts_clingo.language())


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

        out_dir = Path.cwd() / "out"
        out_dir.mkdir(exist_ok=True)
        self.out_dir = out_dir

    @classmethod
    def from_dict(cls, config: dict) -> "MetaSystem":
        """
        Create a MetaSystem instance from a configuration dictionary.

        Args:
            config (dict): The configuration dictionary containing system details.
        Returns:
            MetaSystem: An instance of the MetaSystem class.
        """
        log.debug(f"Creating MetaSystem from config: {config}")
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

    def fo_transform(self, files: List[str], prg: str) -> str:
        """
        Transforms a list of files and a program string and returns a string with the transformation.

        Rewrites show statements, generates externals, and performs safety and occurrence checks.

        Args:
            files (List[str]): The list of file paths to process.
            prg (str): The program string to process.
        """
        out_dir = Path(self.out_dir)
        tree = AspenTree(default_language=clingo_lang)

        syntax_enc_symbols = [tree.parse(Path(e)) for e in self.syntax_encoding]
        input_file_symbols = [tree.parse(Path(i)) for i in files]
        str_input_symb = tree.parse(prg)

        syntax_fact_file = out_dir / "syntax_facts.lp"
        with StringIO() as buf:
            tree.textio_symbols[Function("fact_file", [])] = buf
            tree.transform(
                meta_files=[Path(ENCODINGS_PATH) / "aspen" / "all.lp"], initial_program=("metasp_preprocess", ())
            )
            facts_str = buf.getvalue().strip().replace("&", "__")
        with open(syntax_fact_file, "w") as fact_file:
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
        with open(out_dir / fname, "w") as f:
            f.write(rewritten_program_str)

        tree = AspenTree(default_language=clingo_lang)
        semantic_enc_symbols = [tree.parse(Path(e)) for e in self.semantics_encoding]
        tree.transform(
            meta_files=[Path(ENCODINGS_PATH) / "aspen" / "remove_ampersand.lp"],
            initial_program=("metasp_remove_ampersand", ()),
        )
        semantics_encoding: list[str] = []
        for s in semantic_enc_symbols:
            source = tree.sources[s]
            p = source.path
            assert p is not None
            stem = p.stem
            out_file = out_dir / (stem + "_rewritten.lp")
            with open(out_file, "w") as sem_file:
                sem_file.write(str(source.source_bytes, encoding=source.encoding))
            semantics_encoding.append(str(out_file))
        self.semantics_encoding = semantics_encoding
        return rewritten_program_str

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
                log.error(f"You must provide the constant {const}  to run the system, using -c {const}=<val>.")
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
