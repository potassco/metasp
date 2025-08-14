modality(mel, atom).
modality(mel, initial, 0, ()).
modality(mel, final, 0, ()).

modality(mel, next, 2, ((num,num),mel)).
modality(mel, next, 2, ((num,fixed(w)),mel)).
% modality(mel, next, 2, ((num,atom),mel)).

modality(mel, eventually, 2, ((num,atom),mel)).
modality(mel, always, 2, ((num,atom),mel)).

occurence(mel, body;head).

arg(mel, (next;eventually;always), 1, unsafe).
