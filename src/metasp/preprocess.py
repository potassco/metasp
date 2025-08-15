from collections.abc import Sequence


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
