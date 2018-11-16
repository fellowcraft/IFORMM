\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.
\
\ 6850-INT -- interrupt handler for 6850 interrupt
\ include MIDI input and output interrupts

loaded definitions create _6850-int
only forth also
internals also definitions

\ The MIDI input interrupt, and most other interrupts, are arbitrated by the 
\ 68901 chip which interrupts the 68000 at level 6.
\ In order for the 68901 priorities to be meaningful, interrupt routines
\ must reenable hardware interrupts (by executing move #$2500, sr).
\ Failure to do so may result in lost MIDI input.
\ It is not done by the TOS system clock routine vectored at $114;
\ FORMULA's clock routine fixes this.

code 6850-handler		\ replaces TOS input handler
 th f0f4 # sp -) long movem	\ save d0-d3, a0-a3, a5
 begin
  7 # MIDI-cr l#) btst		\ interrupt from MIDI 6850?
  0<> if
   1 # MIDI-cr l#) btst		\ transmit buffer empty?
   0<> if
    ' MIDI-transmit l#) jsr
   then
   0 # MIDI-cr l#) btst		\ input buffer full?
   0<> if
    d0 long clr
    MIDI-dr l#) d0 bmove
    ' MIDI-input l#) jsr
   then
  then
  7 # kbd-cr l#) btst		\ interrupt from keyboard 6850?
  0<> if
   0 l# a5 move
   TOS-kbdrout l#) a2 move
   a2 ) jsr	
  then
  4 # th -5ff l#) btst		\ 68901 warns of pending interrupt
 0<> until			\ and lets you do it now
 6 # th -5ef l#) bclr 		\ explicitly clear interrupt-in-service bit
 sp )+ th 2f0f # movem		\ restore d0-d3, a0-a3, a5
 rte
end-code 

: +MIDI
 init-MIDI-input
 init-MIDI-output
 ['] 6850-handler 6850-vector token! ;
