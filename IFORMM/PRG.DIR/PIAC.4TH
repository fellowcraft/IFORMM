\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ SLIDER
\ may 7th,90 ; april 18, 95 ; april 97 ; march 98 ; september 99 ;
\ september 2000 ; december 2003 (restore)
\ slider for mixboard 
\ --> first random process 


\ use the sliders to control variables in processes.

\ SliderInit ( value #Slider -- ) 
\ example: 100 1 SliderInit

\ Slider ( #Slider -- n )
\ example:     1 Slider 

\ slideractions ( -- does an action ) 
\  define action:
\ :  send-out-mod-wheel   
\    0 Slider 1 0 mcc 
\ ; 
\ install action:
\ ' send-out-mod-wheel 0 slideractions !  
\ use action:
\ type:    slider       and move leftmost slider 

\ see action:
\ .slideractions ( -- nlist )
\ prints out a list

\ ---------------------------------------------------------------------

only forth also internals also forth definitions 


variable allsliders        17 allsliders ! 
variable slider-length    128 slider-length !
variable slider-offset     20 slider-offset !
    
create old-y-pos      allsliders @ /w* allot
create current-y-pos  allsliders @ /w* allot
create xpositions     allsliders @ /w* allot
create ypositions     allsliders @ /w* allot
create slider-values  allsliders @ /w* allot


: display-numbers  ( box# -- prints value )
 
 /w* >r         r@ slider-values + w@   
                r@    xpositions + w@   
                r>    ypositions + w@ slider-length @ + 4 +
		        say.
; 


: display-slide-box  ( box# -- )  
 /w* >r   r@ xpositions + w@  x1 !        
          r> ypositions + w@  y1 !
                          10  x2 ! 
           slider-length @ 1+ y2 ! 
; 

: check-slide-box    ( box# -- )   
 /w* >r   r@  xpositions + w@  x1 !   
          r>  ypositions + w@  y1 !
                           10  x2 !
              slider-length @  y2 !
; 


: pos-box   ( box# y-position -- )  y1 ! 
            /w* xpositions + w@ 1+ x1 ! 8 x2 ! 1 y2 ! ;       


: .box         ( box# -- prints box# ) 
  dup /w* >r           r@ xpositions    + w@ 
                       r> ypositions    + w@ 15 -       
                       say. 
                                
; 

: Slider ( box# -- data ) 
    /w* slider-values + w@ 
; 

: SliderInit ( value box# -- data ) 
    /w* slider-values + w! 
; 



: convert-screen-to-value ( y-pos -- value )
 slider-offset @ - 
 slider-length @ - negate

;
 
: convert-value-to-screen ( val -- y-pos )
 slider-length @ - negate
 slider-offset @ +
;


: text-display

0 184 say." 0=f 1=U 2/3=X/Y 4/5=X/Y 6=v 7=U 8=l 9=U 10=p 11=U" 

;


: default-slider-setup 

                 1 char-color !

                 black-line  
                 allsliders @ 0 do 
  

  \ better notation would be:  slider-offset  i  ypositions!
  				 
  slider-offset @        i /w*  ypositions  + w!
 640 allsliders @ / i *  i /w*  xpositions  + w!

	
				                 white-fill  
                                 i display-slide-box box(filled)
                                 box(unfilled)    
            
              i /w* slider-values + w@ 
              convert-value-to-screen         
              i /w* current-y-pos + w!  
              
              i /w* current-y-pos + w@  
              i /w* old-y-pos + w! 

           black-fill i i /w* current-y-pos + w@ pos-box box(filled)    
           
                   i display-numbers 
                   i .box
                  loop     
 
                  text-display
             
;


\ ------ main gui word  ----

: default-slider-action
       allsliders @ 0 do   
      
       i check-slide-box check.box left-button and   
      
          if 
          
             mouse-y dup i /w* current-y-pos + w!  
             convert-screen-to-value i /w* slider-values + w!       
           
                
     
white-fill i i /w*  old-y-pos + w@ pos-box  
box(filled)
black-fill i i /w* current-y-pos + w@ pos-box
box(filled) 
                 i display-numbers                   
                 i /w* current-y-pos + w@ 
                 i /w* old-y-pos     + w! 
         
          then
                
        loop 
;


\ ================================================
\ Let's Slider value to be set by another process 
\ or by Ext. Controller
\ ================================================

quan cur-S#
: ccSlider   ( value n# -- )

  to cur-S#
  cur-S# /w* slider-values + w!       
           
;

\ -------------------------------


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


: bruno-setup
  
  59 0 SliderInit
  19 1 SliderInit
  1  2 SliderInit
  31 3 SliderInit
  1  4 SliderInit
  14 5 SliderInit
   4 6 SliderInit
  120 7 SliderInit
 44  8 SliderInit
  33 9 SliderInit
  1 10 SliderInit     
  1 11 SliderInit 
  0 12 SliderInit
  1 13 SliderInit
  1 14 SliderInit
  1 15 SliderInit
  1 16 SliderInit

;


: panda-setup
  
  34  0 SliderInit
  17  1 SliderInit
  2   2 SliderInit
  16  3 SliderInit
  3   4 SliderInit
  58  5 SliderInit
  11  6 SliderInit
  60  7 SliderInit
  60  8 SliderInit
  28  9 SliderInit
  1  10 SliderInit     
  1  11 SliderInit 
  0  12 SliderInit
  1  13 SliderInit
  72 14 SliderInit
  1  15 SliderInit
  1  16 SliderInit

;

: orchy-setup

  34  0 SliderInit
  25  1 SliderInit
  4   2 SliderInit
  29  3 SliderInit
  11   4 SliderInit
  58  5 SliderInit
  41  6 SliderInit
  57  7 SliderInit
  68  8 SliderInit
  23  9 SliderInit
  1  10 SliderInit     
  1  11 SliderInit 
  0  12 SliderInit
  1  13 SliderInit
 102 14 SliderInit
  1  15 SliderInit
  1  16 SliderInit

;


: orchy2-setup

  37  0 SliderInit
  13  1 SliderInit
  1   2 SliderInit
  8   3 SliderInit
  1   4 SliderInit
  9  5 SliderInit
  28  6 SliderInit
  98  7 SliderInit
  29  8 SliderInit
  53  9 SliderInit
  1  10 SliderInit     
  1  11 SliderInit 
  0  12 SliderInit
  1  13 SliderInit
 102 14 SliderInit
  4  15 SliderInit
  1  16 SliderInit

;


: plug-setup

  45  0 SliderInit
  4  1 SliderInit
  1   2 SliderInit
  62   3 SliderInit
  1   4 SliderInit
  53  5 SliderInit
  28  6 SliderInit
  98  7 SliderInit
  68  8 SliderInit
  24  9 SliderInit
  1  10 SliderInit     
  1  11 SliderInit 
  0  12 SliderInit
 11  13 SliderInit
 102 14 SliderInit
  4  15 SliderInit
  1  16 SliderInit

;

: string-setup

  51  0 SliderInit
  9  1 SliderInit
  1   2 SliderInit
  15   3 SliderInit
  1   4 SliderInit
  15  5 SliderInit
  53  6 SliderInit
  74  7 SliderInit
  18  8 SliderInit
  32  9 SliderInit
  1  10 SliderInit     
  1  11 SliderInit 
  0  12 SliderInit
 72  13 SliderInit
 67 14 SliderInit
  6  15 SliderInit
  4  16 SliderInit

;


: piac-setup

  45  0 SliderInit
  30  1 SliderInit
  1   2 SliderInit
  15   3 SliderInit
  1   4 SliderInit
  10  5 SliderInit
  32  6 SliderInit
  88  7 SliderInit
  18  8 SliderInit
  32  9 SliderInit
  1  10 SliderInit     
  1  11 SliderInit 
  0  12 SliderInit
 10  13 SliderInit
 67 14 SliderInit
  6  15 SliderInit
  4  16 SliderInit

;



create scale1      0 , 2 , 4 , 5 , 7 , 9 , 11 ,
create scale       0 , 2 , 4 , 6 , 7 , 9 , 11 ,
create scalePenta  0 , 2 , 5 , 7 , 9 ,
create dur7        0 , 4 , 7 , 11 ,
create moll7       0 , 3 , 7 , 10 ,
create sad         0 , 3 , 4 , 7 , 8 , 11 ,

quan rndT
: Cirnd  100 irnd to rndT
                  rndT 50  <  if 0 exit endif
                  rndT 80  <  if 1 exit endif
                  rndT 90  <  if 2 exit endif
  	          rndT 100 <  if 3 exit endif
               
; 

: +or- brnd if + else - then ;

quan maxChannels

quan Rpitch 0 to Rpitch
quan Rvel   0 to Rvel
quan Rdur   0 to Rdur 

:ap pure-random         \ the first random stream without GUI 
 ::ap

 

 120 beats-per-minute
 midi-thru-channel to $channel

 begin
 

127 irnd 16 Slider > if 
 \ 1 8 tel 0 $            \ pause
 30 30 irnd  + 0 SliderInit  \ change key  
 24 irnd       1 SliderInit  \ change range
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
       
       scalePenta 
       1 Slider irnd dup rot swap
       5 mod 4* + @                \ freq from scale           
       swap 5 / 12 * +               \ error (3 instead of 6) leads to new distribution. 
       0 Slider +
       to Rpitch

       7 Slider irnd                \ around center vel
       6 Slider +
       2* 127 -                     \ adjust for -127 - 127 range
       to Rvel        

       8 Slider         	    \ 
       9 Slider  irnd *
       $channel 7 > if 4 * then 
       14 Slider +
       1 max                 	    \ length of note
       to Rdur

       Cirnd to $channel 
       
       15 Slider 0 >
       if
       15 Slider irnd 1+ 0 
        do 
        $channel i + to $channel
        Rpitch Rvel Rdur MIDI-do-note
	loop
       endif


   loop
 
   then      
       0 $

  \ key? until
  again  
   
 ;;ap
;ap





: iboard

    pure-random
['] default-slider-setup  is gui-setup
['] default-slider-action is gui-action
    gui
;


