% generate externals for metasp
#include "./utils/symbol_signature.lp".
#include "./utils/named_child_index.lp".

#program metasp_preprocess.

% some definitions.

negation(N) :- type(N, ("default_negation"; "double_default_negation")).
positive(N)
  :- type(N, ("literal"; "body_literal")),
		 #false: child(N,S), negation(S).

extended_expression_sig(TypeName, ExpDef, Sig) :- expression_sig(TypeName, ExpDef, Sig).
extended_arg_kwarg(Sig, Idx, Name, Val) :- arg_kwarg(Sig, Idx, Name, Val).

metasp_symbol(N) :- type(N,("metasp_symbolic_atom";"metasp_function")).
macro_root_symbol((Head;Body)) :- valid_macro(_,Head,Body).
root_symbol(N) :- type(N, ("metasp_symbolic_atom";"symbolic_atom")).
root_symbol(N) :- macro_root_symbol(N).

symbol_signature(N,(Name,Arity))
  :- metasp_symbol(N), child(N,M), type(M,"terms"), field(M,"arguments"),
		 MaxIdx = #max{ Idx : child(M,L), named_child_index(L,Idx) }, Arity=MaxIdx+1,
		 child(N,J), type(J,"identifier"), field(J,"name"), leaf_text(J,Name).

symbol_signature(N,(Name,0))
  :- metasp_symbol(N), #false: child(N,M), type(M,"terms");
		 child(N,J), type(J,"identifier"), field(J,"name"), leaf_text(J,Name).

metasp_atom_type(N, TypeName)
  :- type(N, "metasp_symbolic_atom"),
		 symbol_signature(N, Sig),
		 extended_expression_sig(TypeName, _, Sig).

metasp_atom_allowed_occurrence(N, Occ)
  :- type(N, "metasp_symbolic_atom"),
		 symbol_signature(N, Sig),
		 metasp_atom_type(N, TypeName),
		 occurrence(TypeName, Occ).

metasp_atom_allowed_occurrence(N,("head";"body")) :- metasp_atom_allowed_occurrence(N, "any").
metasp_atom_allowed_occurrence(N,"directive") :- metasp_atom_allowed_occurrence(N, "head").

metasp_operand(N,Idx,O)
  :- metasp_symbol(N), child(N,M), type(M,"terms"),
		 child(M,O), named_child_index(O,Idx).

% deterine occurrences of symbols in program.
% note: we do not count negated literals as head occurences

root_symbol_occurrence(N, "head")
  :- type(M,"literal"),
		 positive(M),
		 field(M,"head"),
		 child(M,N),
		 root_symbol(N).

root_symbol_occurrence(O, "head")
  :- type(M,"disjunction"),
		 child(M,N),
		 type(N,"literal"),
		 positive(N),
		 child(N,O),
		 root_symbol(O).

root_symbol_occurrence(P, "head")
  :- type(M, "disjunction"),
		 child(M,N),
		 type(N,"conditional_literal"),
		 child(N,O),
		 type(O,"literal"),
		 positive(O),
		 child(O,P),
	   root_symbol(P).

root_symbol_occurrence(Q, "head")
  :- type(M, "set_aggregate"),
		 field(M, "head"),
		 child(M, N),
		 type(N, "set_aggregate_elements"),
		 child(N,O),
		 type(O, "set_aggregate_element"),
		 child(O,P),
		 type(P,"literal"),
		 positive(P),
		 child(P,Q),
		 root_symbol(Q).

root_symbol_occurrence(Q, "head")
  :- type(M, "head_aggregate"),
		 child(M, N),
		 type(N, "head_aggregate_elements"),
		 child(N,O),
		 type(O, "head_aggregate_element"),
		 child(O,P),
		 type(P,"literal"),
		 positive(P),
		 child(P,Q),
		 root_symbol(Q).

root_symbol_occurrence(N, "directive")
  :- type(M,"literal"),
		 positive(M),
		 field(M, "head"),
		 child(M,N),
		 root_symbol(N),
		 child(L, M),
		 type(L, "rule"),
		 #false: child(L, B), type(B, "body").

root_symbol_occurrence(M, "macrodef") :- macro_root_symbol(M).

root_symbol_occurrence(M, "body")
  :- root_symbol(M),
		 not root_symbol_occurrence(M, "head"),
		 not root_symbol_occurrence(M, "macrodef").


% determine safety of atom operands.


metasp_operand_safety(N,O,Safety)
  :- symbol_signature(N,(Name, Arity)),
		 metasp_operand(N,Idx,O),
		 arg_safety((Name, Arity), Idx, Safety).

% base cases
% everything starts out as safe
root_symbol2operand(Root, Root, "safe")
  :- root_symbol(Root).

% recursion
root_symbol2operand(Root, Operand, Safety)
  :- root_symbol2operand(Root, Symb, Safety),
		 metasp_operand_safety(Symb, Operand, "safe").

root_symbol2operand(Root, Operand, "unsafe")
  :- root_symbol2operand(Root, Symb, _),
		 metasp_operand_safety(Symb, Operand, "unsafe").

root_symbol2leaf_operand(Root, Symb, Safety)
  :- root_symbol2operand(Root, Symb, Safety),
		 not metasp_operand(Symb,_,_).


% deal with macros


macro_head_var(TypeName, Head, Body, Idx, Name)
  :- macro(TypeName, Head, Body),
		 metasp_operand(Head, Idx, Func),
		 type(Func, "function"),
		 symbol_signature(Func, (Name, 0)).

valid_macro(TypeName, Head, Body)
  :- macro(TypeName, Head, Body),
		 macro_head_var(Type, Head, Body, Idx, _): metasp_operand(Head, Idx, Operand).

extended_expression_sig(TypeName, Sig, Sig)
  :- valid_macro(TypeName, Head, Body),
		 symbol_signature(Head, Sig).

aspen(query(descendant(Body)))
  :- valid_macro(TypeName, Head, Body).

in_macro_body(Body, Node)
  :- valid_macro(TypeName, Head, Body),
		 aspen(return(query(descendant(Body)), Node)).

extended_arg_kwarg(Sig, Idx, "safety", "safe")
  :- valid_macro(TypeName, Head, Body),
		 in_macro_body(Body, Var),
		 root_symbol2leaf_operand(Body, Var, "safe"),
		 symbol_signature(Var, (Name, 0)),
		 macro_head_var(TypeName, Head, Body, Idx, Name),
		 symbol_signature(Head, Sig).

extended_arg_kwarg(Sig, Idx, "safety", "unsafe")
  :- valid_macro(TypeName, Head, Body),
		 symbol_signature(Head, Sig),
		 macro_head_var(TypeName, Head, Body, Idx, Name),
		 not extended_arg_kwarg(Sig, Idx, "safety", "safe").


% generate externals


safe_occurrence(N)
  :- root_symbol_occurrence(N, "body"),
		 child(O, N),
		 type(O, "body_literal"),
		 positive(O).

statement(SourceSymb, Statement)
  :- type(Source, "source_file"),
     child(Source, Statement),
		 source_root(SourceSymb, Source),
     not type(Statement, "metasp_type").

aspen(query(descendant(Statement))) :- statement(_, Statement).

statement_desc(Statement, Node)
  :- aspen(return(query(descendant(Statement)), Node)),
		 statement(_, Statement).

metasp_statement(Statement)
  :- statement_desc(Statement, Node),
		 metasp_symbol(Node).

metasp_statement_desc(Statement, Node)
  :- metasp_statement(Statement),
		 statement_desc(Statement, Node).

% The head of an external generated for a head root symbol of the
% original statement is a leaf operand of the root symbol.
ext_head(HeadRoot, HeadLeaf)
  :- metasp_statement_desc(Statement, HeadRoot),
		 root_symbol_occurrence(HeadRoot, "head"),
		 root_symbol2leaf_operand(HeadRoot, HeadLeaf, _),
		 symbol(HeadLeaf).

% The head of an external generated for a body metasp symbolic atom of
% the original statement is the metasp symbolic atom itself
ext_head(BodyRoot, BodyRoot)
  :- metasp_statement_desc(Statement, BodyRoot),
		 type(BodyRoot, "metasp_symbolic_atom"),
		 root_symbol_occurrence(BodyRoot, "body").

% In both cases, the body of the external statement consists of the
% conjunction of the safe atomic leaf operands occurring in the body
% of the original statement.
ext_body(HeadLeaf, BodyLeaf)
  :- metasp_statement_desc(Statement, HeadLeaf),
		 ext_head(_,HeadLeaf),
		 metasp_statement_desc(Statement, BodyRoot),
		 safe_occurrence(BodyRoot),
		 root_symbol2leaf_operand(BodyRoot, BodyLeaf, "safe"),
		 symbol(BodyLeaf).

% If the operator is part of a condition (as head or body), we need to
% include the (safe leaf atoms of) condition as well in the body of
% external statement protecting the operator.

% 1. case: member is head of condition.
cond_member2cond(E,C)
  :- type(N, "literal"),
		 child(N,E),
		 root_symbol(E),
		 child(P,N),
		 child(P,C),
		 type(C, "condition").

% 2. case: member is body of condition.
cond_member2cond(E,C)
  :- type(N, "literal"),
		 child(N,E),
		 root_symbol(E),
		 child(C,N),
		 type(C, "condition").

ext_body(Leaf, CondBodyLeaf)
  :- metasp_statement_desc(Statement, Root),
		 ext_head(Root, Leaf),
		 cond_member2cond(Root, Cond),
		 child(Cond, Lit),
		 type(Lit, "literal"),
		 positive(Lit),
		 child(Lit, CondBodyRoot),
		 root_symbol2leaf_operand(CondBodyRoot, CondBodyLeaf, "safe"),
		 symbol(CondBodyLeaf).
