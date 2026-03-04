#type tel {
  expressions: {
    &true/0;
    &not/1: { type: tel, safety: unsafe; };
    &initial/0;
    &next/1: {
      type: tel, safety: safe;
    };
    &eventually/1: {
      type: tel, safety: safe;
    };
  };
  subtypes: { atom; };
  macros:   { &final: &not(&next(&true)); };
  occurrence: any;
}.
