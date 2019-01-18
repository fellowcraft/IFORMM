\ Copyright (c) 1988-2018 by Frank Rothkamm.  All rights reserved.
\ ---------------------------------------------------------------------
only forth also internals also forth definitions 

: grid-setup
 
  40 0 0 V!
  24 0 1 V!
  1  0 2 V!
  16 0 3 V!
  1  0 4 V!
  16 0 5 V!
  64 0 6 V!
  1  0 7 V!
 60  0 8 V!
  2  0 9 V!
  1 0 10 V!     
  1 0 11 V! 
  0 0 12 V!
  1 0 13 V!
  1 0 14 V!
  1 0 15 V!
  1 0 16 V!

;

variable 'scale 
\ --------------- x-1,.x.,-----------------------------------------------
create scale0     11 , 0 , 1 , 2 ,  3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 ,
create scale1      6 , 0 , 2 , 4 ,  5 , 7 ,  9 , 11 ,
create scale2      6 , 0 , 2 , 4 ,  6 , 7 ,  9 , 11 ,
create scalePenta  4 , 0 , 2 , 5 ,  7 , 9 ,
create dur7        3 , 0 , 4 , 7 , 11 ,
create moll7       3 , 0 , 3 , 7 , 10 ,
create scaleSB     3 , 0 , 3 , 7 ,  8 ,
create sad         5 , 0 , 3 , 4 ,  7 , 8 , 11 ,
create scaleBlues  6 , 0 , 2 , 3 ,  5 , 6 ,  7 , 10 ,

' scaleBlues 'scale !
: scale 'scale @ execute ;

quan rndT
: Cirnd  100 irnd to rndT
                  rndT 50  <  if 0 exit then
                  rndT 80  <  if 1 exit then
                  rndT 90  <  if 2 exit then
  	          rndT 100 <  if 3 exit then
               
; 

quan maxChannels
quan Rpitch 0 to Rpitch
quan Rvel   0 to Rvel
quan Rdur   0 to Rdur 
quan tmp    0 to tmp

:ap random2         \ the first random stream without GUI 
 ::ap

 

 120 beats-per-minute
 midi-thru-channel to $channel

 begin
 

126 irnd 1+  0 16 V@  < if 
 \ 1 8 tel 0 $            \ pause
  40 12 irnd + 0 0 V!P  \ change key  
\ 24 irnd      0 1 V!   \ change range
then

0 17 V@ 0 = if 
            brnd
            else 
0 17 V@ irnd 50 < if true else false then            
            then   
 if   0 2 V@  0 3 V@  tel
 else 0 4 V@  0 5 V@  tel
 then   


 0 13 V@  1  > if
 0 12 V@  0 13 V@  40 * irnd + $channel mpb
               then

 0 0 V@  0  > if                  \ 0 turns note-generation off
 
 0 10 V@ 0 11 V@ irnd + 1 max 
 0 do
        1  0 = if 
        10 to $channel
         46 80 40 irnd + 80 MIDI-do-note  			\ timpani        
       then
       
       0 1 V@ irnd to tmp
              
       scale
       tmp scale @ mod 4* 4 +
       +
       @ 
       
       tmp scale @  /  12 * 
       +

       0 0 V@ 
       +
       dup 127 > if dup 10 300 say. then 
       to Rpitch

       0 7 V@ irnd                \ around center vel
       0 6 V@ +
       2* 127 -                     \ adjust for -127 - 127 range
       to Rvel        

       0 8 V@ 
       0 9 V@ irnd dup * 
       +
       1 max                 	    \ length of note
       to Rdur

    \   Cirnd to $channel 
       
     
    
        0 15 V@ irnd  dup 10 300 say.
        to $channel
        Rpitch dup 10 320 say.
        Rvel dup   10 340 say.
        Rdur dup   10 360 say.
        MIDI-do-note
   


   loop
 
   then      
       0 $

  \ key? until
  again  
   
 ;;ap
;ap


: formula-show

2 200 say." 0f..1U..2X/.3/Y.4X/.5/Y.6V..7u..8L..9u..10Po11u.12u$13u$14..15Ch16Tr17P%" 

;



: ifor01
    mouse-off
    erase-screen
    grid-setup
    formula-show
    random2
    grid2
;


