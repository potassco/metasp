
% #type tel {
%     expressions: {
% 	    &true/0;
%         &initial/0;
%         &next/1: {
%             type: tel;
%         };
%         &eventually/1: {
%             type: tel;
%         };
%     };
%     subtypes: { atom; };
%     occurrence: any;
% }.


type(tel).

expression(tel, (__initial, 0)).
expression(tel, (__true, 0)).
expression(tel, (__next, 1)).
	arg((__next, 1), 0, type, tel).
expression(tel, (__eventually, 1)).
	arg((__eventually, 1), 0, type, tel).

subtype(function, tel).
allow(tel, body).
allow(tel, head).

