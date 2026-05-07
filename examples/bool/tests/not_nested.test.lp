{a}.
{b}.
&not(&not(a)).

#show a/0.
#show b/0.

% #TEST
% clingo --meta-config ../config.yml --const n=1
% - a
% - b a
