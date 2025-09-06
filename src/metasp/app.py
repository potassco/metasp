import sys
import logging
import textwrap
from typing import Optional

from clingo import Model
from clingo.application import Application, ApplicationOptions
from clingcon.__main__ import ClingconApp
from fclingo.__main__ import FclingoApp

from .utils.logging import configure_logging
from .system import MetaSystem
from metasp.preprocess import preprocess, reify
from clingo.script import enable_python

log = logging.getLogger(__name__)


class ClingoApp(Application):
    def __init__(self, name):
        self.program_name = name

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
        log.error("Application '%s' not found. Available applications: %s", app_name, list(APPS_BY_NAME.keys()))
        raise ValueError(f"Application '{app_name}' not found.")
    return APPS_BY_NAME.get(app_name, None)


def make_app(app_name: str) -> Application:

    base_class = get_app_by_name(app_name)

    class MetaspApp(base_class):
        def __init__(self, config: dict, constants=None):
            """
            Create application

            Args:
                config (dict): The configuration dictionary.
                constants (Optional[dict], optional): The constants required by the system that will become attributes. Defaults to None.
            """
            super().__init__(f"Metasp ({base_class})")
            self.metasp_config = config
            self.constants = constants or {}
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
                textwrap.dedent(
                    """\
                    Provide logging level.
                                                <level> ={debug|info|error|warning}
                                                (default: warning)\033[0m"""
                ),
                self.parse_log_level,
                argument="<level>",
            )
            super().register_options(options)

        def print_model(self, model: Model, printer) -> None:
            """
            Print the model using the system's printing function which is set in the configuration.

            Args:
                model (Model): The model to print.
            """
            if self.meta_system.print_model is not None:
                self.meta_system.print_model(model)
            else:
                super().print_model(model, printer)
            log.debug("\n".join([str(s) for s in model.symbols(atoms=True, shown=True, theory=True)]))

        def main(self, control, files):
            """
            Main entry point for the application.
            """
            log_level_num = logging.getLevelNamesMapping().get(self._log_level.upper(), logging.WARNING)
            configure_logging(sys.stdout, log_level_num, use_color=True)
            log = logging.getLogger("metasp")

            log.info(f"=== Running meta system: '{self.name}' ===")
            log.debug(f"Config: {self.metasp_config}")
            log.debug(f"Constants: {self.constants}")
            log.debug(f"Input files: {files}")

            self.meta_system = MetaSystem.from_dict(self.metasp_config)

            self.meta_system.set_constants(self.constants)
            processed_input = preprocess(files, self.constants, self.meta_system.syntax_encoding)
            reified_input = reify(processed_input, self.constants)
            final_files = self.meta_system.get_files(reified_input)
            super().main(control, final_files)
            # self.meta_system.set_control(control)
            # self.meta_system.meta_compute(reified_input)

    return MetaspApp
