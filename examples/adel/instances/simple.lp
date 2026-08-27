&action(a).

% {f}.
:- not &always(a, f).
% &always(a, f).
&always(&seq(&atrue,&atrue), f):-&initial.

#show &always/2.
#show f/0.
#show &initial/0.
