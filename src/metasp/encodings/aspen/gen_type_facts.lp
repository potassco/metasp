#script (python)

from clingo.symbol import String, Function, Number

def string_to_const(string: String) -> Function:
    return Function(string.string, [])

def dunderfy(string: String) -> String:
		return String("__" + string.string)
#end.

#program metasp_preprocess.

% print

metasp(type(@string_to_const(Name))) :- type_name(_, Name).

metasp(expression(@string_to_const(TypeName), (@string_to_const(@dunderfy(IdName)), Arity)))
  :- expression_sig(TypeName, _, (IdName, Arity)).

metasp(arg((@string_to_const(@dunderfy(IdName)), Arity),
					 Idx,
					 @string_to_const(KwargNameText),
					 @string_to_const(KwargValText)))
  :- arg_kwarg((IdName, Arity), Idx, KwargNameText, KwargValText).

metasp(var(@string_to_const(TypeName),
					 @string_to_const(VarName),
					 @string_to_const(VarType)))
  :- var(TypeName, VarName, VarType).

metasp(subtype(@string_to_const(SubTypeName), @string_to_const(TypeName)))
  :- subtype(SubTypeName, TypeName).

metasp(allow(@string_to_const(TName), head))
  :- occurrence(TName, Text),
		 Text = "head".

metasp(allow(@string_to_const(TName), body))
  :- occurrence(TName, Text),
		 Text = "body".

aspen(print(format("{}.", (@symbol_to_string(F), ())), fact_file)) :- metasp(F).
aspen(print(format("macro({}, {}, {}).", 
									 (TypeName, (node(Head), (node(Body), ())))), 
						fact_file)) :- macro(TypeName, Head, Body).
