#type tel_until {
    expressions: {
        &until/2: {
            type: tel, safety: unsafe;
            type: tel, safety: safe;
        };
    };
    macros: {
    	&eventually(v1): &until(&true, v1);
    	where: {
	        v1: tel;
	    };
    };
    occurrence: body;
}.


#type tel {
    expressions: {
	    &true/0;
        &initial/0;
        &next/1: {
            type: tel, safety: safe;
        };
    };
    subtypes: {
        atom;
        tel_until;
    };
    occurrence: any;
}.
