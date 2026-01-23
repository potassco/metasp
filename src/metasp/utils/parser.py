"""
The command line parser for the project.
"""

from argparse import ArgumentParser
from importlib import metadata
from textwrap import dedent
from typing import Any, Optional, cast
from pathlib import Path

import yaml
from rich_argparse import ArgumentDefaultsRichHelpFormatter
from rich.text import Text

from . import logging

__all__ = ["get_parser"]

VERSION = metadata.version("metasp")

ascii_art_metasp = Text(
    r"""
                     _
  _ __ ___     ___  | |_    __ _   ___   _ __
 | '_ ` _ \   / _ \ | __|  / _` | / __| | '_ \
 | | | | | | |  __/ | |_  | (_| | \__ \ | |_) |
 |_| |_| |_|  \___|  \__|  \__,_| |___/ | .__/
                                        |_|
    """,
    no_wrap=True,
    justify="left",
)

levels = [
    ("error", logging.ERROR),
    ("warning", logging.WARNING),
    ("info", logging.INFO),
    ("debug", logging.DEBUG),
]


def get(levels: list[tuple[str, int]], name: str) -> Optional[int]:
    for key, val in levels:
        if key == name:
            return val
    return None  # nocoverage


def load_config(path):
    with open(path) as f:
        config = yaml.safe_load(f) or {}
    return {k.replace("-", "_"): v for k, v in config.items()}


def get_parser() -> ArgumentParser:
    """
    Return the parser for command line options.
    """
    parser = ArgumentParser(
        prog="metasp",
        description=ascii_art_metasp + "\n🚀 Framework for metaprogramming in ASP.",
        formatter_class=ArgumentDefaultsRichHelpFormatter,
    )
    parser.add_argument("--version", "-v", action="version", version=f"%(prog)s {VERSION}")

    # subparsers = parser.add_subparsers(
    # dest="operation",
    # required=True,
    # help="Available systems defined in configuration file metasp.yml. Each system is a separate subcommand using clingo's Application class.",
    # )
    # for systems_config in config.get("metasp-systems", []):
    # system_parser = subparsers.add_parser(
    # systems_config["name"],
    # help=systems_config.get("description", ""),
    # formatter_class=ArgumentDefaultsRichHelpFormatter,
    # )
    system_parser_output = parser.add_subparsers(
        dest="output",
        required=True,
        help="Available output options for the meta system.",
    )
    output_options = {
        "solve": "Solve the processed and reified input files with the meta encoding for the semantics.",
        "transform": "Output the transformed first order program and run syntactic checks.",
        "reify": "Output the reification with extensions.",
        "ui": "User interface mode.",
    }
    for option, description in output_options.items():
        output_parser = system_parser_output.add_parser(
            option,
            help=description,
            formatter_class=ArgumentDefaultsRichHelpFormatter,
        )
        output_parser.add_argument(
            "files",
            nargs="*",
            help="Input file paths.",
        )
        output_parser.add_argument(
            "-c",
            "--const",
            action="append",
            help="Replace term occurrences of <id> with <term> (must have form <id>=<term>)",
            type=lambda s: s if "=" in s else parser.error("Constants must have form <id>=<term>"),
        )
        output_parser.add_argument(
            "--log",
            default="warning",
            choices=[val for _, val in levels],
            metavar=f"{{{','.join(key for key, _ in levels)}}}",
            help="Set log level",
            type=cast(Any, lambda name: get(levels, name)),
        )
        output_parser.add_argument(
            "--syntax-encoding",
            nargs="*",
            type=str,
            default=None,
            help="Syntax encoding defining the extended grammar. ",
            metavar="<file>",
        )
        output_parser.add_argument(
            "--meta-config",
            type=str,
            help="Optional path to metasp yaml configuration file, setting the arguments for the system (Use to avoid long command lines).",
        )

    return parser
