#type upper_bound {
   subtypes: {
       number;
       supremum;
   };
}.
#type interval {
    expressions: {
        &i/2: {
            type: number, safety: unsafe;
            type: upper_bound, safety: unsafe;
        };
    };
}.
#type mel {
    expressions: {
	    &top/0;
	    &bottom/0;
        &initial/0;
        &final/0;
        &next/2: {
            type: interval, safety: unsafe;
            type: mel, safety: safe;
        };
        &eventually/2: {
            type: interval, safety: unsafe;
            type: mel, safety: safe;
        };
        &always/2: {
            type: interval, safety: unsafe;
            type: mel, safety: unsafe;
        };
    };
    subtypes: {
        atom;
    };
    macros: {
        &next(v1): &next(&i(0, #sup), v1);
        where: {
            v1: mel;
        };
    };
    occurrence: any;
}.
