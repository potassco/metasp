from collections.abc import Sequence
from clingox.reify import Reifier
from typing import List
from clingo import Control, Symbol


def reify(prg: str, constants: Sequence[str]) -> str:
    """
    Reify the input data with the given constants.
    The input predicate is expected to have the required externals
    which can be achieved by calling preprocess first.

    Args:
        prg (str): The input data to be reified.
        constants (Sequence[str]): The constants to be used in the reification.
    Returns:
        str: The reified input data.
    """
    symbols: List[Symbol] = []

    ctl = Control(["--warn=none"] + [f"-c {c}" for c in constants])
    reifier = Reifier(symbols.append, reify_steps=False)
    ctl.register_observer(reifier)
    ctl.add("base", [], prg)
    ctl.ground([("base", [])])
    reified_input = "\n".join([str(s) + "." for s in symbols])
    title = "\n\n%%%%%% Reified Input %%%%%%\n\n"
    return title + reified_input


def preprocess(input_files: Sequence[str], constants: Sequence[str], syntax_encoding: Sequence[str]) -> str:
    """
    Preprocess the input files.

    Args:
        input_files (Sequence[str]): The input files to be preprocessed.
        syntax_encoding (Sequence[str]): The syntax encoding defining modalities and safety.
        constants (Sequence[str]): The constants to be used during preprocessing <id>=<term>.
    Returns:
        str: The preprocessed input as a string. With externals and transformed show statements.
    Raises:
        ValueError: If modality sanity check fails.
    """
    # Read the input files
    input_data = ""
    for file in input_files:
        with open(file, "r") as f:
            input_data += f.read()
    # TODO: Amade preprocessing would go here
    return input_data
