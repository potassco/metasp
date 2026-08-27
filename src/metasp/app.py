import json
import logging
import sys
import textwrap
from collections.abc import Callable
from time import perf_counter
from typing import Optional

from clingo import Model
from clingo.application import Application, ApplicationOptions
from clingo.statistics import StatisticsMap
from clingo.script import enable_python


from metasp import MetaspProcessor
from metasp.grammar import Grammar
from metasp.utils.parser import load_config

from .system import MetaSystem
from .utils.logging_utils import configure_logging, print_model_logs

log = logging.getLogger(__name__)

# ======== Setting up possible applications ========

try:
    from clingcon.__main__ import ClingconApp
except ImportError:
    ClingconApp = None

try:
    from flingo.__main__ import FlingoApp

    class MyFlingoApp(FlingoApp):
        def __init__(self, name):
            super().__init__()
            self.program_name = name

except ImportError:
    MyFlingoApp = None


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
        ctl.solve(on_statistics=self.__on_statistics)

    def __on_statistics(self, step: StatisticsMap, accu: StatisticsMap):
        """
        Handle statistics from the solver.

        Args:
            step (StatisticsMap): The current step statistics.
            accu (StatisticsMap): The accumulated statistics.
        """
        pass


APPS_BY_NAME = {
    "clingo": ClingoApp,
    "clingcon": ClingconApp,
    "flingo": MyFlingoApp,
}


def get_statistics_hook(
    app_class: type[object],
) -> tuple[Optional[str], Optional[Callable[[object, StatisticsMap, StatisticsMap], None]]]:
    """
    Get the private name and method for the __on_statistics hook in the given application class.
    This follows the patter of Clingcon and Flingo, which have a private method for handling statistics
    which is called in the solve call.

    Args:
        app_class (type[object]): The application class to inspect.

    Returns:
        tuple[Optional[str], Optional[Callable[[object, StatisticsMap, StatisticsMap], None]]]:
            A tuple containing the mangled name of the hook and the hook itself, or (None, None) if not found.
    """
    for candidate in app_class.__mro__:
        mangled_name = f"_{candidate.__name__}__on_statistics"
        hook = candidate.__dict__.get(mangled_name)
        if hook is not None:
            return mangled_name, hook
    return None, None


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
    if APPS_BY_NAME[app_name] is None:
        msg = f"Install the corresponding package via pip for '{app_name}' to use it."
        log.error(msg)
        raise ImportError(msg)
    return APPS_BY_NAME.get(app_name, None)


def make_app(app_name: str) -> Application:

    base_class = get_app_by_name(app_name)

    class MetaspApp(base_class):
        def __init__(self, constants=None, on_model=None, root_dir=None):
            """
            Create application

            Args:
                config (dict): The configuration dictionary.
                constants (Optional[dict], optional): The constants required by the system that will become attributes. Defaults to None.
                on_model (Optional[callable], optional): A callback function to handle models. Defaults to None.
            """
            super().__init__(f"Metasp ({base_class})")
            self.constants = constants or {}
            self.root_dir = root_dir or "."
            self.metasp_config = {}
            self.metasp_on_model = on_model
            self.metasp_config_file = None
            self._log_level = "warning"
            self.times = {}
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
            print_model_logs(model)
            if self.metasp_on_model is not None:
                self.metasp_on_model(model)
            log.debug(
                "\n".join([str(s).replace("__", "&") for s in model.symbols(atoms=True, shown=True, theory=True)])
            )
            if self.meta_system.print_model is not None:
                self.meta_system.print_model(model)
            else:
                super().print_model(model, printer)

        def _metasp_on_statistics(self, step: StatisticsMap, accu: StatisticsMap):
            accu.update(
                {
                    "Metasp": {
                        "Times in seconds": self.times,
                    }
                }
            )

        def main(self, control, files):
            """
            Main entry point for the application.
            """
            log_level_num = logging.getLevelNamesMapping().get(self._log_level.upper(), logging.WARNING)
            configure_logging(sys.stdout, log_level_num, use_color=True)
            log = logging.getLogger("metasp")

            metasp_system_final_config = {}
            if self.metasp_config_file is not None:
                metasp_system_final_config = load_config(self.metasp_config_file, root_dir=self.root_dir)
                log.debug("Loaded config from file: %s %s", self.metasp_config_file, metasp_system_final_config)

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

            self.meta_system.set_constants(self.constants)

            start_time = perf_counter()
            transformed_input = self.meta_system.fo_transform(files, "")
            self.times["FO-Transform"] = round(perf_counter() - start_time, 3)

            start_time = perf_counter()
            grammar = Grammar.from_asp_files(self.meta_system.syntax_encoding)
            self.times["Load-Grammar"] = round(perf_counter() - start_time, 3)

            processor = MetaspProcessor(grammar)

            start_time = perf_counter()
            reified = processor.reify_and_extend(transformed_input, self.constants)
            self.times["Reify-and-Extend"] = round(perf_counter() - start_time, 3)

            final_files = self.meta_system.get_files(reified)

            super().main(control, final_files)

    # Overwrite statistics to include Metasp Statistics
    parent_private_name, parent_on_statistics = get_statistics_hook(base_class)

    if parent_on_statistics is None:
        print("Parent class does not have __on_statistics method")

    def _override_on_statistics(self, step: StatisticsMap, accu: StatisticsMap):
        if parent_on_statistics is not None:
            parent_on_statistics(self, step, accu)
        self._metasp_on_statistics(step, accu)

    if parent_private_name is not None:
        setattr(MetaspApp, parent_private_name, _override_on_statistics)

    return MetaspApp
