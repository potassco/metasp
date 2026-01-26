aspen(exception(format("Expected node identifier, found {}.", (Node, ()))))
  :- aspen(query(descendant(Node))), not node(Node).

aspen(return(Query, Node))
  :- aspen(Query), Query = query(descendant(Node)).

aspen(return(Query, Node''))
  :- aspen(return(Query, Node')), Query = query(descendant(Node)),
		 child(Node', Node'').
