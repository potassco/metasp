type(mel).
allow(mel,body).
allow(mel,head).

subtype(function, mel).
expression(mel, (__top, 0)).
expression(mel, (__bottom, 0)).
expression(mel, (__initial, 0)).
expression(mel, (__final, 0)).
expression(mel, (__next, 2)).
    arg( (__next, 2), 0, type, (number,symbol)).
    arg( (__next, 2), 1, type, mel).
expression(mel, (__eventually, 2)).
    arg( (__eventually,2), 0, type, (number,symbol)).
    arg( (__eventually,2), 1, type, mel).
expression(mel, (__always, 2)).
    arg( (__always,2), 0, type, (number,symbol)).
    arg( (__always,2), 1, type, mel).


var(v, mel).
macro(mel, __next(v), __next((0,w), v)).
