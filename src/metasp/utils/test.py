import logging
import os
import sys
import textwrap
from enum import Enum, auto
from typing import Optional, Union
from metasp.utils.logging_utils import color
from metasp.app import make_app
from clingo.application import clingo_main
from metasp.utils.parser import get_parser, load_config, parse_constants
from metasp.app import APPS_BY_NAME

log = logging.getLogger(__name__)

FORMAT = """
Expected format is the following set of line comments, starting by #TEST,
followed by a line with the command, and the list of expected models, each starting with "% -":

% #TEST
%  clingo --meta-config config.yml --const n=1
% - a b c
% - a b
"""


class TestStatus(Enum):
    PENDING = auto()
    FAIL = auto()
    PASS = auto()


class StatusInfo:
    def __init__(self, status: TestStatus, message: Optional[str] = None):
        self.status = status
        self.message = message

    def __repr__(self):
        if self.status == TestStatus.FAIL and self.message:
            return f"{self.status.name}({self.message})"
        return self.status.name


def find_test_files(current_path: Optional[str] = None) -> list[str]:
    """
    Find all test files in the current directory and its subdirectories.
    Test files are identified by the .test.lp extension.

    Args:
        current_path (Optional[str]): The path to start searching for test files. Defaults to the current working directory.

    Returns:
        list: A list of file paths to the test files.
    """
    import os

    if current_path is None:
        current_path = os.getcwd()
    test_files = []
    for root, _, files in os.walk(current_path):
        for file in files:
            if file.endswith(".test.lp"):
                test_files.append(os.path.join(root, file))
    return test_files


class TestMetasp:

    def __init__(self, file: str, system: str, command_line_args: str, expected_models: list[list[str]]) -> None:
        self.file = file
        self.system = system
        self.command_line_args = command_line_args
        self.expected_models = expected_models
        self.status = StatusInfo(TestStatus.PENDING)

    @property
    def root_dir(self) -> str:
        return os.path.dirname(self.file)

    @property
    def name(self) -> str:
        return os.path.basename(self.file)

    @property
    def passed(self) -> bool:
        return self.status.status == TestStatus.PASS

    @classmethod
    def from_command_line_args(cls, args: list[str], current_path: Optional[str] = None) -> list["TestMetasp"]:
        test_files = [arg for arg in args if arg.endswith(".test.lp")]
        if len(test_files) == 0:
            log.info(
                "No test file provided in the command line arguments. Will search for test files in the current directory and its subdirectories."
            )
            test_files = find_test_files(current_path)
            if not test_files:
                log.error("No test files found in the current directory and its subdirectories.")
                raise ValueError("No test files found in the current directory and its subdirectories.")

        return [cls.from_test_file(file) for file in test_files]

    @classmethod
    def from_test_file(cls, file_path: str) -> "TestMetasp":
        args = ""
        expected_models = []
        reading_test = False
        reading_command = False
        system = None
        with open(file_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("% #TEST"):
                    reading_test = True
                    reading_command = True
                    reading_test = True
                    continue
                if reading_test and not line.startswith("%"):
                    log.error("Invalid test format in file %s", file_path)
                    log.error(FORMAT)
                    raise ValueError(
                        f"After the test all lines should be comments starting with '%'. Unexpected line: {line}"
                    )
                line = line.lstrip("%").strip()  # Remove leading '%' and any leading/trailing whitespace
                if reading_command:
                    system = line.split()[0]
                    args = line.split()[1:]
                    if line.startswith("-"):
                        log.error("Invalid test format in file %s", file_path)
                        log.error(FORMAT)
                        raise ValueError(
                            "Unexpected line format in test file: command line arguments should be in a single line after '% #TEST'."
                        )
                    if system not in APPS_BY_NAME.keys():
                        log.error("Invalid test format in file %s", file_path)
                        log.error(FORMAT)
                        raise ValueError(f"Unknown system '{system}' in test file {file_path}.")
                    reading_command = False
                    continue
                if reading_test and line.startswith("-"):
                    expected_model = line.split("-")[1].strip()  # Extract expected model after "-"
                    expected_models.append([s.replace("&", "__") for s in expected_model.split()])
                if reading_test and not line.startswith("-"):
                    log.error("Invalid test format in file %s", file_path)
                    log.error(FORMAT)
                    raise ValueError(f"Unexpected format in test file: {line}")
        if not reading_test:
            log.error(f"No test comments found in the test file. {file_path}")
            log.error(FORMAT)
            raise ValueError("No test case found in the test file.")
        log.info(f"Parsed test case from file {file_path}: args={args}, expected_models={expected_models}")
        return cls(file=file_path, system=system, command_line_args=args, expected_models=expected_models)

    def print_fail(self, s: str) -> None:
        sys.stdout.write(s + "\n")

    def run(self, obtained_models: list[list[str]]) -> None:
        """
        Assert that the obtained models match the expected models.

        Args:
            obtained_models (list[list[str]]): The list of obtained models, where each model is a list of strings.
        """
        self.obtained_models = obtained_models
        log.info(f"Obtained models: {obtained_models}")
        log.info(f"Expected models: {self.expected_models}")
        if len(obtained_models) != len(self.expected_models):
            self.status = StatusInfo(
                TestStatus.FAIL,
                f"Number of obtained models ({len(obtained_models)}) does not match expected ({len(self.expected_models)}).",
            )
            return

        remaining_models = obtained_models.copy()

        for expected_model in self.expected_models:
            found_match = False
            for obtained_model in remaining_models:
                if set(expected_model) == set(obtained_model):
                    found_match = True
                    remaining_models.remove(obtained_model)
                    break
            if not found_match:
                self.status = StatusInfo(
                    TestStatus.FAIL,
                    f"Expected model {expected_model} not found.",
                )
                return

        self.status = StatusInfo(TestStatus.PASS)

    def print_result(self) -> None:
        if self.status.status == TestStatus.PASS:
            print(color(f"✓ Test '{self.name}' passed.", "green"))
        elif self.status.status == TestStatus.PENDING:
            print(color(f"？ Test '{self.name}' status is pending. No result to print.", "yellow"))
        elif self.status.status == TestStatus.FAIL:
            expected_models = "\n\t\t" + "\n\t\t".join([f"    - {' '.join(model)}" for model in self.expected_models])
            obtained_models = "\n\t\t" + "\n\t\t".join([f"    - {' '.join(model)}" for model in self.obtained_models])
            error_message = f"""
✗ Test {self.name} failed.\n
    Reason:          {self.status.message}
    Arguments:       {self.command_line_args}
    Expected models: {expected_models}
    Obtained models: {obtained_models}
            """
            print(color(textwrap.dedent(error_message), "red"))


def run_tests(command_line: list[str], current_path: str = None) -> None:
    tests = TestMetasp.from_command_line_args(command_line, current_path=current_path)
    for test in tests:
        sep = "=" * 40
        print(color(f"\n{sep}\nRunning test '{test.name}'\n{sep}", "normal"))
        App_class = make_app(test.system)
        models = []

        def save_model(model):
            models.append([str(s) for s in model.symbols(shown=True, theory=True)])

        args = test.command_line_args + [test.file, "0"]
        constants_dict = parse_constants(args)
        clingo_main(
            App_class(constants=constants_dict, on_model=save_model, root_dir=test.root_dir),
            arguments=args,
        )
        test.run(models)
        test.print_result()
    summary = ""
    for test in tests:
        if test.status.status == TestStatus.FAIL:
            summary += color(f"✗", "red")
        if test.status.status == TestStatus.PASS:
            summary += color(f"✓", "green")
        if test.status.status == TestStatus.PENDING:
            summary += color(f"？", "yellow")
    fail = any(not test.passed for test in tests)
    print(color(f"\n-----------------------\nTEST Results: {summary}", "green" if not fail else "red"))
    return fail
