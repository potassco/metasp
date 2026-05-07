"""
The main entry point for the application.
"""

import sys
from typing import Optional
import os
from networkx import config
import yaml
import argparse
from clingo.application import clingo_main
from metasp.utils.parser import get_parser, load_config, parse_constants
from metasp.system import MetaSystem
from metasp.utils.logging_utils import configure_logging
from metasp.app import make_app
from metasp.grammar import Grammar
from metasp import MetaspProcessor, replace_internal_prefix
from metasp.utils.test import TestMetasp, run_tests
import subprocess
from pprint import pprint

import logging

log = logging.getLogger(__name__)


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

    if selected_command == "test":  # nocoverage
        exit_status = run_tests(argv[1:])
        return exit_status

    parser = get_parser()
    args, remaining = parser.parse_known_args(argv)

    defaults = {}
    if args.meta_config:
        defaults = load_config(args.meta_config)

    # inject defaults
    # Set defaults for each subparser instead of the main parser
    for subparser in parser._subparsers._group_actions:
        for choice, sub in subparser.choices.items():
            sub.set_defaults(**defaults)

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
        log.error(f"Error loading grammar from syntax encoding files: {e}")
        # TODO maybe more specific error message for syntax errors
        log.error(
            "Make sure the path to the syntax encoding files is correct (if using a config file, it should be relative where metasp is run)."
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
        return 0
    if args.output == "ui":  # nocoverage
        print("Running in user interface mode. Use Ctrl+C to exit.")
        command = meta_system.clinguin_command(reified)
        print(f"Running command: {' '.join(command)}")
        result = subprocess.run(command, shell=False)
        if result.returncode != 0:
            print(f"Command failed with exit code {result.returncode}")
        return 0


def main() -> None:  # nocoverage
    """
    Run the main function.
    """
    sys.exit(run(sys.argv[1:]))


if __name__ == "__main__":  # nocoverage
    main()
