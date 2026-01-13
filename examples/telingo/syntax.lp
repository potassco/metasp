
#type tel {
    expressions: {
	    &true/0;
        &initial/0;
        &next/1: {
            type: tel, safety: safe;
        };
        &until/2: {
            type: tel, safety: unsafe;
            type: tel, safety: safe;
        };
    };
    subtypes: {
        atom;
    };
    macros: {
    	&eventually(v1): &until(&true, v1);
    	where: {
	        v1: tel;
	    };
    };
    occurrence: any;
}.
