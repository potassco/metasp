#program always.

floor(1..nfloors). %Instance
{wait;up;down;serve}=1:- not &final.
:- up, at(X), not floor(X+1). :- down, at(X), not floor(X-1).
at(X+1):- 'up, 'at(X).
at(X-1):- 'down, 'at(X).
at(X) :- 'at(X), not 'up, not 'down. called(X):- 'called(X), #false:'at(X), 'serve.
:- called(X), &final.
ready :- called(X), at(X).

#program initial.
at((nfloors+1)/2). called(1;nfloors). %Instance

