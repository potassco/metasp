"""
The command line parser for the project.
"""

from argparse import ArgumentParser
from importlib import metadata
from textwrap import dedent
from typing import Any, Optional, cast
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
    return parser
