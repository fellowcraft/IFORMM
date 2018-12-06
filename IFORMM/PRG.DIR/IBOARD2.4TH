\ Copyright (c) 1988-2018 by Frank Rothkamm.  All rights reserved.
\ ---------------------------------------------------------------------
only forth also internals also forth definitions 

: pure-random-setup
 
  40 0 SliderInit
  24 1 SliderInit
  1  2 SliderInit
  16 3 SliderInit
  1  4 SliderInit
  16 5 SliderInit
  64 6 SliderInit
  1  7 SliderInit
 60  8 SliderInit
  2  9 SliderInit
  1 10 SliderInit     
  1 11 SliderInit 
  0 12 SliderInit
  1 13 SliderInit
  1 14 SliderInit
  1 15 SliderInit
  1 16 SliderInit

;

variable 'scale 
\ --------------- x-1,.x.,--------------------------------------------
create scale0     11 , 0 , 1 , 2 ,  3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11
create scale1      6 , 0 , 2 , 4 ,  5 , 7 ,  9 , 11 ,
create scale2      6 , 0 , 2 , 4 ,  6 , 7 ,  9 , 11 ,
create scalePenta  4 , 0 , 2 , 5 ,  7 , 9 ,
create dur7        3 , 0 , 4 , 7 , 11 ,
create moll7       3 , 0 , 3 , 7 , 10 ,
create scaleSB     3 , 0 , 3 , 7 ,  8 ,
create sad         5 , 0 , 3 , 4 ,  7 , 8 , 11 ,

' scalePenta 'scale !
: scale 'scale @ execute ;

quan rndT
: Cirnd  100 irnd to rndT
                  rndT 50  <  if 0 exit endif
                  rndT 80  <  if 1 exit endif
                  rndT 90  <  if 2 exit endif
  	          rndT 100 <  if 3 exit endif
               
; 

quan maxChannels
quan Rpitch 0 to Rpitch
quan Rvel   0 to Rvel
quan Rdur   0 to Rdur 
quan SliderVal 0 to SliderVal

:ap pure-random2         \ the first random stream without GUI 
 ::ap

 

 120 beats-per-minute
 midi-thru-channel to $channel

 begin
 

126 irnd 1+ 16 Slider < if 
 \ 1 8 tel 0 $            \ pause
 40 12 irnd  + 0 SliderInit  \ change key  
\ 24 irnd       1 SliderInit  \ change range
then

 brnd
 if   2 Slider 3 Slider tel
 else 4 Slider 5 Slider tel
 then

 13 Slider 1 > if
 12 Slider 13 Slider 40 * irnd + $channel mpb
               then

 0 Slider 0 > if                  \ 0 turns note-generation off
 
 10 Slider 11 Slider irnd + 1 max 
 0 do
        1  0 = if 
        10 to $channel
         46 80 40 irnd + 80 MIDI-do-note  			\ timpani        
       endif
       
       1 Slider irnd to SliderVal
              
       scale
       SliderVal scale @ mod 4* 4 +
       +
       @ 
       
       SliderVal scale @  /  12 * 
       +

       0 Slider 
       +
       dup 127 > if dup 100 220 say. endif 
       to Rpitch

       7 Slider irnd                \ around center vel
       6 Slider +
       2* 127 -                     \ adjust for -127 - 127 range
       to Rvel        

       8 Slider 
       9 Slider irnd dup * 
       +
       1 max                 	    \ length of note
       to Rdur

       Cirnd to $channel 
       
       15 Slider irnd 1+ 0 
        do 
        i dup 20 200 say.
        to $channel
        Rpitch dup 20 220 say.
        Rvel dup   20 240 say.
        Rdur dup   20 260 say.
        MIDI-do-note
     	loop


   loop
 
   then      
       0 $

  \ key? until
  again  
   
 ;;ap
;ap





: iboard2
 
['] default-slider-setup is gui-setup
['] default-slider-action is gui-action
    pure-random-setup
    pure-random2
    gui
;


