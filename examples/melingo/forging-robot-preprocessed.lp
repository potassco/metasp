% Example from
% Theorem Proving for Pointwise Metric Temporal Logic Over the Naturals via Translations
% Ullrich Hustadt et al



% ## Adjustments for finite length traces

% Limit the max timing (a horizon larger than 20 will break it, needed to not enumerate all in clingcon)
eventually((0,20),final):- initial.
% to avoid loops i need a further initial constraint, otherwise it will need an infinite length trace
next((1,5),leavingHome) :- resting, initial.


% ## Initial state
resting :- initial.

% ## Transitions

next((2,3),randomWalk) :- leavingHome.
{next((1,w),homing);next((1,w),moveToFood)}=1 :- randomWalk.
{next((1,w),grabFood);next((1,w),homing);next((1,w),scanArena)}=1 :- moveToFood.
{next((1,w),randomWalk);next((1,w),moveToFood);next((1,w),homing)}=1 :- scanArena.
next((2,3),moveToHome):-grabFood.
next((1,15),deposit):-moveToHome.
next((3,4),resting):-deposit.
next((1,15),resting):-homing.


% ## Show statements

_show.
_show(resting):-resting.
_show(leavingHome):-leavingHome.
_show(randomWalk):-randomWalk.
_show(searching):-searching.
_show(homing):-homing.
_show(moveToFood):-moveToFood.
_show(scanArena):-scanArena.
_show(grabFood):-grabFood.
_show(moveToHome):-moveToHome.
_show(deposit):-deposit.
_show(testing):-testing.

% ## Externals (for all temporal atoms in the bodies)

#external resting.
#external initial.
#external final.
#external leavingHome.
#external randomWalk.
#external scanArena.
#external moveToFood.
#external grabFood.
#external moveToHome.
#external deposit.
#external homing.
