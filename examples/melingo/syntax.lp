type(mel).
subtype(atom, mel).

type(ub).
subtype(number, ub).
subtype(atom, ub).
% constructor(ub, (w,0), none).

% type(interval).
% constructor(interval, (i,2), none).
%     arg( (i,2), 0, type, number).
%     arg( (i,2), 1, type, ub).


constructor(mel, (initial, 0), body).
constructor(mel, (final, 0), body).

constructor(mel, (next, 2), any).
    arg( (next, 2), 0, type, (number,ub)).
    arg( (next, 2), 1, type, mel).

% constructor(mel, next, 2).
    % constructor(mel, next, 0, (number,number),safe).
    % constructor(mel, next, 0, mel,safe).

% constructor(mel, next, 2, ((number,omega),mel)).

constructor(mel, (eventually, 2), any).
    arg( (eventually,2), 0, type, (number,ub)).
    arg( (eventually,2), 1, type, mel).

constructor(mel, (always, 2), any).
    arg( (always,2), 0, type, (number,ub)).
    arg( (always,2), 1, type, mel).


% ------------------------------------ Derived --------- %%
constructor(mel, (next, 1), any).
    arg( (next,1), 0, type, mel).


var(_a, mel).
defined_as(any, next(_a), __next((0,w), _a)).
