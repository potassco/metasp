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
from metasp.utils.parser import get_parser, load_config
from metasp.system import MetaSystem
from metasp.utils.logging_utils import configure_logging
from metasp.app import make_app
from metasp.grammar import Grammar
from metasp import MetaspProcessor, replace_internal_prefix
import subprocess
from pprint import pprint

import logging

log = logging.getLogger(__name__)


def parse_constants(arguments: list[str]) -> dict[str, str]:
    """
    Parse constants from the command line arguments.
    We need these constrants in both steps and since we can't fork the control object,
    we parse them here.

    Args:
        arguments (list): The command line arguments.
    Returns:
        list: A list of constants in the form <id>=<term>.
    """
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument(
        "-c",
        "--const",
        action="append",
        help="Replace term occurrences of <id> with <term> (must have form <id>=<term>)",
        type=lambda s: s if "=" in s else parser.error("Constants must have form <id>=<term>"),
    )
    args, _ = parser.parse_known_args(arguments)
    input_consts = {c.split("=")[0]: c.split("=")[1] for c in args.const} if args.const else {}
    return input_consts


def get_configuration() -> Optional[dict[str, object]]:
    """
    Load the configuration from the metasp.yml file.

    Returns:
        dict: The configuration dictionary loaded from the YAML file. If the file does not exist, returns None.
    """
    # Get the configuration file to know the available commands
    config_path = os.path.join(os.getcwd(), "metasp.yml")
    if not os.path.isfile(config_path):
        return None

    with open(config_path, "r") as config_file:
        try:
            config = yaml.safe_load(config_file)
            return config
        except yaml.YAMLError as e:
            raise e


def main() -> None:
    """
    Run the main function.
    """
    # config = get_configuration()
    constants_dict = parse_constants(sys.argv[2:])
    if len(sys.argv) < 2:
        print("---------- You need help")
        parser = get_parser()
        parser.print_help()
        # print("Usage: metasp <solve | reify | transform> [options] <files>")
        exit(1)

    selected_command = sys.argv[1]
    if selected_command == "solve":
        system_name = sys.argv[2]
        App_class = make_app(system_name)
        exit_status = clingo_main(App_class(constants=constants_dict), sys.argv[3:])
        sys.exit(exit_status)

    parser = get_parser()
    args, remaining = parser.parse_known_args()

    defaults = {}
    if args.meta_config:
        defaults = load_config(args.meta_config)

    # inject defaults
    # Set defaults for each subparser instead of the main parser
    for subparser in parser._subparsers._group_actions:
        for choice, sub in subparser.choices.items():
            sub.set_defaults(**defaults)

    args = parser.parse_args()

    # pprint(vars(args))
    configure_logging(sys.stderr, args.log, sys.stderr.isatty())

    args_dict = vars(args)
    log.debug("Arguments:\n%s", yaml.dump(args_dict))
    # system_config = meta_systems_configs[args.system]
    meta_system = MetaSystem.from_dict(args_dict)
    meta_system.set_constants(constants_dict)
    try:
        grammar = Grammar.from_asp_files(meta_system.syntax_encoding)
    except Exception as e:
        log.error(f"Error loading grammar from syntax encoding files: {e}")
        # TODO maybe more specific error message for syntax errors
        log.error(
            "Make sure the path to the syntax encoding files is correct (if using a config file, it should be relative where metasp is run)."
        )
        raise e
    processor = MetaspProcessor(grammar)
    if len(args.files) == 0:
        log.warning("No input files provided.")
    transformed_input = processor.fo_transform(args.files, "")
    if args.output == "transform":
        sys.stdout.write(replace_internal_prefix(transformed_input) + "\n")
        exit(0)
    reified = processor.reify_and_extend(transformed_input, constants_dict)
    if args.output == "reify":
        sys.stdout.write(replace_internal_prefix(reified) + "\n")
        exit(0)
    if args.output == "ui":
        print("Running in user interface mode. Use Ctrl+C to exit.")
        command = meta_system.clinguin_command(reified)
        print(f"Running command: {' '.join(command)}")
        result = subprocess.run(command, shell=False)
        if result.returncode != 0:
            print(f"Command failed with exit code {result.returncode}")
        exit(0)


if __name__ == "__main__":
    main()
