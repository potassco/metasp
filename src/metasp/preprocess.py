from collections.abc import Sequence
from metasp.reifier import MetaReifier, FormulaRegistery
from typing import List
from clingo import Control, Symbol
from metasp.grammar import Grammar


def preprocess(input_files: Sequence[str], constants: dict[str, str], grammar: Grammar) -> str:
    """
    Preprocess the input files.

    Args:
        input_files (Sequence[str]): The input files to be preprocessed.
        constants (dict[str,str]): The constants to be used during preprocessing <id>:<term>.
        grammar (Grammar): The grammar defining the syntax and safety.
    Returns:
        str: The preprocessed input as a string. With externals and transformed show statements.
    Raises:
        ValueError: If grammar sanity check fails.
    """
    # Read the input files
    input_data = ""
    for file in input_files:
        with open(file, "r") as f:
            input_data += f.read()
    # TODO: Amade preprocessing would go here
    return input_data
