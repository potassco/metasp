#type path {
    expressions: {
        &step/0;
        &test/1: {
            type: del;
        };
        &choice/2: {
            type: path;
            type: path;
        };
        &seq/2: {
            type: path;
            type: path;
        };
        &star/1: {
            type: path;
        };
    };
    macros: {
        a: &seq(&test(a), &step);
        where: {
            a: function;
        };
    };
}.

#type del{
    expressions: {
        &top/0;
        &bot/0;
        &box/2: {
            type: path;
            type: del;
        };
        &dia/2: {
            type: path;
            type: del;
        };
    };
    subtypes: {
        function;
    };
    occurrence: any;
}.
