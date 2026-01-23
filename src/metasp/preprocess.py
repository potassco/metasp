from collections.abc import Sequence
from typing import List
from clingo import Control, Symbol
from metasp.grammar import Grammar


def preprocess(input_files: Sequence[str], program_string: str, grammar: Grammar) -> str:
    """
    Preprocess the input files.

    Args:
        input_files (Sequence[str]): The input files to be preprocessed.
        program_string (str): The program string to be preprocessed.
        grammar (Grammar): The grammar defining the syntax and safety.
    Returns:
        str: The preprocessed input as a string. With externals and transformed show statements.
    Raises:
        ValueError: If grammar sanity check fails.
    """
    # Read the input files
    input_data = program_string
    for file in input_files:
        with open(file, "r") as f:
            input_data += f.read()
    # TODO: Amade preprocessing would go here
    return input_data
