type(mel).
allow(mel,body).
allow(mel,head).

type(ub).
subtype(number, ub).
subtype(atom, ub).

subtype(atom, mel).
expression(mel, (initial, 0)).
expression(mel, (final, 0)).
expression(mel, (next, 2)).
    arg( (next, 2), 0, type, (number,ub)).
    arg( (next, 2), 1, type, mel).
expression(mel, (eventually, 2)).
    arg( (eventually,2), 0, type, (number,ub)).
    arg( (eventually,2), 1, type, mel).
expression(mel, (always, 2)).
    arg( (always,2), 0, type, (number,ub)).
    arg( (always,2), 1, type, mel).


% ------------------------------------ Derived --------- %%
% expression(mel, (next, 1)).
    % arg( (next,1), 0, type, mel).


var(_a, mel).
macro(mel, __next(_a), __next((0,w), _a)).
