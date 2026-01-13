% What about conditionals?
% % :- a: &eventually(a) Can we do this? is it then body or head?
% HEAD_ATOM :: DEL
% BODY_ATOM :: DEL

% DEL:: ATOM | box PATH DEL | dia PATH DEL | top | bot
% PATH:: step | test DEL | choice PATH PATH | seq PATH PATH | star PATH

% a:= ATOM
% a:PATH = &seq(&test (a), &step)

% % boxAtom :: String -> Formula -> Formula
% % Not good because it would not replace in [a;b]f, since it does not match
% a:= ATOM
% f:= DEL
% &box a f = &box (&seq(&test (a), &step)) f


type(del).
allow(del, head).
allow(del, body).

type(path).
subtype(function, del).
% subtype(atom, path).

expression(del, (__box, 2)).
    arg((__box, 2), 0, type, path).
    arg((__box, 2), 1, type, del).
expression(del, (__dia, 2)).
    arg((__dia, 2), 0, type, path).
    arg((__dia, 2), 1, type, del).
expression(del, (__top, 0)).
expression(del, (__bot, 0)).
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

% Derived We need this in the grammar to parse the input
%% ------- Derived --------- %%

var(a, function).
macro(path, a, __seq(__test(a), __step)).



% #type del{
%     expressions: {
%         &top/0;
%         &bot/0;
%         &box/2:     {
%             type: path;
%             type: del;
%         }

%         ;
%     }
% }
