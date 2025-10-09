type(mel).
subtype(atom, mel).

type(omega).
constructor(omega, w, 0, ()).



constructor(mel, initial, 0, ()).
constructor(mel, final, 0, ()).

constructor(mel, next, 2, ((num,num),mel)).

% constructor(mel, next, 2).
    % constructor(mel, next, 0, (num,num),safe).
    % constructor(mel, next, 0, mel,safe).

constructor(mel, next, 2, ((num,omega),mel)).

constructor(mel, eventually, 2, ((num,atom),mel)).
constructor(mel, always, 2, ((num,atom),mel)).

allow(mel, body;head).

arg(mel, (next;eventually;always), 1, unsafe).
