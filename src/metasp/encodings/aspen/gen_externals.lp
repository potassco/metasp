#program metasp_preprocess.

% auxiliary predicates for generation of externals

ext_body_idx(Head, Body, Idx)
  :- ext_body(Head, Body),
		 Idx = #count{ B: ext_body(Head, B), B < Body }.

_ext_head_cons(node(Head), (), -1) :- ext_head(_,Head).

_ext_head_cons(node(Head), (node(Body), Cons), Idx+1)
  :- _ext_head_cons(node(Head), Cons, Idx),
		 ext_body_idx(Head, Body, Idx+1).

ext_head_cons(node(Head), Cons)
  :- _ext_head_cons(node(Head), Cons, Idx),
		 not ext_body_idx(Head, _, Idx+1).

ext_head_source(Head, Source)
  :- ext_head(_,Head),
		 metasp_statement_desc(Statement, Head),
		 statement(Source, Statement).

aspen(print(format("#external {}: {}.", (node(Head), (join(", ", Cons), ()))), Source))
  :- ext_head_cons(node(Head), Cons),
		 Cons != (),
		 ext_head_source(Head, Source).

aspen(print(format("#external {}.", (node(Head), ())), Source))
  :- ext_head_cons(node(Head), ()),
		 ext_head_source(Head, Source).
