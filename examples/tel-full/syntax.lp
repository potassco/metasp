% #type tel {
%     expressions: {
% 		&true/0;
% 		&false/0;
% 		&or/2: {
% 			type: tel, safety: unsafe;
% 			type: tel, safety: unsafe;
% 		};
% 		&and/2: {
% 			type: tel, safety: safe;
% 			type: tel, safety: safe;
% 		};
% 		&initial/0;
% 		&final/0;
% 		&next/1: {
% 			type: tel, safety: safe;
% 		};
% 		&until/2: {
% 			type: tel, safety: unsafe;
% 			type: tel, safety: safe;
% 		};
%     };
% 	subtypes: {
% 		atom;
% 	};
%     macros: {
% 		&wnext(v1): &or{&next(v1), &final};
% 		&eventually(v1): &until(&true, v1);
% 		&always(v1): &release(&false, v1);
% 		&release(v1, v2): &until(v2, &and(v2, &or(v1, &final)));
% 		where: {
% 			v1: tel;
% 			v2: tel;
% 		};
%     };
%     occurrence: any;
% }.



type(tel).

expression(tel, (__true, 0)).
expression(tel, (__false, 0)).
expression(tel, (__or, 2)).
	arg((__or, 2), 0, type, tel).
	arg((__or, 2), 1, type, tel).
expression(tel, (__and, 2)).
	arg((__and, 2), 0, type, tel).
	arg((__and, 2), 1, type, tel).
expression(tel, (__initial, 0)).
expression(tel, (__final, 0)).
expression(tel, (__next, 1)).
	arg((__next, 1), 0, type, tel).
expression(tel, (__until, 2)).
	arg((__until, 2), 0, type, tel).
	arg((__until, 2), 1, type, tel).

macro(tel, __wnext(v1), __or(__next(v1), __final)).
macro(tel, __eventually(v1), __until(__true, v1)).
macro(tel, __always(v1), __release(__false, v1)).
macro(tel, __release(v1, v2), __until(v2, __and(v2, __or(v1, __final)))).
var(tel, v1, tel).
var(tel, v2, tel).

subtype(atom, tel).
allow(tel, body).
allow(tel, head).
