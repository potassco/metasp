% # Window
% -------
elem(w, window, root).
attr(w, class, ("d-flex"; "flex-column")).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #General attributes
attr(main(S), class, ("d-flex"; "flex-row";"bg-opacity-25";"w-100";"p-2";"rounded";"m-2")):-elem(main(S),container,_).
attr(main(S), class, ("bg-primary";"bg-opacity-59")):-elem(main(S),container,_),_clinguin_browsing.
attr(main(S), class, ("bg-info")):-elem(main(S),container,_),not _clinguin_unsat, not _clinguin_browsing.
attr(main(S), class, ("bg-danger")):-elem(main(S),container,_), _clinguin_unsat.
attr(section(S), class, ("d-flex"; "flex-column"; "align-items-center";"rounded";"p-2";"m-2";"bg-light";"shadow")):-elem(section(S),container,_).
attr(title(T), class, ("h5";"pb-1")):-elem(title(T),label,_).
attr(title(T), order, 1):-elem(title(T),label,_).
attr(content(C), class, ("d-flex"; "flex-column";"w-100";"p-1";"border-top";"border-bottom")):-elem(content(C),container,_).
attr(content(C), order, 2):-elem(content(C),container,_).
attr(footer(C), class, ("d-flex"; "flex-column";"w-100";"p-1")):-elem(footer(C),container,_).
attr(footer(C), order, 3):-elem(footer(C),container,_).
attr(footer_elem(C), class, ("d-flex";"flex-row-reverse")):- elem(footer_elem(C),container,_).
attr(footer_item(C), class, ("m-1";"btn-primary")):- elem(footer_item(C),button,_).
attr(footer_item(C), class, ("m-1")):- elem(footer_item(C),textfield,_).
attr(footer_item(C), class, ("m-1";"btn-outline-dark")):- elem(footer_item(C),dropdown_menu,_).

attr(elem_container(C), class, ("d-flex"; "flex-row"; "align-items-left";"justify-content-between")):-elem(elem_container(C),container,_).
attr(elem_title(C), order, 1):-elem(elem_title(C),_,_).
attr(elem_title(C), class, ("pe-5";"fst-italic")):-elem(elem_title(C),_,_).
attr(elem_title(C), height, "28pt"):-elem(elem_title(C),label,_).
attr(elem_val(C), order, 2):-elem(elem_val(C),_,_).
attr(elem_val(C), class, ("btn-outline";"btn-small";"fw-lighter")):-elem(elem_val(C),_,_).
attr(elem_val(C), class, ("pe-3";"pt-1";"pb-1")):-elem(elem_val(C),label,_).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




elem(main(state), container, w).
attr(main(state), order, 1).

    % ## Constants
    % ------------

    elem(section(constants), container, main(state)).

        elem(title(constants), label, section(constants)).
        attr(title(constants), label, "Constants").

        elem(content(constants), container, section(constants)).

            elem(elem_container(const(C)), container, content(constants)):-_clinguin_const(C,V).

                elem(elem_title(const(C)), label, elem_container(const(C))):-_clinguin_const(C,V).
                attr(elem_title(const(C)), label, @format("#const {}",C)):-_clinguin_const(C,V).

                elem(elem_val(const(C)), label, elem_container(const(C))):-_clinguin_const(C,V).
                attr(elem_val(const(C)), label,V):-_clinguin_const(C,V).
                % attr(const_label(C), class, "w-100"):-_clinguin_const(C,V).

        elem(footer(constants), container, section(constants)).

            elem(footer_elem(constants), container, footer(constants)).

                elem(footer_item(const(name)),textfield,footer_elem(constants)).
                attr(footer_item(const(name)),placeholder,"name").
                attr(footer_item(const(name)),width,"60pt").
                when(footer_item(const(name)),input,context,(const_name,_value)).

                elem(footer_item(const(val)),textfield,footer_elem(constants)).
                attr(footer_item(const(val)),placeholder,"value").
                attr(footer_item(const(val)),width,"60pt").
                when(footer_item(const(val)),input,context,(const_value,_value)).

                elem(footer_item(const(btn)),button,footer_elem(constants)).
                attr(footer_item(const(btn)),label,"Set constant").
                when(footer_item(const(btn)),click,call, set_constant(_context_value(const_name),_context_value(const_value))).


    % ## Types
    % ------------

    elem(section(types), container, main(state)).

        elem(title(types), label, section(types)).
        attr(title(types), label, "Types").

        elem(content(types), container, section(types)).

            atom_type(T):- type(T), allow(T,head); allow(T,body), T!=atom.
            elem(elem_container(type(T)), container, content(types)):-atom_type(T).

                elem(elem_title(type(T)), checkbox, elem_container(type(T))):-atom_type(T).
                attr(elem_title(type(T)), label, T):-atom_type(T).
                attr(elem_title(type(T)), checked, true):-atom_type(T),shown_type(T).
                when(elem_title(type(T)), click,call, set_external(shown_type(T),true)):-atom_type(T),not shown_type(T).
                when(elem_title(type(T)), click,call, set_external(shown_type(T),false)):-atom_type(T), shown_type(T).

                % elem(elem_val(type(M)), label, elem_container(type(M))):-type(M,_,_,_).
                % attr(elem_val(type(M)), label,V):-type(M,_,V).
                % attr(const_label(C), class, "w-100"):-_clinguin_const(C,V).


    % elem(section(assignments), container, main(state)).

    %     elem(title(assignments), label, section(assignments)).
    %     attr(title(assignments), label, "Current model assignments").

    %     elem(content(assignments), container, section(assignments)).

    %         elem(elem_container(assign(K)), container, content(assignments)):-_clinguin_assign(K,V).
    %         attr(elem_container(assign(K)), order, V):-_clinguin_assign(K,V).

    %             elem(elem_title(assign(K)), label, elem_container(assign(K))):-_clinguin_assign(K,V).
    %             attr(elem_title(assign(K)), label, K):-_clinguin_assign(K,V).

    %             elem(elem_val(assign(K)), label, elem_container(assign(K))):-_clinguin_assign(K,V).
    %             attr(elem_val(assign(K)), label,V):-_clinguin_assign(K,V).

    % ## UNSAT
    % ------------

    % elem(section(unsat), container, main(state)):-_clinguin_unsat.

    %     elem(title(unsat), label, section(unsat)):-_clinguin_unsat.
    %     attr(title(unsat), label, "UNSAT"):-_clinguin_unsat.
    %     attr(title(unsat), class, "text-danger"):-_clinguin_unsat.

    %     elem(content(unsat), container, section(unsat)):-_clinguin_unsat.


        % #Todo add MUS


    % ## SAT
    % ------------

    % elem(section(sat), container, main(state)):-not _clinguin_unsat.
    % attr(section(sat), class, ("bg-success")):-not _clinguin_unsat.

    %     elem(title(sat), label, section(sat)):-not _clinguin_unsat.
    %     attr(title(sat), label, "SAT"):-not _clinguin_unsat.
    %     attr(title(sat), class, "text-success"):-not _clinguin_unsat.

    %     elem(content(sat), container, section(sat)):-not _clinguin_unsat.



    % ## Actions
    % ------------

    elem(footer(model), container, main(state)).
    attr(footer(model), order, 3).


    elem(footer_elem(select), container, footer(model)).
    attr(footer_elem(select), order, 2).


        elem(footer_item(select(btn)),button,footer_elem(select)).
        attr(footer_item(select(btn)),order,2).
        attr(footer_item(select(btn)),label,"Select solution").
        attr(footer_item(select(btn)),icon,"fa-hand-pointer").
        attr(footer_item(select(btn)),class,"btn-success").
        when(footer_item(select(btn)),click,call, select("#show. #show true(X,W): true(X,W), formula(atom,X).")).


        elem(footer_item(download(btn)),button,footer_elem(select)).
        attr(footer_item(download(btn)),order,3).
        attr(footer_item(download(btn)),label,"Download solution").
        attr(footer_item(download(btn)),icon,"fa-download").
        attr(footer_item(download(btn)),class,"btn-success").
        when(footer_item(download(btn)),click,call, download("#show. #show (X,W): true(X,W), formula(atom,X).","metasp-solution.lp")).


    elem(footer_elem(browse), container, footer(model)).
    attr(footer_elem(browse), order, 1).

        elem(footer_item(next_solution), button, footer_elem(browse)).
        attr(footer_item(next_solution), order, 3).
        attr(footer_item(next_solution), label, "Next").
        attr(footer_item(next_solution), icon, "fa-forward-step").
        when(footer_item(next_solution), click, call, next_solution).

        % elem(footer_item(next_solution_opt), button, footer_elem(browse)).
        % attr(footer_item(next_solution_opt), order, 2).
        % attr(footer_item(next_solution_opt), label, "Next Optimizing").
        % attr(footer_item(next_solution_opt), icon, "fa-forward-fast").
        % when(footer_item(next_solution_opt), click, call, next_solution(optN)).

        elem(footer_item(stop), button, footer_elem(browse)).
        attr(footer_item(stop), order, 1).
        attr(footer_item(stop), label, "Stop Browsing").
        attr(footer_item(stop), class, "btn-danger").
        attr(footer_item(stop), class, "disabled"):-not _clinguin_browsing.
        attr(footer_item(stop), icon, "fa-stop").
        when(footer_item(stop), click, call, stop_browsing).

% elem(main(input), container, w).
% attr(main(input), order, 2).



elem(main(model), container, w).
attr(main(model), order, 3).

    %  ## Model
    %  ---------------

    elem(section(model(W)), container, main(model)):-world(W).
    attr(section(model(W)), order, W):-world(W).

    elem(content(model(W)), container, section(model(W))):-world(W).
    attr(content(model(W)), class, ("d-flex";"flex-row")):-world(W).

            elem(title(model(W)), label, section(model(W))):-world(W).
            attr(title(model(W)), label, W):-world(W).

            _any_or_browse(A):-_clinguin_browsing, _clinguin_model(A).
            _any_or_browse(A):-not _clinguin_browsing, _any(A).

            show_model(true(X,W)):-_any_or_browse(true(X,W)), formula(atom,X), not show.
            show_model(true(X,W)):-_any_or_browse(conjunction(B,W)), formula(atom,X), show(X,B).
            show_model(true(X,W)):-_any_or_browse(true(X,W)), formula(M,X), shown_type(M), not derive(_,X,_), M!=atom.
            show_model(true(X,W)):-_clinguin_assume(true(X,W),_).

            % show_model(true(X,W)):-_any_or_browse(true(X,W)), formula(atom,X).


            elem(sub_content(model(W)), container, content(model(W))):-world(W).


                elem(elem_container(model(A,W)), container, sub_content(model(W))):-show_model(true(A,W)).

                    elem(elem_title(model(A,W)), button, elem_container(model(A,W))):-show_model(true(A,W)).
                    % attr(elem_title(model(A,W)), label, A):-show_model(true(A,W)).
                    attr(elem_title(model(A,W)), label, L):-show_model(true(A,W)), label(A,L).
                    attr(elem_title(model(A,W)), label, A):-show_model(true(A,W)), not label(A,_).
                    attr(elem_title(model(A,W)), "white-space", "nowrap"):-show_model(true(A,W)).
                    attr(elem_title(model(A,W)), class, "font-monospace"):-show_model(true(A,W)).
                    attr(elem_title(model(A,W)), class, "opacity-25"):- _all(A), show_model(true(A,W)).
                    attr(elem_title(model(A,W)), class, "text-primary"):-  show_model(true(A,W)), not formula(atom,A).
                    attr(elem_title(model(A,W)), class, "text-decoration-underline"):-  show_model(true(A,W)),  _clinguin_assume(true(A,W),true).
                    attr(elem_title(model(A,W)), class, ("text-decoration-line-through")):-  show_model(true(A,W)),  _clinguin_assume(true(A,W),false).
                    attr(elem_title(model(A,W)), opacity, "0.4"):-  show_model(true(A,W)), not true(A,W).
                    attr(elem_title(model(A,W)), class, "fw-bolder"):-  show_model(true(A,W)), _all(true(A,W)).

                    when(elem_title(model(A,W)), click, update, (elem_cm(model(A,W)), visibility, shown)):-  show_model(true(A,W)).


                    elem(elem_cm(model(A,W)), context_menu,w):-show_model(true(A,W)).

                        elem(elem_cm(model(A,W),force), button,elem_cm(model(A,W))):-show_model(true(A,W)).
                        attr(elem_cm(model(A,W),force), label,"Force in model"):-show_model(true(A,W)).
                        when(elem_cm(model(A,W),force), click, call, add_assumption(true(A,W),true)):-show_model(true(A,W)),not _clinguin_assume(true(A,W),_), _any(true(A,W)).
                        attr(elem_cm(model(A,W),force), class, ("disabled";"text-light")):-show_model(true(A,W)),not when(elem_cm(model(A,W),force),_,_,_).

                        elem(elem_cm(model(A,W),remove), button,elem_cm(model(A,W))):-show_model(true(A,W)).
                        attr(elem_cm(model(A,W),remove), label,"Remove from model"):-show_model(true(A,W)).
                        when(elem_cm(model(A,W),remove), click, call, add_assumption(true(A,W),false)):-show_model(true(A,W)),not _clinguin_assume(true(A,W),_), not _all(true(A,W)).
                        attr(elem_cm(model(A,W),remove), class, ("disabled";"text-light")):-show_model(true(A,W)),not when(elem_cm(model(A,W),remove),_,_,_).

                        elem(elem_cm(model(A,W),clear), button,elem_cm(model(A,W))):-show_model(true(A,W)).
                        attr(elem_cm(model(A,W),clear), label,"Clear selection"):-show_model(true(A,W)).
                        when(elem_cm(model(A,W),clear), click, call, remove_assumption(true(A,W))):-show_model(true(A,W)),_clinguin_assume(true(A,W),_).
                        attr(elem_cm(model(A,W),clear), class, ("disabled";"text-light")):-show_model(true(A,W)),not when(elem_cm(model(A,W),clear),_,_,_).


% # Menu bar
% -----------
    elem(menu_bar, menu_bar, w).
    attr(menu_bar, title, @format("{} ({})","METASP",S)):-metasp_system(S).
    attr(menu_bar, icon, "fa-desktop").

        elem(menu_bar_restart, button, menu_bar).
        attr(menu_bar_restart, label, "Restart").
        attr(menu_bar_restart, icon, "fa-arrows-rotate").
        attr(menu_bar_restart, class, "btn-outline-danger").
        attr(menu_bar_restart, class, "border-0").
        when(menu_bar_restart, click, call, restart).
