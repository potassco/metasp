#program metasp_preprocess.
% some sanity checks

aspen(exception(node(ExpDef),
							  format("Expected {} argument definitions for expression {}/{}, found {}.",
											 (ArityStr, (IdName, (ArityStr, (@num_to_string(N), ())))))))
  :- expression_sig(TypeName, ExpDef, (IdName, Arity)),
		 N = #count{ Idx: arg_kwarg((IdName, Arity), Idx, _, _ ) },
		 Arity != N,
		 @num_to_string(Arity) = ArityStr.

% raise parse errors

aspen(exception(node(Node), "Missing node near point.")) :- missing(Node).
aspen(exception(node(Node), "Error near point.")) :- error(Node).

% we cannot have any expressions that are not defined in some type
unknown_metasp_symbol(S)
  :- metasp_symbol(S),
		 symbol_signature(S, Sig),
		 not extended_expression_sig(_, _, Sig).

aspen(exception(node(S), format("Undefined metasp expression &{}/{}.",
															   (Name, (@symbol_to_string(Arity), ())))))
  :- unknown_metasp_symbol(S),
		 symbol_signature(S, (Name,Arity)).

% occurrence must be one of any, head, body, directive
known_type_occurrence("any";"head";"body";"directive").

aspen(exception(node(Type),
							  format("Occurrence of types must be one of any, head, body or directive, got: {}",
											 (Occ, ()))))
  :- occurrence(TypeName, Occ),
		 type_name(Type, TypeName),
		 not known_type_occurrence(Occ).

% metasp symbolic atoms can only occur in allowed places
aspen(exception(node(N),
							  format("Occurence of &{}/{} in forbidden position: {}.",
											 (Name, (@symbol_to_string(Arity), (Occ, ()))))))
  :- root_symbol_occurrence(N, Occ),
		 symbol_signature(N, (Name, Arity)),
		 type(N, "metasp_symbolic_atom"),
		 not metasp_atom_allowed_occurrence(N, Occ),
		 not unknown_metasp_symbol(N).


% all arguments of defined expression must have an associated safety.
allowed_safety(("safe";"unsafe")).

arg_safety((IdName, Arity), Idx, Safety)
  :- extended_arg_kwarg((IdName, Arity), Idx, "safety", Safety).

aspen(exception(node(ExpDef),
								format("One or more arguments of expression definition '{}' does not have provided safety information.",
											 (node(ExpDef), ()))))
  :-  extended_expression_sig(TypeName, ExpDef, (IdName, Arity)),
			Arity > 0,
			#false: arg_safety((IdName, Arity), _, Safety),
			        allowed_safety(Safety).

% check that all metasp function not in macros are reachable starting
% from an extended root node through metasp function nodes

root_metasp_symbol(N) :- type(N, "metasp_symbolic_atom").
root_metasp_symbol(N) :- macro_root_symbol(N).
root_metasp_symbol(N)
  :- type(S,"show_term"),
		 child(S,N),
		 type(N, "metasp_function").
root_metasp_symbol(N)
  :- type(E,"edge_pair"),
		 child(E,N),
		 type(N, "metasp_function").
reach_metasp_symbol(N) :- root_metasp_symbol(N).
reach_metasp_symbol(M) :- reach_metasp_symbol(N), metasp_operand(N,_,M).

aspen(exception(node(N),
							  format("Metasp expression {} is not reachable from metasp symbolic atom through other metasp expressions.", (node(N), ()))))
  :- metasp_symbol(N), not reach_metasp_symbol(N).
