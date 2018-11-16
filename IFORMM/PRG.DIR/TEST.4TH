\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

quan SpeedD 8 to SpeedD


:ap test_fb
 ::ap              
        begin  
	    5000 3000 do 
		0 Slider 2* SpeedD max 2048  tel  \ fastest possible note: 1 2048
        brnd to $channel
		\ 3 i 1 Slider  irnd + 0 fre-dt   
        i 1 Slider irnd 8* + u$
		loop  
     again 
 ;;ap
;ap

:ap test
 ::ap              
        begin  
	    120 10 do 
		0 Slider 2* SpeedD max 2048  tel  \ fastest possible note: 1 2048
        brnd to $channel
		\ 3 i 1 Slider  irnd + 0 fre-dt   
        i 1 Slider irnd + $
		loop  
     again 
 ;;ap
;ap

( 
Random Variables


)

create timetable

 100 ,			\ total 'weight' of the table
 0 , 			\ 0 entry has 'no weight', so it will never happen
 50 ,			\ 1 entry will happen 50% of the time (50/100)
 25 ,			\ 2 entry will happen 25% of the time (25/100)
 24 ,			\ 3 entry will happen 24% of the time (24/100)
 1 ,			\ 4 entry will happen 1% of the time (1/100)


:ap demo.trnd
 ::ap 
  ::tsg 
    begin 
     timetable trnd  	\ pick random 1 2 3 or 4
     16 r>i & 		\ make a rhythmic value of that many 16th notes
    again
  ;;sg

  60 
  begin
	  128 frnd3 dup $
  again
 ;;ap
;ap
