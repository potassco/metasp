% In #include statements, replace "metasp." prefix with metasp encoding path.

#const metasp_enc_path = "".

#script (python)
from clingo.symbol import String, Number, Symbol
from os.path import join


def replace_metasp_prefix(string: Symbol, metasp_enc_path: Symbol) -> Symbol:
    s = string.string
    if s.startswith("metasp."):
        return String(join(metasp_enc_path.string, s.removeprefix("metasp.")))
    return Number(0)
#end.

#program metasp_remove_ampersand.

aspen(edit(node(O), R)) :-
  type(N,"include"),
  child(N, M), type(M, "string"),
  child(M, O), type(O, "string_fragment"),
  child_index(O, 1),
  leaf_text(O,T),
  @replace_metasp_prefix(T, metasp_enc_path) = R,
  R != 0.
