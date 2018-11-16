\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ SEMAPHOR --- binary semaphores with a deadline scheduling twist.
\ Binary semaphores protect a resource (e.g. the right to execute a
\ piece of code) that only one process at a time can hold.
\ If a process A tries to acquire a resource held by process B,
\ the deadline of process B is moved back that of process A,
\ to allow it to execute and release the resource.
\ When process B finishes with the resource, it resumes its original deadline.
\ Modified by RKV so that a process can nest P's and V's of the
\ same semaphor.  This is useful for some of the toolbox synchronization
\ techniques used for the Macintosh.

\ IMPORTANT RULE: you aren't allowed to sleep or time-advance
\ while you hold a semaphore.

\ A semaphore is implemented as a record containing the following:
\ holder-CB		(zero if free)
\ holder-deadline	(deadline when it first acquired the semaphore)
\ holder-count		(how many times has the current process P'd it

loaded definitions create _semaphor
only forth also
internals also definitions ap-defs also

0 constant holder-CB
4 constant holder-deadline
8 constant holder-count

forth definitions

: semaphore:
 create 0 , 0 , 0 , ;

: init-sema		( semaphore-addr --- ; )
 dup off na1+ dup off na1+ off ;

\ note: references to the caller are made through execution queue
\ rather than "who".
\ This will make it possible for group processes to use the same
\ routines without pain and suffering.

defer P		\ request resource
defer V		\ release resource

internals definitions

:cm (make-XQ-head*)		( --- ; )
\ CB is in a0
\ change the process's deadline to that of the XQ head.
 addr execution-queue l#) a1 move
 a1 d1 move
 begin					\ look for proc in XQ
  poffset next-proc a1 d) d0 move	\ get next CB in execution queue
  a0 d0 cmp				\ is it the one we want?
 0<> while
  poffset next-proc a1 d) a1 move	\ no, on to the next
 repeat
 poffset next-proc a0 d) poffset next-proc a1 d) move  \ unlink new-qhead
 d1 a1 move
 poffset deadline a1 d) poffset deadline a0 d) move    \ put it in front 
 a1 poffset next-proc a0 d) move
 a0 addr execution-queue l#) move
;cm

:cm (P)	  ( semaphore-addr --- ; )
 (mask-softint)
 sp ) a0 move
 holder-CB a0 d) d0 move
 addr who l#) d0 cmp

\ if this process already owns semaphore, just bump count

 0= wif
  sp )+ a0 move		\ need to pop semaphor off stack
  1 holder-count a0 d) addq
 welse
  d0 tst

\ if some other process owns it, promote that process

  0<> wif
   d0 a0 move
   (make-XQ-head*)
   ['] (switch-to-XQ* l#) jsr
  wthen

\ if nobody owns it, grab it for ourself.

  sp )+ a0 move
  addr execution-queue l#) a1 move
  a1 holder-CB a0 d) move
  poffset deadline a1 d) holder-deadline a0 d) move
 wthen
 (unmask-softint) ;cm

code (P		( semaphore-addr --- ; )
 (P)
c;

:cm (V)		( semaphore-addr --- ; )
 (mask-softint)
 sp )+ a0 move
 holder-count a0 d) tst
 0<> wif

\ if this process has "nested" ownership, just dec the count

  1 holder-count a0 d) subq
 welse

\ if count is down to zero, demote ourself if needed

  holder-CB a0 d) clr
  holder-deadline a0 d) d0 move
  addr execution-queue l#) a1 move
  poffset deadline a1 d) d0 cmp
  0<> wif
   ['] (set-deadline* l#) jsr
  wthen
 wthen
 (unmask-softint)
;cm

code (V
 (V)
c;

: +semaphore
 ['] (P is P
 ['] (V is V ;

: -semaphore
 ['] drop is P
 ['] drop is V ;

-semaphore 
