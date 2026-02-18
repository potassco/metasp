
#type del{
  expressions: {
    &initial/0;
    &true/0;
    &false/0;
    &always/2: {
      type: path, safety: unsafe;
      type: del, safety: unsafe;
    };
    &eventually/2: {
      type: path, safety: safe;
      type: del, safety: safe;
    };
  };
  subtypes:   { atom; };
  macros:     { &final: &eventually(&step,&false); };
  occurrence: any;
}.

#type path {
  expressions: {
    &step/0;
    &test/1: { type: del, safety: safe; };
    &star/1: { type: path, safety: unsafe;};
    &choice/2: {
      type: path, safety: unsafe;
      type: path, safety: unsafe;
    };
    &seq/2: {
      type: path, safety: safe;
      type: path, safety: safe;
    };
  };
  macros: {
    a: &seq(&test(a), &step);
    where: { a: atom; };
  };
}.
