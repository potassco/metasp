
% #type mel {
%     expressions: {
% 	    &top/0;
% 	    &bottom/0;
%         &initial/0;
%         &final/0;
%         &next/2: {
%             type: (number, number), safety: safe;
%             type: mel, safety: safe;
%         };
%     };
%     subtypes: {
%         function;
%     };
%     macros: {
%         &next(v1): &next(0, v1);
%         where: {
%             v1: mel;
%         };
%     };
%     occurrence: any;
% }.


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


var(mel, v, mel).
macro(mel, __next(v), __next((0,w), v)).
