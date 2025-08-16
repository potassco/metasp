#const floors=5.
floor(1..floors).

at((floors+1)/2):-initial.
called(floors):-initial.
called(1):-initial.


{wait; up ; down; serve}=1 :- not final.
:- up,   at(X), not floor(X+1).
:- down, at(X), not floor(X-1).

next(at(X+1)):- up,   at(X).
next(at(X-1)):- down, at(X).
next(at(X))  :- at(X), not up, not down, not final.
served(X) :- at(X), serve.
next(called(X)):- called(X), not served(X).

ready :- called(X), at(X).

:- called(X), final.

:- not dia(
	seq(
		star(
			seq(
				choice(star(up), star(down)) ,
				seq(
					test(ready),
					serve
				)
			)
		),
		star(wait)
	),
	final
).



_show.
_show(down):-down.
_show(up):-up.
_show(wait):-wait.
_show(serve):-serve.
_show(at(X)):-at(X).
_show(final):-final.


#external initial.
#external final.
#external wait.
#external top.
#external up.
#external down.
#external serve.
#external at(X):floor(X).
#external dia(seq(star(seq(choice(star(up),star(down)),seq(test(ready),serve))),star(wait)),final).
