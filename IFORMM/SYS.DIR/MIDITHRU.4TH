\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

only forth also ap-defs also internals also forth definitions

\ midi-thru-handling
\ default: note on, note off, cc with stochastics.

defer thru-display

quan midi-thru-channel
quan current-note
quan current-velocity

: mat-thru  ( v -- )

midi-thru-channel MIDI-after-touch or 2 ['] MIDI-command-event event    
  
;

: mpb-thru  ( v v -- )

midi-thru-channel MIDI-pitch-bend or 3 ['] MIDI-command-event event

;

\ ---------------------------------------------

create equalArray 128 /n* allot

\ --------------------------- OFF ------------------------------------
quan current-off-note

: off-on ( n -- e )
  
  to current-off-note
  
    current-off-note                      \ pitch
    current-off-note /n* equalArray + @   \ random-offset
    +  
        
   midi-thru-channel  mku

 
;

\ ----------------------------------- RND ----------------------------------------
quan  $rnd
quan offset-note
quan offset-cent
quan master-transpose

defer magic-number

: uniform-around-center 
  $rnd irnd $rnd 2/ -                  \ distribution around center
;

: 1/f-around-center 
  $rnd frnd2 $rnd 2/ -                  \ distribution around center
;

: neumann-around-center 
  nrnd $rnd 1 max mod $rnd 2/ -         \ distribution around center
;

' uniform-around-center is magic-number 


\ ----------------------------------- ON ----------------------------------------
: on-on
   
  to current-note 
  to current-velocity

  magic-number
  master-transpose + to offset-note    \ + or - fixed amount
  current-note offset-note +           \ actual note        	       
  dup 127 > swap 1 < or                \ exceed boundaries?
  if  exit then                        \ exit

  offset-note current-note /n* equalArray + !  	\ keep pitch
    
  current-velocity
  current-note offset-note +
  midi-thru-channel  mkd

  thru-display
;



:ap  rnd-bubble
 
 ::gp
 
  current-velocity 0 do     	  
    64 					\ vol
    24 irnd 64 +        \ pitch
    MIDI-note-on midi-thru-channel or 
    3 ['] MIDI-command-event 
	3000 irnd 1+  
	future-event    
  loop  
  ;;gp	
;ap


quan cc_val1
quan cc_val2 
quan cc_index

: mcc-thru-test
  to cc_val1       			\ get the current parameters    
  to cc_val2       

  cc_val2 dup .                           
  cc_val1 dup . cr
  midi-thru-channel
  mcc
      
;              


variable cur-sysex   8 allot

: sys-action
  cur-sysex 1 get-sysex-command 
  cur-sysex . cr
;




\ ---------------------- Continious Controllers --------------------------------
: mcc-thru
   
\ MS20 
  
  to cc_val1       			\ get the current parameters
  to cc_val2

 \ pitch randomization
   cc_val1 126 =         \ could also be mod wheel 1
   if cc_val2 to $rnd exit then

 \ sustain pedal
   cc_val1 64 =
   if cc_val2 cc_val1 midi-thru-channel mcc exit then

  \ catch Volume control and make index
  \ cc_val1 7 =
  \ if cc_val2 10 / 10 * to cc_index exit then

  cc_val1 29 = if
     cc_val2 case 
	 0 of   ['] uniform-around-center is magic-number endof
	 43 of  ['] 1/f-around-center is magic-number endof
	 85 of  ['] neumann-around-center is magic-number endof
   \ 127 of     endof
     endcase	 
  exit then
  
  \ master transpose
  cc_val1 15 = if
     cc_val2 case 
	 0 of   -24 to master-transpose endof
	 43 of  -12 to master-transpose endof
	 85 of    0 to master-transpose endof
	 127 of  12 to master-transpose endof
     endcase
  exit then
  
  cc_val2 cc_val1 midi-thru-channel mcc

;

\ ---------------------------------------------
quan scr_refresh 0 to scr_refresh
:  (thru-display 

   scr_refresh   0  = 
   scr_refresh 640 >= 
   or if
    \ erase-screen 
  	  1 to scr_refresh 
  	  then
   
   scr_refresh 1+ to scr_refresh     
   
   scr_refresh 
   current-note negate 100 +  
   1 !pix 
   
   current-note     570 300 say.   
   current-velocity 570 315 say. 
   cc_val1          570 330 say.   
   cc_val2          570 345 say.
 
   \ 560 x1 ! 201 y1 !   
   \ f38  x2 !  32  y2 !  box(unfilled)
 
;

' (thru-display is thru-display


defer midithru

:  default-midi

 ['] off-on           0 MIDI-action !
 ['] on-on            1 MIDI-action !
 ['] mcc-thru         3 MIDI-action !
 ['] mat-thru         5 MIDI-action !
 ['] mpb-thru         6 MIDI-action !
 ['] sys-action       7 MIDI-action !

;

' default-midi is midithru
