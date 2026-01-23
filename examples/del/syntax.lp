
% #type del{
%     expressions: {
%         &true/0;   &false/0;
%         &always/2: { type: path; type: del; };
%         &eventually/2: { type: path; type: del;}; };
%     subtypes:   { atom; };
%     macros:     { &final: &box(&step,&bot); };
%     occurrence: any;
% }.

% #type path {
%     expressions: {
%         &step/0;
%         &test/1: { type: del; };
%         &star/1: { type: path; };
%         &choice/2: { type: path; type: path; };
%         &seq/2: { type: path; type: path; }; };
%     macros: {
%         a: &seq(&test(a), &step);
%         where: { a: atom; };
%     };
% }.




type(del).
allow(del, head).
allow(del, body).

expression(del, (__always, 2)).
    arg((__always, 2), 0, type, path).
    arg((__always, 2), 1, type, del).
expression(del, (__eventually, 2)).
    arg((__eventually, 2), 0, type, path).
    arg((__eventually, 2), 1, type, del).
expression(del, (__true, 0)).
expression(del, (__false, 0)).

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
macro(del, __final, __always(__step,__false)).
