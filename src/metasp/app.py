import textwrap
from clingo.application import Application, ApplicationOptions, Flag, clingo_main
from .utils.logging import configure_logging
from .system import MetaSystem
import logging
import sys
from clingo import Model
import logging
import clingo

log = logging.getLogger(__name__)


class MetaspApp(Application):
    def __init__(self, config: dict, constants=None):
        """
        Create application
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
        """
        if log_level is not None:
            self._log_level = log_level.upper()
            return self._log_level in ["INFO", "WARNING", "DEBUG", "ERROR"]

        return True

    def register_options(self, options: ApplicationOptions) -> None:
        """
        Add custom options
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
        Print the model.

        Args:
            control (_type_): _description_
            model (_type_): _description_
        """
        log.debug("------- Full model -----")
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
        log.debug(f"Constants: {self.constants}")
        log.debug(f"Config: {self.config}")
        log.debug(f"Loading files: {files}")

        self.meta_system = MetaSystem.from_dict(self.config)
        self.meta_system.main(control, self.constants, files)
