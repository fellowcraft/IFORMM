\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ------------------------------------------------------------------------------
\ ----------------------------Yamaha TG33 --------------------------------------
\ ------------------------------------------------------------------------------


only forth also ap-defs also internals also forth definitions

quan tg_region
quan tg_st
quan tg_element_number
quan tg_f1
quan tg_f2 
quan tg_b1
quan tg_b2
quan tg_data_msb
quan tg_data_lsb

hex

: TG33  ( 1 2 3 4 5 6 7 8 9 -- ) 
   
  to tg_data_lsb
  to tg_data_msb
  to tg_b2
  to tg_b1
  to tg_f2
  to tg_f1
  to tg_element_number
  to tg_st
  to tg_region      
      
   f7
   tg_data_lsb
   tg_data_msb
   tg_b2
   tg_b1
   tg_f2
   tg_f1
   tg_element_number
   tg_st
   tg_region
   26
   10  para-channel or  
   43 
   f0 

   0e ['] MIDI-command-event event
;

decimal
