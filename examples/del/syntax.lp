% #type path {
%     expressions: {
%         &step/0;
%         &test/1: {
%             type: del;
%         };
%         &choice/2: {
%             type: path;
%             type: path;
%         };
%         &seq/2: {
%             type: path;
%             type: path;
%         };
%         &star/1: {
%             type: path;
%         };
%     };
%     macros: {
%         a: &seq(&test(a), &step);
%         where: {
%             a: atom;
%         };
%     };
% }.

% #type del{
%     expressions: {
%         &top/0;
%         &bot/0;
%         &box/2: {
%             type: path;
%             type: del;
%         };
%         &dia/2: {
%             type: path;
%             type: del;
%         };
%     };
%     subtypes: {
%         atom;
%     };
%     occurrence: any;
% }.



type(del).
allow(del, head).
allow(del, body).

expression(del, (__box, 2)).
    arg((__box, 2), 0, type, path).
    arg((__box, 2), 1, type, del).
expression(del, (__dia, 2)).
    arg((__dia, 2), 0, type, path).
    arg((__dia, 2), 1, type, del).
expression(del, (__top, 0)).
expression(del, (__bot, 0)).

type(path).
subtype(atom, del).
expression(path, (__step, 0)).
expression(path, (__test, 1)).
    arg((__test, 1), 0, type, del).
expression(path, (__choice, 2)).
    arg((__choice, 2), 0, type, path).
    arg((__choice, 2), 1, type, path).
expression(path, (__seq, 2)).
    arg((__seq, 2), 0, type, path).
    arg((__seq, 2), 1, type, path).
expression(path, (__star, 1)).
    arg((__star, 1), 0, type, path).

var(path, a, atom).
macro(path, a, __seq(__test(a), __step)).
