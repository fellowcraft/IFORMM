\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ------------------------------------------------------------------------------
\ ----------------------------Kawai K5 / K5M------------------------------------
\ ------------------------------------------------------------------------------

only forth also ap-defs also internals also forth definitions

quan SBOTH 2 to SBOTH   \ 0=S1  1=S2  2=BOTH

quan Data
 quan ValueLow
 quan ValueHigh

quan CursorNo
 quan CursorLow
 quan CursorHigh 

hex

: _k5x  ( CursorNo Data -- )


        to Data
        to CursorNo 
		
   	Data tb 00001111 and      to ValueLow
		Data tb 11110000 and 4 >> to ValueHigh
       
	CursorNo tb 01111111 and      to CursorLow
 	CursorNo tb 10000000 and 7 >> to CursorHigh


	  
  f7            \ EOX
  ValueLow         
  ValueHigh
  CursorLow 
  SBOTH 1 << CursorHigh +
  02 			      \ K5 machine ID
  00            \ synth group
  10            \ parameter send
  para-channel  \ MIDI channel   
  40            \ Kawai ID
  f0            \ SYS-X debug
   
  
;

: k5x       _k5x 0b ['] MIDI-command-event event ;
: k5fx   >r _k5x 0b ['] MIDI-command-event r> future-event ;

decimal
