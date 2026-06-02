#include "metasp.show.lp".
#include "metasp.meta.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".

% ----------------------------
%## lt
true(&lt(X,Y))  :- formula(num, &lt(X,Y)), &sus{X}<Y.
&sus{X}<Y  :- true(&lt(X,Y)).

% ---------------------
%## in
% Only used in the body
&in{L..U}=:X :- formula(num, &range(L,U,X)), true(&range(L,U,X)).
