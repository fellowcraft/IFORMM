\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ EXECUTE -- low-level words involving the execution queue (XQ):
\	a deadline-sorted queue of runnable processes and groups
\ The only things that modify the XQ are:
\ 1) process level (must mask software interrupts)
\ 2) the software interrupt routine, which is non-reentrant and therefore
\    does not have to mask interrupts while modifying the XQ

loaded definitions create _execute
only forth also
internals also definitions

quan execution-queue		\ priority queue for processes

code (switch-to-XQ*
\ context switch to head of XQ.
\ Call only from process level by jsr (to save PC).

 addr execution-queue l#) a2 move	\ XQH in a2
 poffset first-descendant a2 d) a0 move	\ new CB in a0
 addr who l#) d0 move			\ same as current process?
 a0 d0 cmp
 0<> wif					\ no - must switch
  (save-forth-state*)
  preempted-flag # poffset flags a2 d) btst	\ preempted?
  0= wif
   (restore-forth-state*)
   rts					\ resume non-preempted process
  welse
   preempted-flag # poffset flags a2 d) bclr
   poffset preempted-CB a2 d) a0 move
   (restore-machine-state*)
   (unmask-softint)
ifdef MAC
   rts
ifend
ifdef ATARI
   rte
ifend
  wthen
 welse
  rts					\ resume this process
 wthen
end-code

code switch-to-XQ*
 ' (switch-to-XQ* l#) jsr
c;

code (rec->XQ*		( record-ptr --- ; schedule record for execution )
\ called only from process level (by RT-time-advance, advance-XQH, awaken)
\ input: record ptr in a1
 addr execution-queue l#) a0 move
 ' (insert-deadline l#) jsr
 a0 addr execution-queue l#) move
 rts
end-code

code (set-deadline*    \ new deadline is in d0 to start with
 addr execution-queue l#) a1 move
 d0 poffset deadline a1 d) move
 a1 ) a0 move
 ' (insert-deadline l#) jsr
 a0 addr execution-queue l#) move
 ' (switch-to-XQ* l#) jsr
 rts
end-code

code set-deadline*		( n --- set our deadline to n )
 sp )+ d0 move
 ' (set-deadline* l#) jsr
c;
