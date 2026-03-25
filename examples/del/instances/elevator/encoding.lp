
{wait;up; down;serve} = 1 :- not &final.
:- up, at(X), not floor(X+1). :- down, at(X), not floor(X-1).

% ISSUE: If we dont have the floor(X-1) condition here,
% the external generated is #external at(X-1): down, at(X), which leads to an infinite grounding
&next(at(X+1)):- up, at(X), not &final, floor(X+1).
&next(at(X-1)):- down, at(X), not &final, floor(X-1).
&next(at(X) ):- at(X), not up, not down, not &final.
&next(called(X)):- called(X), not &final, #false:at(X), serve.
:- called(X), &final.
ready :- called(X), at(X).

% Control constraint
#const use_control = true.
:- &initial,
    use_control = true,
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
