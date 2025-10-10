#const floors=5.
floor(1..floors).

at((floors+1)/2):-__initial.
called(floors):-__initial.
called(1):-__initial.


{wait; up ; down; serve}=1 :- not __final.
:- up,   at(X), not floor(X+1).
:- down, at(X), not floor(X-1).

__next(at(X+1)):- up,   at(X).
__next(at(X-1)):- down, at(X).
__next(at(X))  :- at(X), not up, not down, not __final.
served(X) :- at(X), serve.
__next(called(X)):- called(X), not served(X).


ready :- called(X), at(X).

:- called(X), __final.

:- not __dia(
	__seq(
		__star(
			__seq(
				__choice(__star(up), __star(down)) ,
				__seq(
					__test(ready),
					serve
				)
			)
		),
		__star(wait)
	),
	__final
).



_show.
_show(down):-down.
_show(up):-up.
_show(wait):-wait.
_show(serve):-serve.
_show(at(X)):-at(X).
_show(final):-final.


#external __initial.
#external __final.
#external wait.
#external __top.
#external up.
#external down.
#external serve.
#external at(X):floor(X).
#external __dia(__seq(__star(__seq(__choice(__star(up),__star(down)),__seq(__test(ready),serve))),__star(wait)),__final).
