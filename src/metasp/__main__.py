"""
The main entry point for the application.
"""

import sys

from .utils.logging import configure_logging, get_logger
from .app import MetaspApp
from .utils.parser import get_parser
import os
import yaml
import argparse
from clingo.application import clingo_main


def parse_constants(arguments):
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
    return args.const if args.const else []


def get_configuration() -> dict:
    """
    Load the configuration from the metasp.yml file.
    Returns:
        dict: The configuration dictionary loaded from the YAML file.
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
    config = get_configuration()
    if config is not None:
        systems = {system["name"]: system for system in config.get("metasp-systems", [])}
        if len(sys.argv) > 1 and sys.argv[1] in list(systems.keys()):
            system = sys.argv[1]
            constants = parse_constants(sys.argv[2:])
            exit_status = clingo_main(MetaspApp(config=systems[system], constants=constants), sys.argv[2:])
            sys.exit(exit_status)

    parser = get_parser()
    subparsers = parser.add_subparsers(
        dest="system",
        required=True,
        help="Available systems defined in configuration file metasp.yml. Each system is a separate subcommand using clingo's Application class.",
    )
    if config is None:
        print(
            "\033[93mConfiguration file 'metasp.yml' not found in current directory. Make sure this file exists and defines at least one system to use metasp.\033[0m"
        )
    else:
        for system in config.get("metasp-systems", []):
            system_parser = subparsers.add_parser(system["name"], help=system.get("description", ""))
            system_parser.set_defaults(**system.get("defaults", {}))

    parser.parse_args()


if __name__ == "__main__":
    main()
