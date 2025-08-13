% #TODO
#script (python)

from clingo import Symbol, String, SymbolType, Function, Number

def name(O):
    return Function(O.name,[])

def args(O):
    if O.type == SymbolType.Function:
        args = [a for a in O.arguments]
        return Function("",args)
    else:
        return None

def arity(O):
    if O.type == SymbolType.Function:
        return Number(len(O.arguments))
    else:
        return None
#end.



possible_formula(F,@name(F),@args(F),@arity(F)):-output(F,B).
arg_formula(F,1,F1) :- possible_formula(F, N, (F1,), 1).
arg_formula(F,1,F1) :- possible_formula(F, N, (F1,F2), 2).
arg_formula(F,2,F2) :- possible_formula(F, N, (F1,F2), 2).
arg_formula(F,1,F1) :- possible_formula(F, N, (F1,F2,F3), 3).
arg_formula(F,2,F2) :- possible_formula(F, N, (F1,F2,F3), 3).
arg_formula(F,3,F3) :- possible_formula(F, N, (F1,F2,F3), 3).
% TODO find a better way to do this


formula(M, F):- possible_formula(F, N, ARGS, ARITY), modality(M, N, ARITY, ARGS_TYPES).
% #TODO check that the types of the arguments also match

possible_formula(F',@name(F'),@args(F'),@arity(F')):- formula(M, F), possible_formula(F,  N, ARGS, ARITY), arg_formula(F, X, F').
possible_formula(F',@name(F'),@args(F'),@arity(F')):- formula(M, F), derive(F,F',T).


modality(M):- modality(M, _, _, _).
formula(atom, F):- possible_formula(F, N, ARGS, ARITY), N!=_show, not formula(M,F):modality(M).


