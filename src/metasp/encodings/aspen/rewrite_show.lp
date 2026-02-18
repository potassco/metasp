#script (python)

from string import ascii_uppercase

from clingo.symbol import String, Function, Symbol

def upper_alphabet_cons(length_str: Symbol) -> Symbol:
    cons = Function("", [])
    length = int(length_str.string)
    for char in ascii_uppercase[:length]:
        cons = Function("", [String(char), cons])
    return cons

#end.

#program metasp_preprocess.

% show
aspen(edit(node(Show), "_show."))
  :- type(Show, "show").

% show term
aspen(edit(node(ShowTerm),
					 format("_show_term({}) :- {}.",
									(node(Term), (node(Body), ())))))
  :- type(ShowTerm, "show_term"),
		 child(ShowTerm, Term),
		 field(Term, "term"),
		 child(ShowTerm, Body),
		 type(Body, "body").

% show signature
extended_signature(S) :- type(S, ("signature"; "metasp_signature")).

signature_sign(S,node(Sign))
  :- extended_signature(S),
		 child(S,Sign),
		 field(Sign, "sign"),
		 type(Sign, "classical_negation").

signature_sign(S,"")
  :- extended_signature(S),
		 #false: child(S,Sign),
		         field_name(Sign, "sign"),
						 type(Sign, "classical_negation").

signature_arity(S,Arity)
  :- extended_signature(S),
		 child(S,A),
		 field(A, "arity"),
		 type(A, "number"),
		 leaf_text(A,Arity).

signature_id_prefix(Sig,"") :- type(Sig, "signature").

signature_id_prefix(Sig,"&") :- type(Sig, "metasp_signature").

arity_var_cons(A, @upper_alphabet_cons(A))
  :- signature_arity(_,A).

aspen(edit(node(ShowSig), format("_show_atom({0}{1}{2}({3})) :- {0}{1}{2}({3}).",
																 (Sign, (Pre, (node(Id), (join(", ", Cons), ())))))))
  :- type(ShowSig, "show_signature"),
		 child(ShowSig, Sig),
		 extended_signature(Sig),
		 signature_id_prefix(Sig, Pre),
		 signature_sign(Sig,Sign),
		 child(Sig, Id),
		 type(Id, "identifier"),
		 signature_arity(Sig, Arity),
		 arity_var_cons(Arity, Cons).
