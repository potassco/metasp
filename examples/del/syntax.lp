
#type del{
  expressions: {
    &always/2: {
      type: path, safety: unsafe;
      type: del, safety: unsafe;
    };
    &eventually/2: {
      type: path, safety: safe;
      type: del, safety: safe;
    };
  };
  subtypes:  { tel; };
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
