% #type upper_bound {
%    subtypes: {
%        number;
%        supremum;
%    };
% }.
% #type interval {
%     expressions: {
%         &i/2: {
%             type: number;
%             type: upper_bound;
%         };
%     };
% }.
% #type mel {
%     expressions: {
% 	    &top/0;
% 	    &bottom/0;
%         &initial/0;
%         &final/0;
%         &next/2: {
%             type: interval, safety: safe;
%             type: mel, safety: safe;
%         };
%         &eventually/2: {
%             type: interval, safety: unsafe;
%             type: mel, safety: unsafe;
%         };
%         &always/2: {
%             type: interval, safety: safe;
%             type: mel, safety: safe;
%         };
%     };
%     subtypes: {
%         atom;
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

subtype(atom, mel).
expression(mel, (__top, 0)).
expression(mel, (__bottom, 0)).
expression(mel, (__initial, 0)).
expression(mel, (__final, 0)).
expression(mel, (__next, 2)).
    arg( (__next, 2), 0, type, interval).
    arg( (__next, 2), 1, type, mel).
expression(mel, (__eventually, 2)).
    arg( (__eventually,2), 0, type, interval).
    arg( (__eventually,2), 1, type, mel).
expression(mel, (__always, 2)).
    arg( (__always,2), 0, type, interval).
    arg( (__always,2), 1, type, mel).


var(mel, v, mel).
macro(mel, __next(v), __next(__i(0,#sup), v)).

% Not doable becase x+1 is not defined
% var(mel, x, number).
% macro(mel, __next(x,v), __next(__i(x,x+1), v)).


type(interval).
expression(interval, (__i, 2)).
    arg((__i, 2), 0, type, number).
    arg((__i, 2), 1, type, upper_bound).

type(upper_bound).
subtype(number, upper_bound).
subtype(supremum, upper_bound).
