#type linear_term_elem{
    expressions:{
        &times_next/3: {
            type: number, safety: unsafe;
            type: number, safety: unsafe;
            type: atom, safety: unsafe;
        };
    };
    macros: {
        &next(n,v1): &times_next(1, n, v1);
        &next(v1): &times_next(1, 1, v1);
        v1: &times_next(1, 0, v1);
        n: &times_next(n, 0, _one);
        where: {
            n: number;
            v1: atom;
        };
  };
}.
#type linear_term{
    expressions:{
        &add/2: {
            type: linear_term_elem, safety: unsafe;
            type: linear_term_elem, safety: unsafe;
        };
    };
    macros: {
        v1: &add(0, v1);
        n: &add(0, n);
        lte: &add(0, lte);
        where: {
            n: number;
            v1: atom;
            lte: linear_term_elem;
        };
    };
}.

% #type opname {
%     expressions: {
%         &oplt/0; &opeq/0; &opneq/0; &opleq/0;
%     };
% }.

#type thtc_assign {
    expressions: {
        &assign/2: {
            type: linear_term_elem, safety: unsafe;
            type: linear_term, safety: unsafe;
        };
    };
    occurrence: head;
}.

#type thtc {
    expressions: {
        &neq/2: {
            type: linear_term, safety: unsafe;
            type: linear_term, safety: unsafe;
        };
        &lt/2: {
            type: linear_term, safety: unsafe;
            type: linear_term, safety: unsafe;
        };
        &leq/2: {
            type: linear_term, safety: unsafe;
            type: linear_term, safety: unsafe;
        };
    };
    occurrence: body;
}.


#type tel {
  expressions: {
    &initial/0;
    &final/0;
    &next_tel/1: {
      type: tel, safety: safe;
    };
  };
  subtypes: { atom; };
  occurrence: any;
}.




% Susana there is an issue if I do. Variables of base type dont apply macros
        % &lt(v1,v2): &op(&oplt, v1, v2);
        % &eq(v1,v2): &op(&opeq, v1, v2);
        % &neq(v1,v2): &op(&opneq, v1, v2);
        % &leq(v1,v2): &op(&opleq, v1, v2);

% Infinite recursion:
% &assign(&next(s), s):- not &op(&opneq, &next(s),s).
%
