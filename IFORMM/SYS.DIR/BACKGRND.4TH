\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ BACKGRND ---- a simple background process facility

\ A background process (or BP) is one that often does long computations
\ that do not produce real-time output.
\ The Forth interpreter is an example; it might execute "fload" or "words",
\ which must not be allowed to supercede real-time computations.

\ In our approach, a BP has a fixed deadline that must be >= 7fffff00
\ (this allows different BP's to be prioritized).
\ Its time position (TP) start off at zero.
\ If a BP ever does anything "real-time", then its TP is brought up to date.
\ Specifically, if it does any of the following:
\ - schedule an event
\ - time-advance
\ - become a group using ::gp
\ and its time position is < cur-SVT, then its TP is set to cur-SVT.

\ This approach allows the Forth interpreter to generate real-time output
\ when requested (although it never gets a real-time deadline).

loaded definitions create _backgrnd
only forth also
internals also definitions ap-defs also

pquan BP-deadline				\ defaults to +infinity
th 7fffff00 constant first-BP-deadline

forth definitions

: background	(  --- ; place caller in background at its deadline )
 BP-flag execution-queue set-flag
 BP-deadline first-BP-deadline u< if
 +infinity to BP-deadline
 then
 mask-softint
 BP-deadline set-deadline*
 unmask-softint ;

: foreground
 BP-flag execution-queue clear-flag
 0 time-advance ;
