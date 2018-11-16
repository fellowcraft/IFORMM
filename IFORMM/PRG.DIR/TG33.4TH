\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ .................//////////////////////////////////////////////...............
\ -----------------                  TG33                        ---------------
\ .................\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\...............

\ quan all_levels  0 to all_levels

quan tgOSC 0 to tgOSC


: TG33-control    \ 15 to para-channel

\ midi-in-channel 1 = if          \ absolute assignment for Oxygen8
\ cc_val1   
\ case
\  \ LFO -------------------------------------------------------
\   21 of 2 9 tgOSC  0 3  1 96   0 cc_val2 4 / TG33 endof \ LFO speed
\   22 of 2 9 tgOSC  0 7  1 96   0 cc_val2 4 / TG33 endof \ LFO PMD

\   \ ------------------------------------------------------------
\   25 of  7 tgOSC  0 6  1 112  0 cc_val2 8 / TG33 endof \ LFO AMD
\   26 of  7 tgOSC  0 3  0  31  0 cc_val2     TG33 endof \ LFO wave
 
\  endcase 
\ exit then

midi-in-channel 0 = if          \ absolute assignment for MS20
 cc_val1   
 case
 
   \ experimental-algorithm-control
	77 of cc_val2 0 ccSlider endof 
	78 of cc_val2 1 ccSlider endof
	
	97 of cc_val2 1 max 2  ccSlider endof    \ x/ 
	98 of cc_val2 1 max 4  ccSlider endof    \ /y
	95 of cc_val2 1 max 3  ccSlider endof    \ x/
	96 of cc_val2 1 max 5  ccSlider endof    \ /y
			
    94 of cc_val2 7 1 max ccSlider endof 	\ vel rnd	  
   
   endcase 
exit then


  cc_val1
  cc_index +   
  case
  

  \ Element 0 ----------------------------------------------

\    $02 ST $0b F1 F2 B1  B2 - data                        \ b=element
31 of 3   3   0  0 12  1  64 0 cc_val2 2 / TG33 endof      \ Attack Rate
32 of 3   3   0  0 17  1   0 0 cc_val2     TG33 endof      \ Attack Level
33 of 3   4   0  0 13  1  64 0 cc_val2 2 / TG33 endof      \ Decay1 Rate
34 of 3   4   0  0 18  1   0 0 cc_val2     TG33 endof      \ Decay1 Level
35 of 3   5   0  0 14  1  64 0 cc_val2 2 / TG33 endof      \ Decay2 Rate
36 of 3   5   0  0 19  1   0 0 cc_val2     TG33 endof      \ Decay2 Level
37 of 3   6   0  0 15  1  64 0 cc_val2 2 / TG33 endof      \ Release Rate

\      $02 ST $0b F1 F2 B1  B2 - data                     \ b=element
  41 of 2   0   0  0  0  1 127 0 cc_val2       TG33 endof \ Wave Type
  42 of 2   1   0  0  1  1 127 0 cc_val2       TG33 endof \ Freq Shift  
  43 of 2   0   0  0  9  1 127 0 cc_val2       TG33 endof \ Volume     

  46 of 2   4   0  0  9  1 112 0 cc_val2       TG33 endof \ VS     
  47 of 2   3   0  0  8  1 120 0 cc_val2 31 /  TG33 endof \ Pan     

\      $02 ST $0b F1 F2 B1  B2 - data                     \ b=element
  51 of 2   7   0  0  3  0  31 0 cc_val2       TG33 endof \ LFO type 
  52 of 2   9   0  0  3  1  96 0 cc_val2 4 /   TG33 endof \ LFO speed
  53 of 2   7   0  0  7  1  96 0 cc_val2       TG33 endof \ LFO PM
  54 of 2   7   0  0  6  1 112 0 cc_val2 4 /   TG33 endof \ LFO AM
  55 of 2   8   0  0  4  1 127 0 cc_val2       TG33 endof \ LFO Delay
  56 of 2   8   0  0  5  1 127 0 cc_val2       TG33 endof \ LFO Rate

  \ Element 1 ----------------------------------------------

\    $02 ST $0b F1 F2 B1  B2 - data                        \ b=element
71 of 3   3   1  0 48  1  64 0 cc_val2 2 / TG33 endof      \ Attack Rate
72 of 3   3   1  0 17  1   0 0 cc_val2     TG33 endof      \ Attack Level
73 of 3   4   1  0 13  1  64 0 cc_val2 2 / TG33 endof      \ Decay1 Rate
74 of 3   4   1  0 18  1   0 0 cc_val2     TG33 endof      \ Decay1 Level
75 of 3   5   1  0 14  1  64 0 cc_val2 2 / TG33 endof      \ Decay2 Rate
76 of 3   5   1  0 19  1   0 0 cc_val2     TG33 endof      \ Decay2 Level
77 of 3   6   1  0 15  1  64 0 cc_val2 2 / TG33 endof      \ Release Rate

\      $02 ST $0b F1 F2 B1  B2 - data                     \ b=element
  81 of 2   0   1  0  0  1 127 0 cc_val2       TG33 endof \ Wave Type
  82 of 2   1   1  0  1  1 127 0 cc_val2       TG33 endof \ Freq Shift  
  83 of 2   0   1  0  9  1 127 0 cc_val2       TG33 endof \ Volume     

  86 of 2   4   1  0  9  1 112 0 cc_val2       TG33 endof \ VS     
  87 of 2   3   1  0  8  1 120 0 cc_val2 31 /  TG33 endof \ Pan     

\      $02 ST $0b F1 F2 B1  B2 - data                     \ b=element
  91 of 2   7   1  0  3  0  31 0 cc_val2       TG33 endof \ LFO type 
  92 of 2   9   1  0  3  1  96 0 cc_val2 4 /   TG33 endof \ LFO speed
  93 of 2   7   1  0  7  1  96 0 cc_val2       TG33 endof \ LFO PM
  94 of 2   7   1  0  6  1 112 0 cc_val2 4 /   TG33 endof \ LFO AM
  95 of 2   8   1  0  4  1 127 0 cc_val2       TG33 endof \ LFO Delay
  96 of 2   8   1  0  5  1 127 0 cc_val2       TG33 endof \ LFO Rate



  \ Element 2 ----------------------------------------------

\    $02 ST $0b F1 F2 B1  B2 - data                        \ b=element
111 of 3   3   2  0 12  1  64 0 cc_val2 2 / TG33 endof      \ Attack Rate
112 of 3   3   2  0 17  1   0 0 cc_val2     TG33 endof      \ Attack Level
113 of 3   4   2  0 13  1  64 0 cc_val2 2 / TG33 endof      \ Decay1 Rate
114 of 3   4   2  0 18  1   0 0 cc_val2     TG33 endof      \ Decay1 Level
115 of 3   5   2  0 14  1  64 0 cc_val2 2 / TG33 endof      \ Decay2 Rate
116 of 3   5   2  0 19  1   0 0 cc_val2     TG33 endof      \ Decay2 Level
117 of 3   6   2  0 15  1  64 0 cc_val2 2 / TG33 endof      \ Release Rate

\      $02 ST $0b F1 F2 B1  B2 - data                     \ b=element
  121 of 2   0   2  0  0  1 127 0 cc_val2       TG33 endof \ Wave Type
  122 of 2   1   2  0  1  1 127 0 cc_val2       TG33 endof \ Freq Shift  
  123 of 2   0   2  0  9  1 127 0 cc_val2       TG33 endof \ Volume     

  126 of 2   4   2  0  9  1 112 0 cc_val2       TG33 endof \ VS     
  127 of 2   3   2  0  8  1 120 0 cc_val2 31 /  TG33 endof \ Pan     

\      $02 ST $0b F1 F2 B1  B2 - data                     \ b=element
  131 of 2   7   2  0  3  0  31 0 cc_val2       TG33 endof \ LFO type 
  132 of 2   9   2  0  3  1  96 0 cc_val2 4 /   TG33 endof \ LFO speed
  133 of 2   7   2  0  7  1  96 0 cc_val2       TG33 endof \ LFO PM
  134 of 2   7   2  0  6  1 112 0 cc_val2 4 /   TG33 endof \ LFO AM
  135 of 2   8   2  0  4  1 127 0 cc_val2       TG33 endof \ LFO Delay
  136 of 2   8   2  0  5  1 127 0 cc_val2       TG33 endof \ LFO Rate

  \ Element 3 ----------------------------------------------

\    $02 ST $0b F1 F2 B1  B2 - data                        \ b=element
151 of 3   3   3  0 12  1  64 0 cc_val2 2 / TG33 endof      \ Attack Rate
152 of 3   3   3  0 17  1   0 0 cc_val2     TG33 endof      \ Attack Level
153 of 3   4   3  0 13  1  64 0 cc_val2 2 / TG33 endof      \ Decay1 Rate
154 of 3   4   3  0 18  1   0 0 cc_val2     TG33 endof      \ Decay1 Level
155 of 3   5   3  0 14  1  64 0 cc_val2 2 / TG33 endof      \ Decay2 Rate
156 of 3   5   3  0 19  1   0 0 cc_val2     TG33 endof      \ Decay2 Level
157 of 3   6   3  0 15  1  64 0 cc_val2 2 / TG33 endof      \ Release Rate

\      $02 ST $0b F1 F2 B1  B2 - data                     \ b=element
  161 of 2   0   3  0  0  1 127 0 cc_val2       TG33 endof \ Wave Type
  162 of 2   1   3  0  1  1 127 0 cc_val2       TG33 endof \ Freq Shift  
  163 of 2   0   3  0  9  1 127 0 cc_val2       TG33 endof \ Volume     

  166 of 2   4   3  0  9  1 112 0 cc_val2       TG33 endof \ VS     
  167 of 2   3   3  0  8  1 120 0 cc_val2 31 /  TG33 endof \ Pan     

\      $02 ST $0b F1 F2 B1  B2 - data                     \ b=element
  171 of 2   7   3  0  3  0  31 0 cc_val2       TG33 endof \ LFO type 
  172 of 2   9   3  0  3  1  96 0 cc_val2 4 /   TG33 endof \ LFO speed
  173 of 2   7   3  0  7  1  96 0 cc_val2       TG33 endof \ LFO PM
  174 of 2   7   3  0  6  1 112 0 cc_val2 4 /   TG33 endof \ LFO AM
  175 of 2   8   3  0  4  1 127 0 cc_val2       TG33 endof \ LFO Delay
  176 of 2   8   3  0  5  1 127 0 cc_val2       TG33 endof \ LFO Rate
   
  endcase

;



\ ---------------------- main---------------------------------------------------
: TG33-thru
  MS20
  to cc_val1       			\ get the current parameters 
  to cc_val2
 
\   cc_val1 . 
\   cc_val2 . cr
 
\ sustain pedal ----------------------------------------------------------------
  cc_val1 64 = 
  if cc_val2 cc_val1 midi-thru-channel mcc exit then

\ pitch randomization ----------------------------------------------------------
  cc_val1 1 =      \ mod wheel
  if cc_val2 to $rnd exit then

\ master transpose
  cc_val1 15 = if
     cc_val2 case 
	 0 of   -24 to master-transpose endof
	 43 of  -12 to master-transpose endof
	 85 of    0 to master-transpose endof
	 127 of  12 to master-transpose endof
     endcase
  exit then

\ irnd - frnd - nrnd : switches ------------------------------------------------
cc_val1
case 29 of
     cc_val2 case 
	 0 of   ['] uniform-around-center is magic-number endof
	 43 of  ['] 1/f-around-center is magic-number endof
	 85 of  ['] neumann-around-center is magic-number endof
   \ 127 of     endof
     endcase
   endof
   
endcase

\ catch Volume control and make index ----------------------------------------
  cc_val1 7 = 
  if
 \ cc_val2   0 = if -10 to cc_index exit then
 \ cc_val2 127 = if -20 to cc_index exit then

  cc_val2     1 = if    0 to cc_index exit then
  cc_val2    41 = if   40 to cc_index exit then
  cc_val2    81 = if   80 to cc_index exit then
  cc_val2   121 = if  120 to cc_index exit then


 \ cc_val2     1 = if   0 to tgOSC exit then
 \ cc_val2    41 = if   1 to tgOSC exit then
 \ cc_val2    81 = if   2 to tgOSC exit then
 \ cc_val2   121 = if   3 to tgOSC exit then
   
  then      
 
  TG33-control
  
;


: TG33-on-on
  
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




: tg33

  ['] off-on      0 MIDI-action !

  ['] TG33-on-on  1 MIDI-action !
      
  ['] TG33-thru   3 MIDI-action !
  
\ ['] test-patch 4 MIDI-action ! 
   
  ['] mat-thru   5 MIDI-action !

  ['] mpb-thru   6 MIDI-action !

  ['] sys-action 7 MIDI-action !

;
