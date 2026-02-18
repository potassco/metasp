#type tel {
  expressions: {
    &true/0;
    &initial/0;
    &next/1: {
      type: tel, safety: safe;
    };
    &eventually/1: {
      type: tel, safety: safe;
    };
  };
  subtypes: { atom; };
  occurrence: any;
}.
