type(del).
type(path).
subtype(atom, del).


constructor(del, box, 2, (path,del)).
constructor(del, dia, 2, (path,del)).
constructor(del, top, 0, ()).
constructor(del, bot, 0, ()).


constructor(path, step, 0, ()).
constructor(path, test, 1, (del,)).
constructor(path, choice, 2, (path, path)).
constructor(path, seq, 2, (path, path)).
constructor(path, star, 1, (path,)).
constructor(path, converse, 1, (path,)).


% Derived
constructor(del, final, 0, ()).
subtype(path, atom).

allow(del, body).
