\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ------------------------------------------------------------------------------
\ ----------------------------Yamaha FS1R---------------------------------------
\ ------------------------------------------------------------------------------


only forth also ap-defs also internals also forth definitions

quan AddressHigh
quan AddressLow
quan AddressMiddle
quan DataValueMS
quan DataValueLS

hex

: fs1r  ( a b c d e -- )

        to DataValueLS
        to DataValueMS
        to AddressLow
        to AddressMiddle
        to AddressHigh
        
   f7
   DataValueLS
   DataValueMS
   AddressLow
   AddressMiddle
   AddressHigh
   5e
   10  para-channel or
   43 
   f0 

   10 ['] MIDI-command-event event
;

decimal
