#type bool{
    expressions: {
        &not/1 : {
            type: bool, safety: unsafe;};
        &and/2 : {
            type: bool, safety: unsafe;
            type: bool, safety: unsafe;};
        &or/2 : {
            type: bool, safety: unsafe;
            type: bool, safety: unsafe;};
        &to/2 : {
            type: bool, safety: unsafe;
            type: bool, safety: unsafe;};
    };
    subtypes:  { atom; };
    occurrence: any;
    macros:   {
        &eq(f1, f2): &and(&to(f1,f2), &to(f2,f1));
        where: { f1: bool; f2: bool; };
    };
}.
