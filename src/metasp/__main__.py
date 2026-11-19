"""
The main entry point for the application.
"""

import argparse
import logging
import subprocess
import sys

import yaml
from clingo.application import clingo_main

from metasp import MetaspProcessor
from metasp.app import make_app
from metasp.grammar import Grammar
from metasp.system import MetaSystem
from metasp.utils.logging_utils import configure_logging
from metasp.utils.parser import get_parser, load_config, parse_constants
from metasp.utils.test import run_tests
from metasp.utils.visualization import replace_internal_prefix, visualize_reified_program

log = logging.getLogger(__name__)


# pylint: disable=too-many-branches
# pylint: disable=too-many-statements
def run(argv: list[str]) -> int:
    """Core CLI logic"""

    constants_dict = parse_constants(argv[1:])
    if len(argv) == 0 or argv[0] in ["-h", "--help"]:
        parser = get_parser()
        parser.print_help()
        return 1

    selected_command = argv[0]
    if selected_command == "solve":
        system_name = argv[1]
        App_class = make_app(system_name)
        exit_status = clingo_main(App_class(constants=constants_dict), argv[2:])
        return exit_status

    if selected_command == "test":
        if "-h" in argv or "--help" in argv:
            print(
                "Run the test cases defined in the test file."
                "If no specific tests file is provided, all test files .test.lp in current directory will be ran."
            )
            print("Usage: metasp test [test_files]")
            return 1
        exit_status = run_tests(argv[1:])
        return exit_status

    parser = get_parser()
    args, _ = parser.parse_known_args(argv)

    defaults = {}
    if args.meta_config:
        defaults = load_config(args.meta_config)

    # inject defaults
    # Set defaults for each subparser instead of the main parser
    # pylint: disable=protected-access
    if parser._subparsers is not None:
        for action in parser._subparsers._group_actions:
            if isinstance(action, argparse._SubParsersAction):
                for subparser in action.choices.values():
                    subparser.set_defaults(**defaults)

    args = parser.parse_args(argv)

    # pprint(vars(args))
    configure_logging(sys.stderr, args.log, sys.stderr.isatty())

    args_dict = vars(args)
    log.debug("Arguments:\n%s", yaml.dump(args_dict))
    # system_config = meta_systems_configs[args.system]
    meta_system = MetaSystem.from_dict(args_dict)
    meta_system.set_constants(constants_dict)
    transformed_input = meta_system.fo_transform(args.files, "")
    try:
        grammar = Grammar.from_asp_files(meta_system.syntax_encoding)
    except Exception as e:  # nocoverage
        log.error("Error loading grammar from syntax encoding files: %s", e)
        # TODO maybe more specific error message for syntax errors
        log.error(
            "Make sure the path to the syntax encoding files is correct"
            "(if using a config file, it should be relative where metasp is run)."
        )
        raise e
    processor = MetaspProcessor(grammar)
    if len(args.files) == 0:  # nocoverage
        log.warning("No input files provided.")
    if args.output == "transform":
        sys.stdout.write(replace_internal_prefix(transformed_input) + "\n")
        return 0
    reified = processor.reify_and_extend(transformed_input, constants_dict)
    if args.output == "reify":
        sys.stdout.write(replace_internal_prefix(reified) + "\n")
        if args.viz_reify:
            visualize_reified_program(reified)
        return 0
    if args.output == "ui":  # nocoverage
        print("Running in user interface mode. Use Ctrl+C to exit.")
        command = meta_system.clinguin_command(reified)
        print(f"Running command: {' '.join(command)}")
        result = subprocess.run(command, shell=False, check=False)
        if result.returncode != 0:
            print(f"Command failed with exit code {result.returncode}")
        return 0

    return 0


def main() -> None:  # nocoverage
    """
    Run the main function.
    """
    sys.exit(run(sys.argv[1:]))


if __name__ == "__main__":  # nocoverage
    main()
