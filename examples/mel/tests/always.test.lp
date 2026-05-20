&next(&always(&i(2,10),a)) :- &initial.
:- &initial, not &eventually(&i(1,5),&final).

% #external &always(&i(2,10),a).
% #show &always/2.
#show a/0.
% #TEST
% clingcon --meta-config ../config.yml -c n=2
% - true(a,2) __csp(t(2),3) __csp(t(1),1) __csp(t(0),0)
% - true(a,2) __csp(t(2),4) __csp(t(1),1) __csp(t(0),0)
% - true(a,2) __csp(t(2),4) __csp(t(1),2) __csp(t(0),0)
% - __csp(t(2),2) __csp(t(1),1) __csp(t(0),0)
% - __csp(t(2),3) __csp(t(1),2) __csp(t(0),0)
% - __csp(t(2),4) __csp(t(1),3) __csp(t(0),0)
