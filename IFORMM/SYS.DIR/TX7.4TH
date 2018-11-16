\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ------------------------------------------------------------------------------
\ ----------------------------Yamaha DX7 / TX7----------------------------------
\ ------------------------------------------------------------------------------


only forth also ap-defs also internals also forth definitions

pquan subgroup#
pquan parameter#
pquan data#

hex

: dx7  ( subgroup parameter data -- ) 

        to data#
        to parameter# 
        to subgroup#
      
   f7
   data# 
   parameter# 
   subgroup#
   10  para-channel or  
   43 
   f0 

   7 ['] MIDI-command-event event
;

decimal
