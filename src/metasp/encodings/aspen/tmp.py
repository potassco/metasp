from clingo.symbol import String, Number, Symbol
from os.path import join


def replace_metasp_prefix(string: Symbol, metasp_enc_path: Symbol) -> Symbol:
    s = string.string
    if s.startswith("metasp."):
        return String(join(metasp_enc_path.string + s.removeprefix("metasp.")))
    return Number(0)
