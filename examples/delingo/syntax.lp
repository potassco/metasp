modality(del, atom).
modality(del, box, 2, (path,del)).
modality(del, dia, 2, (path,del)).
modality(del, top, 0, ()).
modality(del, bot, 0, ()).


modality(path, step, 0, ()).
modality(path, test, 1, (del,)).
modality(path, choice, 2, (path, path)).
modality(path, seq, 2, (path, path)).
modality(path, star, 1, (path,)).
modality(path, converse, 1, (path,)).

modality(del, final, 0, ()). %Derived
modality(path, atom, 0, ()). %Derived to avoid the a?;t

occurence(del, body).
