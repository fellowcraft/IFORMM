\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ FAQ -- words for scheduling future actions in the presence of TD's.
\ This requires maintaining a queue of future actions.
\ The future action record format is in "process"

loaded definitions create _faq
only forth also
ap-defs also internals also definitions

ifdef _GROUP_		\ for recompilation
 realias time-advance gp-time-advance
 realias active-exit gp-active-exit
otherwise
 realias time-advance RT-time-advance
 realias active-exit RT-active-exit
ifend

pquan faq		\ points to head of future action queue

: FAQ-future-event ( args nargs CFA delay --- ; schedule event for later )
 >r >r make-action-rec
 event-flag over set-flag
 r> over pto wakeup-routine
 r> internal-time + over pto time-position
 faq insert-time-position to faq ;

realias future-event FAQ-future-event

ap-defs definitions

: future-routine  ( args nargs CFA delay --- ; schedule future routine )
 >r >r make-action-rec
 event-flag over clear-flag
 r> over pto wakeup-routine
 r> internal-time + over pto time-position
 faq insert-time-position to faq ;

: do-action		( rec-ptr --- ; process an action record )
 event-flag over test-flag if
  execution-queue pget external-time over pto wakeup-time
  rec->wakeup				\ insert event record
 else
  >r
  r@ record->stack		\ move parameters from record to data stack
  r@ pget wakeup-routine execute	\ do it
  r> free
 then ;

internals definitions

: FAQ-time-advance	( delay --- ; )
 internal-time +
 begin					\ end-time on stack
  faq ?dup if				\ any more actions?
   pget time-position			\ yes
   over u> if				\ is it after end time?
    internal-time - time-advance exit	\ yes - advance to end
   else
    faq pget time-position
    internal-time - time-advance	\ no - advance to its position
    faq dup pget next-proc to faq	\ remove it from queue
    do-action				\ do it
   then
  else					\ no more actions - advance to end
   internal-time - time-advance exit
  then
 again ;

realias time-advance FAQ-time-advance

: perform-all
 begin				\ make sure all future actions get done
  faq
 while
  faq pget time-position
  internal-time - time-advance
 repeat ;

: FAQ-active-exit
 perform-all			\ make sure all future actions get done
 active-exit ;

realias active-exit FAQ-active-exit
