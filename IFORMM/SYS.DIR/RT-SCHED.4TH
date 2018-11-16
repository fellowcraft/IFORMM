\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ RT-SCHED --- words to create, schedule and synchronize real-time processes.

loaded definitions create _rt-sched
only forth also internals also ap-defs also

internals definitions

code RT-awaken			( CB --- ; )
\ start up a sleeping or newly-created process (or group, I guess)
\ called from process level
 sp )+ a1 move
 (mask-softint)
 ' (rec->XQ* l#) jsr
 ' (switch-to-XQ* l#) jsr
 (unmask-softint)
c;

realias awaken RT-awaken

code (RT-active-exit		( --- ; eliminate calling process )
 (mask-softint)
 addr who l#) a1 move
 a1 ) addr execution-queue l#) move		\ unlink process
 ' (free l#) jsr
 ' (switch-to-XQ* l#) jsr
end-code

: RT-active-exit	\ must be high-level
 who fin-active
 (RT-active-exit ;

realias active-exit RT-active-exit

: active-create			( --- CB ; )
\ create an active process, but don't schedule it anywhere
\ must still push initial CFA on stack
 cbsize malloc
 dup init-active ;

code process-XQH-delay*		( --- ; )
\ The XQH has an unprocessed delay.
\ - add delay to time position
\ - unlink from XQ
\ - recompute deadline and wakeup time
\ - move to the WQ or XQ as appropriate

\ This may be called by a process within the XQ head hierarchy
\ (e.g. by GP-time-advance)
 addr execution-queue l#) a1 move	\ XQH in a1
 a1 ) addr execution-queue l#) move	\ unlink XQH
 BP-flag # poffset flags a1 d) btst 	\ background process?
 0= if					\ no---set deadline
  poffset time-position a1 d) d1 move
  poffset mindel a1 d) d1 sub		\ deadline = TP - mindel
  d1 poffset deadline a1 d) move
 else					\ yes --- check TP
  poffset time-position a1 d) d0 move
  addr cur-SVT l#) d0 cmp		\ TP < System Virtual Time?
  u< if 				\ yes --- set TP = SVT
   addr cur-SVT l#) poffset time-position a1 d) move
  then
 then

 poffset time-position a1 d) d0 move	\ TP += delay
 poffset delay a1 d) d0 add
 d0 poffset time-position a1 d) move
 poffset maxdel a1 d) d0 sub		\ wakeup time is TP - maxdel
 d0 poffset wakeup-time a1 d) move
 addr cur-SVT l#) d0 cmp
 u> wif
  ' (rec->wakeup l#) jsr	\ if wakeup time is in future, put to sleep
 welse
  ' (rec->XQ* l#) jsr		\ else keep it in execution queue
 wthen
c;

: RT-time-advance	( delay --- ; )
 to delay
ifdef _AUX_
 delay addr internal-time +!
 delay if who do-aux then
ifend
 mask-softint
 process-XQH-delay*
 switch-to-XQ*
 unmask-softint ;

realias time-advance RT-time-advance

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
