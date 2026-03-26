#include "./utils/descendant.lp".

#program metasp_preprocess.

aspen(next_program("metasp_remove_ampersand", ())).

#program metasp_remove_ampersand.

metasp_type(MetaType) :- type(MetaType, "metasp_type").
aspen(query(descendant(MetaType)))  :- metasp_type(MetaType).
exempt(Node) :- aspen(return(query(descendant(MetaType)), Node)), metasp_type(MetaType).

ampersand_id(Amp, Id)
  :- type(Node, "metasp_function"),
     child(Node, Amp),
     leaf_text(Amp, "&"),
     child(Node, Id),
		 type(Id, "identifier"),
		 not exempt(Node).

ampersand_id(Amp, Id)
  :- type(Node, "metasp_symbolic_atom"),
     child(Node, Amp),
     leaf_text(Amp, "&"),
     child(Node, Id),
     type(Id, "identifier"),
     not exempt(Node).

ampersand_id(Amp, Id)
  :- type(Node, "metasp_signature"),
     child(Node, Amp),
     leaf_text(Amp, "&"),
     child(Node, Id),
     type(Id, "identifier"),
     not exempt(Node).

aspen(edit(node(Amp), ""))
  :- ampersand_id(Amp,_).

aspen(edit(node(Id), format("__{}", (node(Id), ()))))
  :- ampersand_id(_, Id).
