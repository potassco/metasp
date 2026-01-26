#script (python)

from clingo.symbol import String, Number, Symbol

def string_to_num(string: Symbol) -> Symbol:
		return Number(int(string.string))

def num_to_string(num: Symbol) -> Symbol:
		return String(str(num.number))

#end.

% raise errors

#program metasp_preprocess.

% type

type_name(MetaType, Name)
  :- type(MetaType, "metasp_type"),
		 child(MetaType, Id),
		 type(Id, "identifier"),
		 leaf_text(Id, Name).

% expression

expression_sig(TypeName, ExpDef, (IdName, @string_to_num(Arity)))
  :- type_name(MetaType, TypeName),
		 child(MetaType, ExpDefinitions),
		 type(ExpDefinitions, "metasp_expression_definitions"),
		 child(ExpDefinitions, ExpDef),
		 type(ExpDef, "metasp_expression_definition"),
		 child(ExpDef, Sig),
		 type(Sig, "metasp_signature"),
		 child(Sig, Id),
		 type(Id, "identifier"),
		 leaf_text(Id, IdName),
		 child(Sig, Num),
		 type(Num, "number"),
		 leaf_text(Num, Arity).

% arg

arg_kwarg((IdName, Arity), Idx, KwargNameText, KwargValText)
  :- expression_sig(TypeName, ExpDef, (IdName, Arity)),
		 type_name(MetaType, TypeName),
		 child(ExpDef, Args),
		 type(Args, "metasp_argument_definitions"),
		 child(Args, Arg),
		 type(Arg, "metasp_argument_definition"),
		 child_index(Arg, Idx),
		 child(Arg, Kwarg),
		 type(Kwarg, "metasp_keyword_arg"),
		 child(Kwarg, KwargName),
		 field(KwargName, "name"),
		 leaf_text(KwargName, KwargNameText),
		 child(Kwarg, KwargVal),
		 field(KwargVal, "value"),
		 leaf_text(KwargVal, KwargValText).

% macro

macro(TypeName, MacroHead, MacroBody)
  :- type_name(MetaType, TypeName),
		 child(MetaType, Macros),
		 type(Macros, "metasp_macros"),
		 child(Macros, MacroDef),
		 type(MacroDef, "metasp_macro_definition"),
		 child(MacroDef, MacroHead),
		 type(MacroHead, "metasp_function"),
		 child_index(MacroHead, 0),
		 child(MacroDef, MacroBody),
		 type(MacroBody, "metasp_function"),
		 child_index(MacroBody, 2).

% var

var(TypeName, VarName, VarType)
  :- type_name(MetaType, TypeName),
		 child(MetaType, Macros),
		 type(Macros, "metasp_macros"),
		 child(Macros, MacroWhere),
		 type(MacroWhere, "metasp_macro_where"),
		 child(MacroWhere, Kwarg),
		 type(Kwarg, "metasp_keyword_arg"),
		 child(Kwarg, KwargName),
		 field(KwargName, "name"),
		 leaf_text(KwargName, VarName),
		 child(Kwarg, KwargVal),
		 field(KwargVal, "value"),
		 leaf_text(KwargVal, VarType).

% subtype

subtype(SubTypeName, TypeName)
  :- type_name(MetaType, TypeName),
		 child(MetaType, Subtypes),
		 type(Occ, "metasp_subtypes"),
		 child(Subtypes, Id),
		 type(Id, "identifier"),
		 leaf_text(Id, SubTypeName).

% allow

occurrence(TypeName, OccText)
  :- type_name(MetaType, TypeName),
		 child(MetaType, Occ),
		 type(Occ, "metasp_occurrence"),
		 child(Occ, TheoryType),
		 type(TheoryType, "theory_atom_type"),
		 leaf_text(TheoryType, OccText).

occurrence(TypeName, ("head"; "body")) :- occurrence(TypeName, "any").
