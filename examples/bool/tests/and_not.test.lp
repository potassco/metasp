{b}.
a.
c:- &and(a,&not(b)).

#show b/0.
#show a/0.
#show c/0.

% #TEST
%   clingo --meta-config ../config.yml
% - a c
% - b a
