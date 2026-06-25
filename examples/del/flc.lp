% ----------------------------
%## Fischer-Ladner closure

%### Eventually
formula(del, &eventually(P,&eventually(&star(P),F))) :- formula(del, &eventually(&star(P),F)).
formula(del, &eventually(P1,F)) :- formula(del, &eventually(&choice(P1,P2),F)).
formula(del, &eventually(P2,F)) :- formula(del, &eventually(&choice(P1,P2),F)).
formula(del, &eventually(P1,&eventually(P2,F))) :- formula(del, &eventually(&seq(P1,P2),F)).
formula(del, &eventually(P2,F)) :- formula(del, &eventually(&seq(P1,P2),F)).

%### Always
formula(del, &always(P,&always(&star(P),F))) :- formula(del, &always(&star(P),F)).
formula(del, &always(P1,F)) :- formula(del, &always(&choice(P1,P2),F)).
formula(del, &always(P2,F)) :- formula(del, &always(&choice(P1,P2),F)).
formula(del, &always(P1,&always(P2,F))) :- formula(del, &always(&seq(P1,P2),F)).
formula(del, &always(P2,F)) :- formula(del, &always(&seq(P1,P2),F)).
