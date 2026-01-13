
% Explicit show statements to include in the domain files for the UI to improve performance

#show type/1.
#show subtype/2.
#show expression/4.
#show world/1.
#show conjunction/2.
#show output/2.
#show shown_type/1.


% #show true(X,W): true(X,W), relevalt_f(_,X).
#show formula(T,S): formula(T,F), sugar(F,S).
#show true(S,W): true(F,W), sugar(F,S).
#show true(S,W): true(F,W), sugar(F,S).

#show show_hide/0.
#show show/2.


% #show true(F,K) : formula(atom,F), true(F,K), not show(_,_), not show_hide.

% Show all true formulas that have a condition
% #show true(S,K) : show(S,B), conjunction(B,K).

% #show formula/2.
% #show true/2.
#show derive/3.
#show expression/4.
