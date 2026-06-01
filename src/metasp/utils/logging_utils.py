"""
Setup project wide loggers.

This is a thin wrapper around Python's logging module. It supports colored
logging.
"""

import logging
from typing import TextIO
from clingo import Model, Symbol, SymbolType

NOTSET = logging.NOTSET
DEBUG = logging.DEBUG
INFO = logging.INFO
WARNING = logging.WARNING
ERROR = logging.ERROR
CRITICAL = logging.CRITICAL

COLORS = {
    "GREY": "\033[90m",
    "BLUE": "\033[94m",
    "GREEN": "\033[92m",
    "YELLOW": "\033[93m",
    "RED": "\033[91m",
    "NORMAL": "\033[0m",
}

log = logging.getLogger(__name__)


class SingleLevelFilter(logging.Filter):
    """
    Filter levels.
    """

    passlevel: int
    reject: bool

    def __init__(self, passlevel: int, reject: bool):
        # pylint: disable=super-init-not-called
        self.passlevel = passlevel
        self.reject = reject

    def filter(self, record: logging.LogRecord) -> bool:
        if self.reject:
            return record.levelno != self.passlevel  # nocoverage

        return record.levelno == self.passlevel


def color(s: str, color: str) -> str:
    """
    Color a string.

    Args:
        s (str): The string to color.
        color (str): The color to use. Must be one of the keys in the COLORS dictionary.
    Returns:
        str: The colored string.
    """
    return f"{COLORS[color.upper()]}{s}{COLORS['NORMAL']}"


def configure_logging(stream: TextIO, level: int, use_color: bool) -> None:
    """
    Configure application logging.
    """
    logging.getLogger("aspen").setLevel(logging.WARNING)

    def format_str(color: str) -> str:
        if use_color:
            return f"{COLORS[color]}%(levelname)-5s:{COLORS['GREY']}  - %(message)s{COLORS['NORMAL']}"
        return f"%(levelname)s:  - %(message)s {COLORS['NORMAL']}"  # nocoverage

    def make_handler(level: int, color: str) -> "logging.StreamHandler[TextIO]":
        handler = logging.StreamHandler(stream)
        handler.addFilter(SingleLevelFilter(level, False))
        handler.setLevel(level)
        formatter = logging.Formatter(format_str(color))
        handler.setFormatter(formatter)
        return handler

    handlers = [
        make_handler(logging.INFO, "GREEN"),
        make_handler(logging.WARNING, "YELLOW"),
        make_handler(logging.DEBUG, "BLUE"),
        make_handler(logging.ERROR, "RED"),
    ]
    logging.basicConfig(handlers=handlers, level=level)


def print_model_logs(model: Model) -> None:
    """
    Auxiliary function to print log messages from the model.
    It looks for symbols of the form _log(Level, Message) and prints the message with the corresponding log level.
    """
    for sym in model.symbols(atoms=True):
        if sym.match("_log", 2):
            level = str(sym.arguments[0]).strip('"').lower()
            if level not in ["debug", "info", "warning", "error", "critical"]:
                log.warning("Invalid log level: {}. Skipping log message.".format(level))
                continue
            getattr(log, level)(sym.arguments[1])


def colored_symbol_str(s: Symbol) -> str:
    """
    Auxiliary function to print a symbol with color if it is an internal symbol (those starting with &).
    Args:
        s (Symbol): The symbol to be printed.
    """
    if s.type == SymbolType.Function and s.name.startswith("__"):
        s_str = str(s)
        s_str = s_str.replace("__", "&")
        return f"{COLORS['YELLOW']}{s_str}{COLORS['NORMAL']}"
    return str(s)
