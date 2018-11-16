\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ FEVENT - future events

loaded definitions create _fevent
only forth also
internals also definitions ap-defs also

code raw-future-event		( params #params proc-addr dt --- ; )
\ this form of future-event is applicable if there are no TD's.
\ It works by putting the event record directly into the wakeup buffer.
 sp )+ d4 move
 sp )+ d3 move
 (make-action-rec)
 d3 poffset wakeup-routine a1 d) move
 addr execution-queue l#) a0 move
 poffset time-position a0 d) d4 add
 d4 poffset wakeup-time a1 d) move
 ' (rec->wakeup l#) jsr
c;

ifndef _FAQ_

realias future-event raw-future-event
ifend

: (::fev		( args nargs delay branch-addr --- ; compiled by ::ev )
 r@ @
 r> na1+ dup @ >r
 na1+
 future-event ;

ap-defs definitions

: ::fev
 compile (::fev
 here to params-addr
 true to params-OK?
 0 ,				\ nargs
 here 0 token,			\ branch address
\ What follows is the event routine machine-language preamble.
\ It is called by a jsr.  Its tasks are
\ 1) to set up the Forth registers and switch to high-level interpretation;
\ 2) to arrange for an "rts" to be done when the high-level part is done.
 [ assembler ]
 long
 temp-stack 200 + l#) rp lea	\ temporary return stack
 (forth-context)
 (record->stack)
 ' (free l#) jsr
 0 l#) ip lea			\ set up an appropriate IP
 next				\ fire up the event
 here here 8 - !		\ sleaze Louise!!
 [ current @ context ! ]
 2345				\ magic #
; immediate		\ error-checking flag
