elem(footer(W), container, section(model(W))):-world(W).

    elem(footer_elem(t(W)), container, footer(W)):-world(W), _clinguin_assign(t(W),V).

        elem(footer_item(t(W)),label,footer_elem(t(W))):-world(W), _clinguin_assign(t(W),V).
        attr(footer_item(t(W)),label,@format("time={} ",V)):-world(W), _clinguin_assign(t(W),V).
        attr(footer_item(t(W)),class,("fst-italic";"text-success")):-world(W), _clinguin_assign(t(W),V).
