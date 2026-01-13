#script (python)
from clingo.symbol import String, Number
def tel_label(formula):
    args = formula.arguments
    name = formula.name
    if name == "__true":
        return "⊤"#For some reason the other top is printing a strange character on the pdf format
    if name == "__false":
        return "⊥"
    if name == "__initial":
        return "I"
    if name == "__final":
        return "F"
    if name == "__next":
        return "○"+tel_label(args[0])
    if name == "__eventually":
        return "◇"+tel_label(args[0])
    if name == "__always":
        return "□"+tel_label(args[0])
    if name == "__until":
        return "("+tel_label(args[0])+" U "+tel_label(args[1])+")"
    if name == "__release":
        return "("+tel_label(args[0])+" R "+tel_label(args[1])+")"
    if name == "__and":
        return "("+tel_label(args[0])+" ∧ "+tel_label(args[1])+")"
    if name == "__or":
        return "("+tel_label(args[0])+" ∨ "+tel_label(args[1])+")"
    if name == "__neg":
        return "¬"+tel_label(args[0])
    else:
        return str(formula)

def get_tel_label(formula):
    return String(str(tel_label(formula)))

#end.

label(F,@get_tel_label(F)):-formula(tel,F).
