import sys
import logging
import textwrap
from clingo.application import Application, ApplicationOptions
from clingo import Model
from .utils.logging import configure_logging
from .system import MetaSystem
from metasp.preprocess import preprocess, reify

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
        # self._step_type = "solve"

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

    # def parse_step(self, step_type):
    #     """
    #     Parse step type

    #     Args:
    #         step_type (str): The type of step to generate.
    #     Returns:
    #         bool: True if the step type is valid, False otherwise.
    #     """
    #     if step_type is not None:
    #         self._step_type = step_type.lower()
    #         return self._step_type in ["extend", "reify", "solve", "ui"]

    #     return True

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
                                            (default: warning)"""
            ),
            self.parse_log_level,
            argument="<level>",
        )
        # options.add(
        #     group,
        #     "step",
        #     textwrap.dedent(
        #         """\
        #         Provide the type of step to generate.
        #             <type>:{extend|reify|solve|ui}(default: solve)
        #                 extend : Output the extended input and run syntactic checks.
        #                 reify  : Output the reified input.
        #                 solve  : Solve the processed and reified input files with the meta encoding for the semantics.
        #                 ui     : User interface mode.

        #             \033[0m"""
        #     ),
        #     self.parse_step,
        # )

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

        self.meta_system.set_constants(self.constants)
        processed_input = preprocess(files, self.constants, self.meta_system.syntax_encoding)
        reified_input = reify(processed_input, self.constants)
        self.meta_system.set_control(control)
        self.meta_system.meta_compute(reified_input)
