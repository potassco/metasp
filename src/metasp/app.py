import sys
import logging
import textwrap
from clingo.application import Application, ApplicationOptions
from clingo import Model
from .utils.logging import configure_logging
from .system import MetaSystem

log = logging.getLogger(__name__)


class MetaspApp(Application):
    def __init__(self, config: dict, constants=None):
        """
        Create application

        Args:
            config (dict): The configuration dictionary.
            constants (Optional[dict], optional): The constants required by the system that will become attributes. Defaults to None.
        """
        self.config = config
        self.constants = constants or {}
        self._log_level = "warning"

    @property
    def name(self):
        return self.config.get("name", "metasp")

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

    def print_model(self, model: Model, _) -> None:
        """
        Print the model using the system's printing function which is set in the configuration.

        Args:
            model (Model): The model to print.
        """
        log.debug("\n".join([str(s) for s in model.symbols(atoms=True, shown=True, theory=True)]))
        self.meta_system.print_model(model)

    def main(self, control, files):
        """
        Main entry point for the application.
        """
        log_level_num = logging.getLevelNamesMapping().get(self._log_level.upper(), logging.WARNING)
        configure_logging(sys.stdout, log_level_num, use_color=True)
        log = logging.getLogger("metasp")

        log.info(f"=== Running meta system: '{self.name}' ===")
        log.debug(f"Config: {self.config}")
        log.debug(f"Constants: {self.constants}")
        log.debug(f"Input files: {files}")

        self.meta_system = MetaSystem.from_dict(self.config)
        self.meta_system.main(control, self.constants, files)
