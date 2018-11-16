\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ EVENT --- words for scheduling real time events.

loaded definitions create _event
only forth also
internals also ap-defs also definitions

\ There are two ways to define event performance routines:
\ 1) as a code word, called by jsr with a pointer to the event record
\   (see PROC-CB) in a1.  These routines can trash all regs except a7.
\ 2) as a high-level Forth definitions using ::ev ... ;;ev

code event-rec		( args #args proc-addr --- rec ; )
\ Schedule an event with a code word performance routine.
\ args and #args are passed in the event record.
\ proc-addr points to the performance routine.
 sp )+ d3 move
 (make-action-rec)
 d3 poffset wakeup-routine a1 d) move
 addr execution-queue l#) a0 move
 BP-flag # poffset flags a0 d) btst 	\ background process?
 0<> if					\ yes
  poffset external-time a0 d) d0 move	\ is its time position less than SVT?
  addr cur-SVT l#) d0 cmp
  u< if 				\ yes --- put it at SVT
   addr cur-SVT l#) poffset external-time a0 d) move
  then
  poffset external-time a0 d) d0 move
  4 d0 addq   \ next wakeup buffer slot (for MIDI clock)
  d0 poffset wakeup-time a1 d) move
 else
  poffset external-time a0 d) poffset wakeup-time a1 d) move
 then
 a1 sp -) move
 ' (rec->wakeup l#) jsr
c;

: event
 event-rec drop ;

internals definitions

: (::ev		( args --- ; compiled by ::ev )
\ following in dictionary: nargs branch-addr
\ this is in turn followed by the event routine
 r@ @			\ get nargs
 r> na1+ dup @ >r	\ branch address
 na1+			\ event routine address
 event ;		\ schedule event

code (rts
 rts
end-code

ap-defs definitions

: ::ev
 compile (::ev
 here to params-addr
 true to params-OK?
 0 ,				\ nargs
 here 0 token,			\ branch address
\ What follows is the event routine machine-language preamble.
\ It is called by a jsr.  Its tasks are
\ 1) to set up the Forth registers and switch to high-level interpretation;
\ 2) to arrange for an "rts" to be done when the high-level part is done.
\ NOTE: if you change the following code you must change the
\ constant "ev-hdr-len", used in the decompiler
 [ assembler ]
 long
 temp-stack 200 + l#) rp lea	\ temporary return stack
 (forth-context)
 (record->stack)
 ['] (free l#) jsr
 0 l#) ip lea			\ set up an appropriate IP (see below)
 next				\ fire up the event
 here here 8 - !		\ backpatch the "lea" instruction (see above)
 [ current @ context ! ]
 2345				\ magic #
; immediate

internals definitions

54 constant ev-hdr-len

ap-defs definitions

: ;;ev
 2345 ?pairs
 compile (rts
 here swap !
 false to params-OK?
; immediate
