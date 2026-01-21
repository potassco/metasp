#script (python)
from clingo.symbol import String, Number
def del_label(formula):
    args = formula.arguments
    name = formula.name
    if name == "__true":
        return "⊤"#For some reason the other top is printing a strange character on the pdf format
    if name == "__false":
        return "⊥"
    if name == "__eventually":
        return "⟨"+del_label(args[0])+"⟩"+del_label(args[1])
    if name == "__always":
        return "["+del_label(args[0])+"]"+del_label(args[1])
    if name == "__seq":
        return "("+del_label(args[0])+";"+del_label(args[1])+")"
    if name == "__choice":
        return "("+del_label(args[0])+"+"+del_label(args[1])+")"
    if name == "__star":
        return del_label(args[0])+"*"
    if name == "__test":
        return del_label(args[0])+"?"
    if name == "__neg":
        return "~"+del_label(args[0])
    if name == "__neg":
        return "~"+del_label(args[0])
    if name == "__step":
        return "𝝉"
    else:
        return str(formula)

def get_del_label(formula):
    return String(str(del_label(formula)))

#end.

% del_label(F,@get_label(F)):-formula(T,F).
label(F,@get_del_label(F)):-formula(del,F).
