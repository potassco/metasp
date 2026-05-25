% Control constraint
:- &initial,
    not &eventually(
        &seq(
            &star(
                &seq(
                    &choice(&star(up), &star(down)),
                    &seq(&test(ready), serve)
                )
            ),
            &star(wait)
        ),
        &final
    ).
