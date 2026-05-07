light(l1).
red(L) :- not green(L), light(L).
&eventually(&i(10,15),green(L)):- push(L).
&next(&i(5,6),push(l1)) :- &initial.

#show push/1.
#show green/1.
% #TEST
% clingcon --meta-config ../config.yml -c n=2
%   - true(green(l1),2) true(push(l1),1) __csp(t(2),15) __csp(t(1),5) __csp(t(0),0)
%   - true(green(l1),2) true(push(l1),1) __csp(t(2),16) __csp(t(1),5) __csp(t(0),0)
%   - true(green(l1),2) true(push(l1),1) __csp(t(2),17) __csp(t(1),5) __csp(t(0),0)
%   - true(green(l1),2) true(push(l1),1) __csp(t(2),18) __csp(t(1),5) __csp(t(0),0)
%   - true(green(l1),2) true(push(l1),1) __csp(t(2),19) __csp(t(1),5) __csp(t(0),0)
