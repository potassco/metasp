% Example from
% Theorem Proving for Pointwise Metric Temporal Logic Over the Naturals via Translations
% Ullrich Hustadt et al

% !!! note Version with multiple robots

lazyness(r1, (1,5)).
lazyness(r2, (5,10)).
lazyness(r3, (1,2)).

% ## Adjustments for finite length traces

% Limit the max timing (a horizon larger than 20 will break it, needed to not enumerate all in clingcon)
eventually((0,20),final):- initial.

% to avoid loops i need a further initial constraint, otherwise it will need an infinite length trace
{next((1,w),resting(R));next((1,w),leavingHome(R))} :- resting(R), initial.

% Not needed because they only rest at the start
% next((1,w), start_resting(R)) :- not resting(R), next(((1,w),resting(R))).
start_resting(R) :- initial, resting(R).
% not_resting(R):-not resting(R), robot(R).
eventually(I, leavingHome(R)):-start_resting(R), lazyness(R, I).


robot(r1).
robot(r2).
robot(r3).
% ## Initial state
resting(R) :- initial, robot(R).

% ## Transitions

eventually((2,3),randomWalk(R)) :- leavingHome(R).
{eventually((1,w),homing(R));eventually((1,w),moveToFood(R))}=1 :- randomWalk(R).
{eventually((1,w),grabFood(R));eventually((1,w),homing(R));eventually((1,w),scanArena(R))}=1 :- moveToFood(R).
{eventually((1,w),randomWalk(R));eventually((1,w),moveToFood(R));eventually((1,w),homing(R))}=1 :- scanArena(R).
eventually((2,3),moveToHome(R)):-grabFood(R).
eventually((1,15),deposit(R)):-moveToHome(R).
eventually((3,4),resting(R)):-deposit(R).
eventually((1,15),resting(R)):-homing(R).


% ## Show statements

_show.
_show(start_resting(R)):-start_resting(R).
_show(resting(R)):-resting(R).
_show(leavingHome(R)):-leavingHome(R).
_show(randomWalk(R)):-randomWalk(R).
_show(searching):-searching.
_show(homing(R)):-homing(R).
_show(moveToFood(R)):-moveToFood(R).
_show(scanArena(R)):-scanArena(R).
_show(grabFood(R)):-grabFood(R).
_show(moveToHome(R)):-moveToHome(R).
_show(deposit(R)):-deposit(R).

% ## Externals (for all temporal atoms in the bodies)

#external start_resting(R):robot(R).
#external resting(R):robot(R).
#external initial.
#external final.
#external leavingHome(R):robot(R).
#external randomWalk(R):robot(R).
#external scanArena(R):robot(R).
#external moveToFood(R):robot(R).
#external grabFood(R):robot(R).
#external moveToHome(R):robot(R).
#external deposit(R):robot(R).
#external homing(R):robot(R).
