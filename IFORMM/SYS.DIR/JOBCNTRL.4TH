\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ JOBCNTRL -- facilities for suspending, resuming and killing processes

loaded definitions create _jobcntrl
only forth also
internals also definitions

\ Each process has a "generation #", assigned from "current-generation#",
\ when it is created.
\ The default wakeup routine kills an object if its gen# is < cur-gen#.
\ Hence an object is killed by decrementing its gen#,
\ and all objects are killed by incrementing cur-gen#.

\ Objects cannot be immediately deleted (in the wakeup routine)
\ since they may have future events to perform (e.g., note-ups).
\ Instead, we arrange for them to call active-exit,
\ which frees auxiliary processes and performs all future actions.

\ Object suspension is done using two per-process flags,
\ "suspended" and "suspend-pending".
\ The wakeup routine doesn't reinsert suspend-pending processes in the XQ.

quan current-generation#
pquan generation#

: suicide		( eventually kills its caller )
 unmask-softint
 ['] active-exit >body @ execute ;	\ active-exit is aliased; want last one

code (next
c;

code genocide		( arrange for an object and descendants to die )
\ pointer to object passed in a1
recursive
 poffset sp-save a1 d) a0 move
 ' (next l#) a2 lea
  a2 a0 ) move
 ' suicide >body l#) a2 lea
  a2 poffset ip-save a1 d) move
 group-flag # poffset flags a1 d) btst
 0<> if			\ if group, recurse
  a1 sp -) move
  poffset child a1 d) a1 move
  begin
   ' genocide l#) jsr
   a1 ) d0 move
   d0 a1 move
  0= until
  sp )+ a1 move
 then
 rts
end-code

code wakeup-process		( wakeup method for processes and groups )
\ called from software interrupt, with ptr to CB in a1
\ handles kill and suspend
 addr current-generation# l#) d0 move
 poffset generation# a1 d) d0 cmp		\ time to die?
 > if
  zombie-flag # poffset flags a1 d) btst	\ yes - already dying?
  0= if
   zombie-flag # poffset flags a1 d) bset	\ arrange for death
   ' genocide l#) jsr
  then
 then
\ if a suspension is pending, don't put it in XQ
 suspend-pending-flag # poffset flags a1 d) btst
 0= if
  ' (rec->XQ* l#) jsr
 else
\ mark it as suspended
  suspend-pending-flag # poffset flags a1 d) bclr
  suspended-flag # poffset flags a1 d) bset
 then
 rts
end-code

code wakeup-immortal-process	( another wakeup method; skips kill checks )
\ called from software interrupt, with ptr to CB in a1
 ' (rec->XQ* l#) jsr
 rts
end-code

code (resume	( CB --- ; )
\ this handles various pathological cases correctly
\ (e.g., process is resumed before suspension takes effect)
 sp )+ a1 move
\ disable interrupts in case process is still in the wakeup buffer
 (mask-softint)
 suspend-pending-flag # poffset flags a1 d) btst
 0<> if
  suspend-pending-flag # poffset flags a1 d) bclr
 else
  suspended-flag # poffset flags a1 d) btst
  0<> if
   suspended-flag # poffset flags a1 d) bclr
   addr cur-SVT l#) poffset time-position a1 d) move
   ' (arouse-process l#) jsr
  then
 then
 (unmask-softint)
c;

forth definitions

: immortal
 ['] wakeup-immortal-process to wakeup-routine ;

: kill		( ID --- ; )
 id->cb ?dup if
  dup pget generation# 1- swap pto generation#
 then ;

: kill-all	( --- ; kill all mortals )
 current-generation# 1+ dup to generation# to current-generation# ;

\ can only be done to top-level objects.
\ doesn't do their pending future actions if using FAQ.
: suspend	( ID --- ; )
 id->cb ?dup if
   suspend-pending-flag swap set-flag
 then ;

: resume	( ID --- ; )
 id->cb ?dup if (resume then ;

code suspend-me         ( --- ; only call from top-level processes!!)
 (mask-softint)
 addr who l#) a1 move
 suspended-flag # poffset flags a1 d) bset
 a1 ) addr execution-queue l#) move
 ' (switch-to-XQ* l#) jsr
 (unmask-softint)
c;
