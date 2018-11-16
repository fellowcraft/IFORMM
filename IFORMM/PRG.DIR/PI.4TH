\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ This will generate a MIDI sequence of the first 1000 PI digits as intervals 
\ above C3. As there are 10 possible digits in our decimal system (0-9), the 
\ number 1 would be a half ton above C, or C# and the number 9 is Bb or A#.

\ Each PI digit also determines the duration of the note, expressing x/32 
\ where (x=0-9). Digit 0 represents therefore a note of 0/32 duration: 
\ the note will sound together with the next one.


create Pi 1000 allot 0 Pi !
  
: pi-read 
  [""] pi.txt read-open
  
  1000 0 do 
  ifd @ fgetc 48 -   \ char to number         
  i Pi + c!          \ store number
  loop

  close-files
;

:ap pi-play
 ::ap
     
    1000 0 do 
	 Pi i + c@           \ get #
     dup 10 > 
	  if 
	   drop              \ range check
      else		  			  
	   dup 300 100 say.  \ print
	   dup 1+ 32 tel        \ x/y dur
	   60 +              \ offset (C3)
	   $                 \ play
      then
	 loop                  
 ;;ap
;ap