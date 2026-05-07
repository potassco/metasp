#include "metasp.show.lp".
#include "metasp.meta.lp".
#include "metasp.reify-defined.lp".
#include "metasp.reify-defined-metasp.lp".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #Not
                :- formula(bool, &not(F)), true(&not(F)), not not true(F).  % ? "not not"
true(&not(F))   :- formula(bool, &not(F)), not true(F).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #And
true(&and(F1,F2)) :- formula(bool, &and(F1,F2)), true(F1), true(F2).
true(F1):-true(&and(F1,F2)).
true(F2):-true(&and(F1,F2)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #Or
true(&or(F1,F2)) :- formula(bool, &or(F1,F2)), true(F1).
true(&or(F1,F2)) :- formula(bool, &or(F1,F2)), true(F2).
true(F1);true(F2):-true(&or(F1,F2)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #To
true(&to(F1,F2)) :- formula(bool, &to(F1,F2)), true(F2): true(F1).
true(F2) :- true(&to(F1,F2)), true(F1).
% ???
% true(F); true(F' ) :- theory_term_tree(F,("<-",F',F'')),   not not true(F'').
