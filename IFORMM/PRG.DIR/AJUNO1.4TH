\ Copyright (c) 1987-2012 by Frank H. Rothkamm.  All rights reserved.

\ .................//////////////////////////////////////////////...............
\ -----------------                  Alpha JUNO 1                ---------------
\ .................\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\...............

\ quan all_levels  0 to all_levels


: AJUNO1-control    \ 15 to para-channel

  cc_val1
\ cc_index +   
  case
  

\ Parameters ----------------------------------------------

16 of   0 cc_val2 4 * 128 / AJUNO1 endof        \ DCO ENV MODE
17 of   1 cc_val2 4 * 128 / AJUNO1 endof        \ VCF ENV MODE
18 of   2 cc_val2 4 * 128 / AJUNO1 endof        \ VCA ENV MODE
19 of   3 cc_val2 4 * 128 / AJUNO1 endof        \ DCO WAVEFORM PULSE
20 of   4 cc_val2 6 * 128 / AJUNO1 endof        \ DCO WAVEFORM SAWTOOTH
21 of   5 cc_val2 6 * 128 / AJUNO1 endof        \ DCO WAVEFORM SUB
22 of   6 cc_val2 4 * 128 / AJUNO1 endof        \ DCO WAVEFORM RANGE
23 of   7 cc_val2 4 * 128 / AJUNO1 endof        \ DCO SUBLEVEL
24 of   8 cc_val2 4 * 128 / AJUNO1 endof        \ DCO NOISE LEVEL
25 of   9 cc_val2 4 * 128 / AJUNO1 endof        \ HPF Cutoff LEVEL
26 of  10 cc_val2 2 * 128 / AJUNO1 endof        \ CHORUS ON/OFF
27 of  11 cc_val2           AJUNO1 endof        \ DCO LFO MOD DEPTH
29 of  12 cc_val2           AJUNO1 endof        \ DCO ENV MOD DEPTH
30 of  13 cc_val2           AJUNO1 endof        \ DCO AFTER MOD DEPTH
31 of  14 cc_val2           AJUNO1 endof        \ DCO PW/PWM MOD DEPTH
32 of  15 cc_val2           AJUNO1 endof        \ DCO PWM RATE
33 of  16 cc_val2           AJUNO1 endof        \ VCF CUTOFF
34 of  17 cc_val2           AJUNO1 endof        \ VCF RESONANCE
35 of  18 cc_val2           AJUNO1 endof        \ VCF LFO MOD DEPTH
36 of  19 cc_val2           AJUNO1 endof        \ VCF ENV MOD DEPTH
37 of  20 cc_val2           AJUNO1 endof        \ VCF KEY FOLLOW
38 of  21 cc_val2           AJUNO1 endof        \ VCF AFTER DEPTH
39 of  22 cc_val2           AJUNO1 endof        \ VCA LEVEL
40 of  23 cc_val2           AJUNO1 endof        \ VCA AFTER DEPTH
41 of  24 cc_val2           AJUNO1 endof        \ LFO RATE
42 of  25 cc_val2           AJUNO1 endof        \ LFO DELAY TIME
43 of  26 cc_val2           AJUNO1 endof        \ ENV T1
44 of  27 cc_val2           AJUNO1 endof        \ ENV L1
45 of  28 cc_val2           AJUNO1 endof        \ ENV T2
46 of  29 cc_val2           AJUNO1 endof        \ ENV L2
47 of  30 cc_val2           AJUNO1 endof        \ ENV T3
48 of  31 cc_val2           AJUNO1 endof        \ ENV L3
49 of  32 cc_val2           AJUNO1 endof        \ ENV T4
50 of  33 cc_val2           AJUNO1 endof        \ ENV KEY FOLLOW
51 of  34 cc_val2           AJUNO1 endof        \ CHORUS RATE
52 of  35 cc_val2 13 * 128 / AJUNO1 endof       \ BENDER RANGE
   
  endcase

;



\ ---------------------- main---------------------------------------------------
: AJUNO1-thru
\ MS20
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
 
  AJUNO1-control
  
;


: AJUNO1-on-on
  
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




: ajuno1

  ['] off-on      0 MIDI-action !

  ['] AJUNO1-on-on  1 MIDI-action !
      
  ['] AJUNO1-thru   3 MIDI-action !
  
\ ['] test-patch 4 MIDI-action ! 
   
  ['] mat-thru   5 MIDI-action !

  ['] mpb-thru   6 MIDI-action !

  ['] sys-action 7 MIDI-action !

;
