import json
import sys
import logging
import textwrap
from typing import Optional

from clingo import Model
from clingo.application import Application, ApplicationOptions
from clingcon.__main__ import ClingconApp
from fclingo.__main__ import FclingoApp

from metasp.utils.parser import load_config

from .utils.logging_utils import configure_logging
from .system import MetaSystem
from metasp.grammar import Grammar
from metasp import MetaspProcessor
from clingo.script import enable_python

log = logging.getLogger(__name__)


class ClingoApp(Application):
    def __init__(self, name):
        self.program_name = name

    def print_model(self, model: Model, printer) -> None:
        model_symbols = " ".join([str(s).replace("__", "&") for s in model.symbols(shown=True)])
        sys.stdout.write(model_symbols + "\n")

    def main(self, ctl, files):
        for f in files:
            ctl.load(f)
        if not files:
            ctl.load("-")
        ctl.ground([("base", [])])
        ctl.solve()


class MyFclingoApp(FclingoApp):
    def __init__(self, name):
        super().__init__()
        self.program_name = name


APPS_BY_NAME = {
    "clingo": ClingoApp,
    "clingcon": ClingconApp,
    "fclingo": MyFclingoApp,
}


def get_app_by_name(app_name: str) -> Optional[Application]:
    """
    Get the application wrapper for the given name.

    Args:
        app_name (str): The name of the application.
    Returns:
        Optional[ClingoControl]: The application wrapper or None if not found.
    """
    if app_name not in APPS_BY_NAME:
        msg = f"Control name '{app_name}' not found. Available options: {list(APPS_BY_NAME.keys())}"
        log.error(msg)
        raise ValueError(msg)
    return APPS_BY_NAME.get(app_name, None)


def make_app(app_name: str) -> Application:

    base_class = get_app_by_name(app_name)

    class MetaspApp(base_class):
        def __init__(self, constants=None):
            """
            Create application

            Args:
                config (dict): The configuration dictionary.
                constants (Optional[dict], optional): The constants required by the system that will become attributes. Defaults to None.
            """
            super().__init__(f"Metasp ({base_class})")
            self.constants = constants or {}
            self.metasp_config = {}
            self.metasp_config_file = None
            self._log_level = "warning"
            enable_python()

        @property
        def name(self):
            return self.metasp_config.get("name", "metasp")

        def parse_log_level(self, log_level):
            """
            Parse log

            Args:
                log_level (str): The log level to set.
            Returns:
                bool: True if the log level is valid, False otherwise.
            """
            if log_level is not None:
                self._log_level = log_level.upper()
                return self._log_level in ["INFO", "WARNING", "DEBUG", "ERROR"]

            return True

        def parse_system_config(self, name, type="str") -> callable:
            def parse_option(value):
                if type == "list":
                    if name not in self.metasp_config:
                        self.metasp_config[name] = []
                    self.metasp_config[name].append(value)
                else:
                    self.metasp_config[name] = value
                return True

            return parse_option

        def parse_config(self, config_file):
            """
            Parse configuration file

            Args:
                config_file (str): The path to the configuration file.
            Returns:
                bool: True if the configuration file is valid, False otherwise.
            """
            if config_file is not None:
                self.metasp_config_file = config_file
                return True
            return False

        def register_options(self, options: ApplicationOptions) -> None:
            """
            Add custom options

            Args:
                options (ApplicationOptions): The application options to register.
            """
            group = "\033[94mMetasp - " + self.name
            options.add(
                group,
                "log",
                textwrap.dedent("""\
                    Logging level.
                                                <level> ={debug|info|error|warning}
                                                (default: warning)"""),
                self.parse_log_level,
                argument="<level>",
            )
            options.add(
                group,
                "syntax-encoding",
                textwrap.dedent("""\
                    Path to syntax encoding files with the grammar.
                                                (default: None)"""),
                self.parse_system_config("syntax_encoding", "list"),
                multi=True,
                argument="<file>",
            )
            options.add(
                group,
                "semantics-encoding",
                textwrap.dedent("""\
                    Path to semantics encoding defining the semantic extension.
                                                (default: None)"""),
                self.parse_system_config("semantics_encoding", "list"),
                multi=True,
                argument="<file>",
            )
            options.add(
                group,
                "required-constants",
                textwrap.dedent("""\
                    Constants required to run the system.
                                                (default: None)"""),
                self.parse_system_config("required_constants", "list"),
                multi=True,
                argument="<file>",
            )
            options.add(
                group,
                "ui-encoding",
                textwrap.dedent("""\
                    Path to ui encoding files extending basic encoding for interactivity.
                                                (default: None)"""),
                self.parse_system_config("ui_encoding", "list"),
                multi=True,
                argument="<file>",
            )
            options.add(
                group,
                "printer",
                textwrap.dedent("""\
                    Name for the printing function to use for models. By defaults uses clingo print
                                                (default: None)"""),
                # TODO add list of available ones
                self.parse_system_config("printer", "str"),
                argument="<file>",
            )
            options.add(
                group,
                "python-scripts",
                textwrap.dedent("""\
                    Path to python scripts to load before running the system. These files can contain custom printing functions.
                                                (default: None)"""),
                self.parse_system_config("python_scripts", "list"),
                multi=True,
                argument="<file>",
            )
            options.add(
                group,
                "meta-config",
                textwrap.dedent("""\
                    Optional path to metasp yaml configuration file, setting the arguments for the system (Use to avoid long command lines).
                                                (default: None)\033[0m"""),
                self.parse_config,
                argument="<file>",
            )
            super().register_options(options)

        def print_model(self, model: Model, printer) -> None:
            """
            Print the model using the system's printing function which is set in the configuration.

            Args:
                model (Model): The model to print.
            """
            log.debug(
                "\n".join([str(s).replace("__", "&") for s in model.symbols(atoms=True, shown=True, theory=True)])
            )
            if self.meta_system.print_model is not None:
                self.meta_system.print_model(model)
            else:
                super().print_model(model, printer)

        def main(self, control, files):
            """
            Main entry point for the application.
            """
            log_level_num = logging.getLevelNamesMapping().get(self._log_level.upper(), logging.WARNING)
            configure_logging(sys.stdout, log_level_num, use_color=True)
            log = logging.getLogger("metasp")

            metasp_system_final_config = {}
            if self.metasp_config_file is not None:
                metasp_system_final_config = load_config(self.metasp_config_file)
                log.debug("Loaded config from file: %s %s", self.metasp_config_file, metasp_system_final_config)
            # Update self.metasp_config with values from metasp_system_final_config

            metasp_system_final_config.update(self.metasp_config)

            self.metasp_config = metasp_system_final_config

            if "control_name" in self.metasp_config and self.metasp_config["control_name"] != app_name:
                msg = f"Control name '{self.metasp_config['control_name']}' in configuration does not match the used control name '{app_name}'"
                log.error(msg)
                raise ValueError(msg)
            log.info(f"=== Running meta system: ===")
            log.info(f"Config: {json.dumps(self.metasp_config, indent=12)}")
            log.info(f"Input files: {files}")

            self.meta_system = MetaSystem.from_dict(self.metasp_config)

            grammar = Grammar.from_asp_files(self.meta_system.syntax_encoding)
            self.meta_system.set_constants(self.constants)
            # processed_input = preprocess(files, self.constants, grammar)
            processor = MetaspProcessor(grammar)
            transformed_input = processor.fo_transform(files, "")
            reified = processor.reify_and_extend(transformed_input, self.constants)
            final_files = self.meta_system.get_files(reified)

            super().main(control, final_files)

    return MetaspApp
