a:-&final.

#show &final/0.
#show a/0.

% #TEST
% clingo --meta-config ../config.yml -c n=3
% -  true(a,3)  true(&final,3)

% #TEST
% clingo --meta-config ../config.yml -c n=5
% -  true(a,5)  true(&final,5)
