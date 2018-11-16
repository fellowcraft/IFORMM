\ Copyright (c) 1987-2008 by Frank H. Rothkamm.  All rights reserved.

\ ------------------------------------------------------------------------------
\ ----------------------------Roland MKS-80 Super Jupiter-----------------------
\ ------------------------------------------------------------------------------


only forth also ap-defs also internals also forth definitions

pquan groupMKS
pquan parameterMKS
pquan dataMKS

hex

: mks80  ( group parameter data -- ) 

        to dataMKS
        to parameterMKS 
        to groupMKS
      
   f7
   dataMKS
   parameterMKS 
   groupMKS
   20  \ Level #
   20  \ Format Type 
   10  para-channel or  
   36
   41  
   f0 

   0a ['] MIDI-command-event event
;

decimal
