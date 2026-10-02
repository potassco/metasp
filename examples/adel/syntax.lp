
#type adel{
  expressions: {
    &sneg/1: { type: adel, safety: safe; };
    &false/0;
    &always/2: {
      type: path, safety: unsafe;
      type: adel, safety: unsafe;
    };
    &eventually/2: {
      type: path, safety: safe;
      type: adel, safety: safe;
    };
  };
  subtypes:  { fluent; };
  occurrence: any;
  macros: {
    &not(x): &always(&test(x),&false);
    &true: &sneg(&false);
    &or(x,y): &eventually(&choice(&test(x),&test(y)), &true);
    &and(x,y): &eventually(&test(x), y);
    &next(x): &eventually(&atrue, x);
    &wnext(x): &always(&atrue, x);
    &final: &always(&atrue, &false);
    &initial: &always(&conv(&atrue), &false);
    where: { x: adel; y: adel; };
  };
}.

#type path {
  subtypes: {aformula;};
  expressions: {
    &test/1: { type: adel, safety: safe;};
    &star/1: { type: path, safety: unsafe;};
    &conv/1: { type: path, safety: unsafe;};
    &choice/2: {
      type: path, safety: unsafe;
      type: path, safety: unsafe;
    };
    &seq/2: {
      type: path, safety: safe;
      type: path, safety: safe;
    };
  };
}.



#type aformula{
    subtypes: {action;};
    expressions: {
        &atrue/0;
        &aand/2: {
            type: aformula, safety: safe;
            type: aformula, safety: safe;
        };
        &aneg/1: { type: aformula, safety: safe; };
    };
    macros: {
        &afalse: &aneg(&atrue);
        &aor(x,y): &aneg(&aand(&aneg(x),&aneg(y)));
        &aimp(x,y): &aor(x,&aneg(y));
        where: { x: aformula; y: aformula; };
    };
}.

#type fluent{
    subtypes: {atom;};
}.

#type action{
    subtypes: {atom;};
}.

#type action_definition{
    expressions:{
      &action/1: { type: atom, safety: safe; };
    };
    occurrence: head;
}.
