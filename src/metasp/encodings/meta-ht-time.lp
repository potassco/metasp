time(0..n).

% h and t are classical models s.t. h \subseteq t

model(h). model(t).

% define atoms
atom( A ) :- atom_tuple(_,A).
atom(|L|) :-          literal_tuple(_,L).
atom(|L|) :- weighted_literal_tuple(_,L,_).


{ hold(A,t,T) } :- atom(A), time(T).
:- hold(L,h,T), not hold(L,t,T), time(T).

% option = 2 simply does not open hold(L,h)

% option = 3

:- not hold(L,h,T), hold(L,t,T), time(T).


%
% t is a classical model, and
% h is a classical model of the reduct wrt. t
%

conjunction(B,M,T) :- model(M), literal_tuple(B), time(T),
        hold(L,M,T) : literal_tuple(B, L), L > 0;
    not hold(L,t,T) : literal_tuple(B,-L), L > 0.

body(normal(B),M,T) :- rule(_,normal(B)), conjunction(B,M,T).
body(sum(B,G),M,T)  :- model(M), rule(_,sum(B,G)), time(T),
    #sum { W,L :     hold(L,M,T), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : not hold(L,t,T), weighted_literal_tuple(B,-L,W), L > 0 } >= G.

               hold(A,M,T) :  atom_tuple(H,A)   :- rule(disjunction(H),B), body(B,M,T).
hold(A,M,T); not hold(A,t,T) :- atom_tuple(H,A),     rule(     choice(H),B), body(B,M,T).


% True if the literal tuple for the output holds
true(O,M,T) :- output(O,B), time(T), model(M), hold(L,M,T) : literal_tuple(B,L).
% If a formula its true, its literal holds
hold(L,M,T) :- output(O,B), time(T), model(M), true(O,M,T),  literal_tuple(B,L).
