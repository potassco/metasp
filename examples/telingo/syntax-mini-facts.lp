
% #type tel {
%     expressions: {
% 		&true/0;
% 		&initial/0;
% 		&next/1: {
% 			type: tel, safety: safe;
% 		};
% 		&until/2: {
% 			type: tel, safety: unsafe;
% 			type: tel, safety: safe;
% 		};
%     };
%     subtypes: {
% 		atom;
%     };
%     macros: {
% 		&eventually(v1): &until(&true, v1);
% 		where: {
% 			v1: tel;
% 		};
%     };
%     occurrence: any;
% }.

type(tel).
allow(tel, body).

subtype(atom, tel).
expression(tel, (__initial, 0)).
expression(tel, (__true, 0)).
expression(tel, (__next, 1)).
	arg((__next, 1), 0, type, tel).
	arg((__next, 1), 0, safety, unsafe).
expression(tel, (__until, 2)).
	arg((__until, 2), 0, type, tel).
	arg((__until, 2), 0, safety, unsafe).
	arg((__until, 2), 1, type, tel).
	arg((__until, 2), 1, safety, safe).

var(v1, tel).
macro(tel, __eventually(v1), __until(__true, v1)).
