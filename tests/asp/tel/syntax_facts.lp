type(tel).
expression(tel,(__true,0)).
expression(tel,(__not,1)).
expression(tel,(__initial,0)).
expression(tel,(__next,1)).
expression(tel,(__eventually,1)).
arg((__not,1),0,type,tel).
arg((__not,1),0,safety,unsafe).
arg((__next,1),0,type,tel).
arg((__next,1),0,safety,safe).
arg((__eventually,1),0,type,tel).
arg((__eventually,1),0,safety,safe).
subtype(atom,tel).
allow(tel,head).
allow(tel,body).
macro(tel, __final, __not(__next(__true))).