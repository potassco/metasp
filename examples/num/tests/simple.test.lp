&lt(a,b).
&range(1,4,a).
&range(1,4,b).

% #TEST
%   flingo --meta-config ../config.yml --const n=0
% - __csp(b,2) __csp(a,1)
% - __csp(b,3) __csp(a,1)
% - __csp(b,4) __csp(a,1)
% - __csp(b,3) __csp(a,2)
% - __csp(b,4) __csp(a,2)
% - __csp(b,4) __csp(a,3)
