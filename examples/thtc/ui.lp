elem(footer(W), container, section(model(W))):-world(W).

    elem(footer_elem(var(K,W)), container, footer(W)):-world(W), _clinguin_assign(var(K,W),V),K!=_one.

        elem(footer_item(var(K,W)),label,footer_elem(var(K,W))):-world(W), _clinguin_assign(var(K,W),V),K!=_one.
        attr(footer_item(var(K,W)),label,@format("{}={}",K,V)):-world(W), _clinguin_assign(var(K,W),V),K!=_one.
        attr(footer_item(var(K,W)),class,("fst-italic";"text-success")):-world(W), _clinguin_assign(var(K,W),V),K!=_one.
