
% Explicit show statements to include in the domain files for the UI to improve performance

#show type/1.
#show subtype/2.
#show expression/4.
#show world/1.
#show conjunction/2.
#show output/2.
#show shown_type/1.

relevalt_f(atom,X):- formula(atom,X),not output(_show,_).
relevalt_f(T,X):- formula(T,X), shown_type(T), not derive(_,X,_).


#show true(X,W): true(X,W), relevalt_f(_,X).
#show formula(T,X): relevalt_f(T,X).
