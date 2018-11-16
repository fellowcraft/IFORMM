\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ Fb01 micro tuning $:  u$

only forth also ap-defs also internals also forth definitions

decimal

	: u$	( cents --- ; play a microtune in cents )
	 64 /mod swap 2* swap 2dup >r >r >r >r

	 getparams
 
	 th f7 0 r> r> th 10 $channel or th 70 th 75 th 43 th f0 
	  9 ['] MIDI-command-event 
          rel future-event 

	 th f7 
           vol 63 +
           r> r> th 10 $channel  or th 70 th 75 th 43 th f0 
         9 ['] MIDI-command-event event
	 
         dur time-advance
	 true to needparams

          
	;
