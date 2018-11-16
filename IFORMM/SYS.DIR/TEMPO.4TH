\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ TEMPO --- words to change the overall speed of the system.
\ The goal is to have a means of fine-tuning the overall speed,
\ perhaps within a few powers of two, with lots of bits of precision.
\ This might be used for automatic synchronization to an external clock,
\ or just fiddling around with the tempo.

\ "real time" (RT), as measured in 5 msec ticks.

\ "system virtual time" (SVT) advances with RT.
\ The current SVT is maintained as a
\ 64-bit number (cur-SVT) with 32 fractional bits
\ Time-position and deadline are in SVT.

\ "tempo" is units of SVT per unit of RT, stored with 16 fractional bits.
\ Because of the implementation of the action buffer
\ (actions are hashed by wakeup time divided by 4)
\ tempo should be about 4 << 16.
\ If it's much more, the clock int has to scan many buckets.
\ If it's much less, bucket chains will have many "for later" entries.

\ The current default is tempo = 5 << 16, just because this happens
\ to mean that SVT = milliseconds.
 
loaded definitions create _tempo
only forth also
internals also definitions

quan cur-SVT		\ current System Virtual Time
quan cur-SVT-frac

5000 constant clock-period	\ interrupt clock period in microseconds
quan old-tempo

forth definitions

quan tempo		\ SVT per ST, scaled by 2^16

: usec-per-SVT	( n --- adjust tempo so that 1 unit of SVT is n usecs )
 clock-period th 10000 * swap / to tempo ; 

\ when using MIDI clock, each clock message advanced SVT
\ by 20.8333 (= 1000/48) units, so that processes with
\ rscale = 2000 will get the right tempo
: start-MIDI-clock
 MIDI-clock 0= if
	 1 to MIDI-clock
	 tempo to old-tempo
	 1365333 to tempo
 then
;

: stop-MIDI-clock
 MIDI-clock if
  0 to MIDI-clock
  old-tempo to tempo
 then
;

internals definitions

:cm (update-SVT)
\ macro to update SVT, used in sysclock handler
 d1 clr
 addr tempo 2+ l#) d0 wmove		\ add fractional parts
 addr cur-SVT-frac l#) d0 word add long
 d0 addr cur-SVT-frac l#) wmove
 addr cur-SVT l#) d0 move		\ get integer parts in D-regs
 addr tempo l#) d1 wmove
 d0 d1 addx				\ add with carry from low part
 d1 addr cur-SVT l#) move
;cm
