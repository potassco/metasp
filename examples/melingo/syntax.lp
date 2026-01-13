
#type mel {
    expressions: {
	    &true/0;
        &initial/0;
        &final/0;
        &next/2: {
            type: (number, number), safety: safe;
            type: mel, safety: safe;
        };
    };
    subtypes: {
        atom;
    };
    macros: {
        &next(v1): &next(0, v1);
        where: {
            v1: mel;
        };
    };
    occurrence: any;
}.
