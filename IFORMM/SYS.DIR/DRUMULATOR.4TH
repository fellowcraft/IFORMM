\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ------------------------------------------------------------------------
\ this was written for the Drumulator to send MIDI via the serial port

only forth also ap-defs also internals also forth definitions

: seri-only  (  -- vel pitch )
     [ modem ]
      15 and \ put pitch in playable range   
      swap
      3 >>  \ scale down velocity to 0-15      
      4 <<  \ make it most significant byte
       
      +
   
      ser-emit
; 

: Thru-drum
 ['] 2drop 0 MIDI-action !
 ['] seri-only 1 MIDI-action !
; 
