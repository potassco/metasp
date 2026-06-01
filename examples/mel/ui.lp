elem(footer(W), container, section(model(W))):-model(W).

    elem(footer_elem(t(W)), container, footer(W)):-model(W), _clinguin_assign(t(W),V).

        elem(footer_item(t(W)),label,footer_elem(t(W))):-model(W), _clinguin_assign(t(W),V).
        attr(footer_item(t(W)),label,@format("time={} ",V)):-model(W), _clinguin_assign(t(W),V).
        attr(footer_item(t(W)),class,("fst-italic";"text-success")):-model(W), _clinguin_assign(t(W),V).
