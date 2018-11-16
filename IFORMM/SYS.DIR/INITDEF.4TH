\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ INITDEF -- definitions of initialization and finalization routines.

\ all top-level words in this file take a CB and return nothing.
\ all macros expect a CB in a0 and who in a1

loaded definitions create _initdef
only forth also
ap-defs also internals also definitions
ifdef MAC
windows also
ifend

:cm (init-process)
\ initialization for all processes
 poffset dstack a0 d) a2 lea		\ initialize d, r stacks to empty
 a2 poffset sp-save a0 d) move
 poffset rstack a0 d) a2 lea
 a2 poffset rp-save a0 d) move
 poffset flags a0 d) clr
 poffset name a0 d) clr
 -1 d0 moveq
 d0 poffset id a0 d) move
ifdef _RATIONAL_
 th 8000 l# poffset error a0 d) move	\ rational scaling error = .5
ifend
;cm

code ((init-active		\ for active processes
\ the following pquans are NOT initialized here,
\ and must be initialized in the process creation construct
\ (see ::ap-init-active and ::gp-init-active)

\ time-position (==external-time if _AUX_)
\ internal-time (if _AUX_)
\ deadline
\ parent (if _GROUP_)
\ maxdel, mindel
\ global-ptr (if _AUX_)
\ wakeup-routine

 sp )+ a0 move
 addr who l#) a1 move
ifdef MAC
 poffset my-wdp a1 d) poffset my-wdp a0 d) move        \ inherit window data pointer
ifend
 (init-process)
ifdef _TOOLBOX_
 poffset proc-grafport a1 d) poffset proc-grafport a0 d) move
 poffset proc-sp a0 d) clr
ifend
 poffset generation# a1 d) poffset generation# a0 d) move
 a0 poffset first-descendant a0 d) move
ifdef _AUX_
 a0 poffset local-ptr a0 d) move	\ local context is itself
 poffset sh1cb a0 d) clr
 poffset sh2cb a0 d) clr
 poffset td1cb a0 d) clr
 poffset td2cb a0 d) clr
 poffset ashcb a0 d) clr
 poffset tsgcb a0 d) clr
ifend
ifdef _FAQ_
 poffset faq a0 d) clr
ifend
ifdef _RATIONAL_
  poffset rscale a0 d) a2 lea	\ rscale-ptr points to proc's own rscale
  a2 poffset rscale-ptr a0 d) move
  poffset rscale a1 d) poffset rscale d0 d) move
ifend
ifdef _TIMEBOUND_
 poffset max-stack a0 d) clr
 poffset min-stack a0 d) clr
ifend
ifdef _PTCHNAME_
 60 d0 moveq
 d0 poffset octave-offset a0 d) move
ifend
ifdef _DOLLAR_
 -10 d0 moveq
 d0 poffset needparams a0 d) move
 d0 poffset $cvolume a0 d) move
 poffset $transpose a1 d) poffset $transpose a0 d) move
 poffset $volume a1 d) poffset $volume a0 d) move
 poffset $channel a1 d) poffset $channel a0 d) move
 ifdef _SM_
 poffset $pitch-convert a1 d) poffset $pitch-convert a0 d) move
 ifend
ifend
ifdef _TUNING_
 poffset tsptr a1 d) poffset tsptr a0 d) move
 poffset tbase a1 d) poffset tbase a0 d) move
 poffset tcenter a1 d) poffset tcenter a0 d) move
ifend
c;

: (init-active
 dup ((init-active
 ['] active-exit >body @ >body		\ get the high-level word
 over tor				\ make sure process exits gracefully
 drop ;

' (init-active is init-active

code (init-passive
 sp )+ a0 move
 addr who l#) a1 move
ifdef MAC
 poffset my-wdp a1 d) poffset my-wdp a0 d) move        \ inherit window data pointer
ifend
 (init-process)
ifdef _RATIONAL_
 poffset rscale a1 d) a2 lea
 a2 poffset rscale-ptr a0 d) move
 poffset rscale-ptr a1 d) poffset rscale-ptr a0 d) move
ifend
c;

' (init-passive is init-passive

: (fin-active
 dup pget id free-id
ifdef _AUX_
 dup (clear-aux
ifend
ifdef _TIMEBOUND_
 dup free-timebnd-stacks
ifend
 drop ;

' (fin-active is fin-active
