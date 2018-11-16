\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ amplitude of partials
\ delayed in time, as all partials can't be set instantly because of MIDI/K5
\ limitations.

\ p p *  r r * r *  /  =  k  keplers harmonic law (3rd)

\ partial creation -------------------------------------------------------------
\ 40 Par 1-63
\ 41 Int 0-99
\ 42 env 1-4
\ 43 mod 0-1

quan RndEnv    \ Probability Variance used by the 4 Partial Sub Envelopes to
0 to RndEnv    \ set perfect to imperfect clones of a Master Envelope

quan k5r1
quan k5r2
quan k5r3
quan k5r4
quan k5r5
quan k5r6

quan k5l1  31 to k5l1
quan k5l2  31 to k5l2
quan k5l3  31 to k5l3
quan k5l4  31 to k5l4
quan k5l5  31 to k5l5
quan k5l6   0 to k5l6

quan kdelay  30 to kdelay
quan kindex  12 to kindex
quan pdelay 120 to pdelay

: Krnd ( n -- n )  RndEnv irnd + ;

\ plays K5 harmonics, sets the amplitude of each harmonic via velocity.
\ keys on a (regular 61 synth) keybard are mapped to harmonics.

quan key-adjust -11 to key-adjust

:ap  on-on-k5

  ::gp [ 2 params ]
  
   key-adjust + to current-note to current-velocity

   40                           \ harmonic
   current-note
   k5x

   41                           \ level
   current-velocity 20 -
   kdelay
   k5fx

 \  thru-display
 \ active-exit
  ;;gp
;ap

: off-off-k5  drop drop ;

:ap k5-control

\ -------------------- Secondary Process ---------------------------------------
  ::ap

  cc_val1
  case
 
\ irnd - frnd - nrnd : buttons -------------------------------------------------

  59 of
  ['] uniform-around-center is magic-number 
  endof
  
  19 of
  ['] 1/f-around-center is magic-number 
  endof
  
  69 of
  ['] neumann-around-center is magic-number 
  endof

\ irnd - frnd - nrnd : switches ------------------------------------------------
 
  29 of
     cc_val2 case 
	 0 of   ['] uniform-around-center is magic-number endof
	 43 of  ['] 1/f-around-center is magic-number endof
	 85 of  ['] neumann-around-center is magic-number endof
   \ 127 of     endof
     endcase
  endof
  
\ master transpose

  15 of
     cc_val2 case 
	 0 of   -24 to master-transpose endof
	 43 of  -12 to master-transpose endof
	 85 of    0 to master-transpose endof
	 127 of  12 to master-transpose endof
     endcase
  endof


\ harmonic or regular play (button 1) ------------------------------------------

  99 of
  [']  off-off-k5    0 MIDI-action !
  [']    on-on-k5    1 MIDI-action !
  endof

  79 of
  ['] off-on      0 MIDI-action !
  ['] on-on       1 MIDI-action !
  endof

  endcase
  ;;ap

\ ------------------------- Main Process ---------------------------------------
  ::gp [ 2 params ] 
  
  \ MS20 
  to cc_val1       			\ get the current parameters
  to cc_val2
  
\ catch Volume control and make index ------------------------------------------
  cc_val1 7 =
  if cc_val2 10 / 10 * to cc_index active-exit then

\ sustain pedal ----------------------------------------------------------------
  cc_val1 64 = 
  if cc_val2 cc_val1 midi-thru-channel mcc active-exit then

\ pitch randomization ----------------------------------------------------------
  cc_val1 1 =      \ mod wheel
  if cc_val2 to $rnd active-exit then

\ Group Buttons ----------------------------------------------------------------
  cc_val1 99 = if 0 to SBOTH exit then  \ S1
  cc_val1 79 = if 1 to SBOTH exit then  \ S2
  cc_val1 89 = if 2 to SBOTH exit then  \ BOTH

\ Absolute assignment for MS20 -------------------------------------------------
\ midi-in-channel 0 = if          
\ cc_val1   
\ case
\ experimental-algorithm-control
\	77 of cc_val2 0 ccSlider endof 
\	78 of cc_val2 1 ccSlider endof
	
\	97 of cc_val2 1 max 2  ccSlider endof    \ x/ 
\	98 of cc_val2 1 max 4  ccSlider endof    \ /y
\	95 of cc_val2 1 max 3  ccSlider endof    \ x/
\	96 of cc_val2 1 max 5  ccSlider endof    \ /y
			
\   94 of cc_val2 7 1 max ccSlider endof 	\ vel rnd	
   
\  endcase 
\ active-exit then

\ ------------------------------------------------------------------------------
\ cc to sys-x transform --------------------------------------------------------
\ ------------------------------------------------------------------------------

  cc_val1
  case
  
\ DFF --------------------------------------------------------------------------
   21 of    107 cc_val2  k5x  exit       endof     \ cutoff
    25 of   111 cc_val2 4 /  k5x	exit    endof  \ cutoff mod
   22 of   108 cc_val2 4 /  k5x	 exit   endof      \ slope
    26 of   112 cc_val2 4 /  k5x	exit    endof  \ slope mod
   23 of   109 cc_val2 4 /  k5x	 exit   endof      \ flat
    27 of   117 cc_val2 4 /  k5x exit	    endof  \ LFO mod Depth DFF
   24 of   174 cc_val2 21 /  k5x	 exit   endof  \ LFO shape
    28 of   175 cc_val2     k5x	 exit   endof      \ LFO Speed
  endcase

  
  cc_val1 cc_index +   
  case
 
\ Pitch Envelope ---------------------------------------------------------------
   31 of   22 cc_val2 2 / 32 - k5x	  endof    \ 3 pitch Level
   32 of   16 cc_val2 4 /  k5x	    	endof  \ 3 pitch Rate
   33 of   23 cc_val2 2 / 32 - k5x	  endof    \ 4 pitch Level
   34 of   17 cc_val2 4 /  k5x	    	endof  \ 4 pitch Rate
   35 of   0 cc_val2     64 - k5x	    endof  \ coarse
   36 of   1 cc_val2 2 / 32 - k5x	    endof  \ fine
   37 of   10 cc_val2 4 /     k5x	    endof  \ LFO Depth Mod
   38 of   4 cc_val2 2 / 24 - k5x	    endof  \ ENV Depth

\ EQ  --------------------------------------------------------------------------
   41 of  166  cc_val2 2 /  k5x endof
   42 of  167  cc_val2 2 /  k5x endof
   43 of  168  cc_val2 2 /  k5x endof
   44 of  169  cc_val2 2 /  k5x endof
   45 of  170  cc_val2 2 /  k5x endof
   46 of  171  cc_val2 2 /  k5x endof
   47 of  172  cc_val2 2 /  k5x endof
   48 of  173  cc_val2 2 /  k5x endof

\ Partials  --------------------------------------------------------------------
   51 of  181  3         k5x endof
   52 of  181  -3   k5x endof
   53 of  182  3         k5x endof
   54 of  182  -3   k5x endof
   55 of  183  3         k5x endof
   56 of  183  -3   k5x endof
   57 of  184  3         k5x endof
   58 of  184  -3   k5x endof

   68 of  39 cc_val2 42 /  k5x endof  \ angle


\ F -- ADSR (R=DSR) DDF ------------------------------------
   61 of   119 cc_val2 4 /  k5x    endof    \ Rate  1
   62 of   122 cc_val2 4 /  k5x    endof    \ Rate  4
   63 of   128 cc_val2 4 /  k5x  	 endof  \ Level 4
   69 of   123 cc_val2 4 /  k5x 	 endof  \ Rate  5  64=sustainpedal
   65 of   129 cc_val2 4 /  k5x 	 endof  \ Level 5
   66 of   124 cc_val2 4 /  k5x 	 endof  \ Rate  6

\ ------------------------------ index 2 ---------------------------------------

\ 1 -- ADSR (R=ASD) ENV ------------------------------------
   71 of    57 cc_val2 4 /  k5x    endof    \ Rate  1
   72 of    60 cc_val2 4 /  k5x    endof    \ Rate  4
   73 of    66 cc_val2 4 /  k5x  	 endof  \ Level 4
   74 of    61 cc_val2 4 /  k5x 	 endof  \ Rate  5
   75 of    67 cc_val2 4 /  k5x 	 endof  \ Level 5
   76 of    62 cc_val2 4 /  k5x 	 endof  \ Rate  6
\
\ 2 -- ADSR (R=ASD) ENV ------------------------------------
   81 of    69 cc_val2 4 /  k5x    endof    \ Rate  1
   82 of    72 cc_val2 4 /  k5x    endof    \ Rate  4
   83 of    78 cc_val2 4 /  k5x  	 endof  \ Level 4
   84 of    73 cc_val2 4 /  k5x 	 endof  \ Rate  5
   85 of    79 cc_val2 4 /  k5x 	 endof  \ Level 5
   86 of    74 cc_val2 4 /  k5x 	 endof  \ Rate  6
\
\ 3 -- ADSR (R=ASD) ENV ------------------------------------
   91 of    81 cc_val2 4 /  k5x    endof    \ Rate  1
   92 of    84 cc_val2 4 /  k5x    endof    \ Rate  4
   93 of    90 cc_val2 4 /  k5x  	 endof  \ Level 4
   94 of    85 cc_val2 4 /  k5x 	 endof  \ Rate  5
   95 of    91 cc_val2 4 /  k5x 	 endof  \ Level 5
   96 of    86 cc_val2 4 /  k5x 	 endof  \ Rate  6
\
\ 4 -- ADSR (R=ASD) ENV ------------------------------------
  101 of    93 cc_val2 4 /  k5x    endof    \ Rate  1
  102 of    96 cc_val2 4 /  k5x    endof    \ Rate  4
  103 of   102 cc_val2 4 /  k5x 	endof   \ Level 4
  109 of    97 cc_val2 4 /  k5x 	 endof  \ Rate  5  64(+index)=sustainpedal
  105 of   103 cc_val2 4 /  k5x 	 endof  \ Level 5
  106 of    98 cc_val2 4 /  k5x 	 endof  \ Rate  6
\
\ AMP mod mix ------------------------------------------------------------------
   78 of   188 cc_val2  4 /  k5x      endof    \ AMD FX env 1
   88 of   189 cc_val2  4 /  k5x	    endof  \ AMD FX env 2
   98 of   190 cc_val2  4 /  k5x	    endof  \ AMD FX env 3
  108 of   191 cc_val2  4 /  k5x	    endof  \ AMD FX env 4

   67 of   cc_val2 4 /  to RndEnv  endof  \ Global SubEnv Randomisation

   
   endcase
 ;;gp
;ap



\ -------------------- not used ------------------------------------------------
:ap k5-init

  ::gp
    64 1 do 40 i               0 i pdelay * + k5fx      \ select harmonic
		        42 i 16 /         60 i pdelay * + k5fx  \ select ENV

       loop
  ;;gp
;ap

: off-on-k5 ( n v -- e )
  to current-off-note

    current-off-note                      \ pitch
    current-off-note /n* equalArray + @   \ random-offset
    +

   midi-thru-channel  mku

;



\ master envelope syncronization (button 1)-------------------------------------

\  59 of 4 0 do
        \ ------------- rates -------------------------
\        57 i kindex * + k5r1 Krnd  40 i kdelay * + k5fx
\        58 i kindex * + k5r2 Krnd  80 i kdelay * + k5fx
\        59 i kindex * + k5r3 Krnd 120 i kdelay * + k5fx
\        60 i kindex * + k5r4 Krnd 160 i kdelay * + k5fx
\        61 i kindex * + k5r5 Krnd 200 i kdelay * + k5fx
\        62 i kindex * + k5r6 Krnd 240 i kdelay * + k5fx
\        \ ------------- levels ------------------------
\        63 i kindex * + k5l1 Krnd 280 i kdelay * + k5fx
\        64 i kindex * + k5l2 Krnd 320 i kdelay * + k5fx
\        65 i kindex * + k5l3 Krnd 360 i kdelay * + k5fx
\        66 i kindex * + k5l4 Krnd 400 i kdelay * + k5fx
\        67 i kindex * + k5l5 Krnd 440 i kdelay * + k5fx
\        68 i kindex * + k5l6 Krnd 480 i kdelay * + k5fx
\        loop
\  endof
\  19 of
\ 30 irnd to LuckyInteger
\ 64 1 do 40 i               0 i pdelay * + k5fx  \ select harmonic
\	 	  41 i VegasInteger 60 i pdelay * + k5fx  \ set level
\      loop
\  64 1 do 40 i               0 i pdelay * + k5fx  \ select harmonic
\      \  42 i  8 mod 2 /    60 i pdelay * + k5fx  \ select ENV (''--..__)
\         42 i  16 /         60 i pdelay * + k5fx  \ select ENV (4 seg)
\       loop
\  endof

quan  LuckyInteger
 6 to LuckyInteger
: VegasInteger  ( n -- n )

  dup 1 = if drop 99 exit then

  dup
  LuckyInteger
  1 max
  mod if drop 0 else 99 swap irnd - then

;

\ ------------------------------------------------------------------------------

\ ---------------------- main--------------------------------------
: k5

 \ k5-init
 
 ['] off-on      0 MIDI-action !
 ['] on-on       1 MIDI-action !
 ['] k5-control  3 MIDI-action !
 ['] mat-thru    5 MIDI-action !
 ['] mpb-thru    6 MIDI-action !
 ['] sys-action  7 MIDI-action !

;


