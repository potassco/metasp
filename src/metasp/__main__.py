"""
The main entry point for the application.
"""

import sys
from typing import Optional
import os
import yaml
import argparse
from clingo.application import clingo_main
from .app import MetaspApp
from .utils.parser import get_parser
from rich_argparse import ArgumentDefaultsRichHelpFormatter
from metasp.preprocess import preprocess, reify
from metasp.system import MetaSystem
from metasp.utils.logging import configure_logging
import subprocess


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
    config = get_configuration()
    constants_dict = parse_constants(sys.argv[2:])
    if config is not None:
        meta_systems_configs = {system["name"]: system for system in config.get("metasp-systems", [])}
        if len(sys.argv) > 2 and sys.argv[1] in list(meta_systems_configs.keys()) and sys.argv[2] == "solve":
            system = sys.argv[1]
            exit_status = clingo_main(
                MetaspApp(config=meta_systems_configs[system], constants=constants_dict), sys.argv[3:]
            )
            sys.exit(exit_status)

    if config is None:
        print(
            "\033[93mConfiguration file 'metasp.yml' not found in current directory. Make sure this file exists and defines at least one system to use metasp.\033[0m"
        )
        # parser.parse_args({})
        exit(1)
    parser = get_parser(config)

    args = parser.parse_args()
    configure_logging(sys.stderr, args.log, sys.stderr.isatty())
    system_config = meta_systems_configs[args.system]
    meta_system = MetaSystem.from_dict(system_config)
    meta_system.set_constants(constants_dict)
    processed_input = preprocess(args.files, constants_dict, meta_system.syntax_encoding)
    if args.output == "extend":
        sys.stdout.write(processed_input + "\n")
        exit(0)
    reified_input = reify(processed_input, constants_dict)
    if args.output == "reify":
        sys.stdout.write(reified_input + "\n")
        exit(0)
    if args.output == "ui":
        print("Running in user interface mode. Use Ctrl+C to exit.")
        command = meta_system.clinguin_command(reified_input)
        print(f"Running command: {' '.join(command)}")
        result = subprocess.run(command, shell=False)
        if result.returncode != 0:
            print(f"Command failed with exit code {result.returncode}")
        exit(0)


if __name__ == "__main__":
    main()
