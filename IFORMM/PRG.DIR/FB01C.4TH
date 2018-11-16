\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

only forth also ap-defs also internals also forth definitions

\          dual FB01 is
\ default: note on, note off, continous control,
\          cc-in (Oxygen8,UC33,MS20) input to regular cc transform
\          cc-in to FB01 sys-ex transform
\          MS20 to pure-random transform [cybernetics]  


create microArray 128 /n* allot
create    chArray 128 /n* allot  
quan fb01channel 
quan fb01-visualisation?  0 to fb01-visualisation?

\ --------------------------- OFF ----------------------------------------------
: fb01-micro-off
  $gtranspose + to current-off-note drop
	    
		th f7  
        0                                      \ velocity
		current-off-note                       \ pitch
		current-off-note /n* equalArray + @    \ random-offset
		+
		current-off-note /n* microArray + @    \ 100 cent		 
		swap th 10 
		current-off-note /n*    chArray + @ or \ channel 
		th 70 th 75 th 43 th f0 
        9 ['] MIDI-command-event event
       
	    
;

\ ----------------------------------- ON ---------------------------------------
quan u$rnd

\ quan last-x
:  micro-thru-display 
      
   cur-SVT th 1fff and 12 /  
   \ dup dup   
   \ last-x < if erase-screen then      
   \ to last-x
      
   offset-note current-note + 4* offset-cent 30 / +
   negate 436 +  
   400 min
   1 !pix 
    
;
 

  
:ap  fb01-micro-on

   ::ap current-note 0 = if rnd-bubble then ;;ap    \ trigger process
   ::gp [ 2 params ]
        $gtranspose + to current-note
                      to current-velocity
	
\ Paramter Change thru key and velocity (pianistical sound control)
\ <!-- hard to control -->
\   current-note case
\ freq
\	17 of 0 current-velocity  dup 20 20 say.  8 / 7 irnd fre-dt active-exit endof
\	19 of 1 current-velocity  dup 20 40 say.  8 / 7 irnd fre-dt active-exit endof
\	21 of 2 current-velocity  dup 20 60 say.  8 / 7 irnd fre-dt active-exit endof
\	23 of 3 current-velocity  dup 20 80 say.  8 / 7 irnd fre-dt active-exit endof
\ fout
\	18 of 0 current-velocity  dup 60 20 say.   fout active-exit endof
\	20 of 1 current-velocity  dup 60 40 say.   fout active-exit endof
\	22 of 2 current-velocity  dup 60 60 say.   fout active-exit endof
\	24 of 3 current-velocity  dup 60 80 say.   fout active-exit endof
\					       endcase
						    

	magic-number
    master-transpose + to offset-note

  current-note offset-note + dup       \ actual note
  127 > swap 1 < or                    \ exceed boundaries?
  if active-exit then                  \ exit

  u$rnd irnd                           \ microtuning offset
  to offset-cent
  fb01max irnd to fb01channel	       \ distribute among all FB01s  


	
	 offset-note current-note /n* equalArray + !  	    \ keep pitch
	 offset-cent current-note /n* microArray + !        \ keep 100 cent
	 fb01channel current-note /n*    chArray + !        \ keep channel 
	  
	    th f7
        current-velocity                            \ velocity
		  current-note offset-note +                \ pitch
		  offset-cent  
		  swap th 10 fb01channel or th 70 th 75 th 43 th f0 
          9 ['] MIDI-command-event event

   
	\ micro-thru-display
    ;;gp
;ap


\ --------------------------FB01 transform -------------------------------------
\ transforms cc to sys-ex for fb01

quan su1  12 to su1
quan su2  12 to su2
quan su3  12 to su3
quan su4  12 to su4

quan vs1   2 to vs1
quan vs2   2 to vs2
quan vs3   2 to vs3
quan vs4   2 to vs4

quan am?1  0 to am?1   \ carrier: no, modulators: yes
quan am?2  1 to am?2
quan am?3  1 to am?3
quan am?4  1 to am?4

quan d11   8 to d11
quan d12   8 to d12
quan d13   8 to d13
quan d14   8 to d14

quan d21   0 to d21
quan d22   0 to d22
quan d23   0 to d23
quan d24   0 to d24

quan if1   0 to if1
quan if2   0 to if2
quan if3   0 to if3
quan if4   0 to if4

quan re1  12 to re1
quan re2  12 to re2
quan re3  12 to re3
quan re4  12 to re4

quan op1   1 to op1
quan op2   1 to op2
quan op3   1 to op3
quan op4   1 to op4

quan Crnd
quan base_freq
quan fb   0 to fb
quan alg  0 to alg

quan ModInit 0 to ModInit

\ *** default *** : 2 FB01's with MIDI-channel on 1 and 2, System-Channel on 1
: fb01-init  
   0 to midi-thru-channel
   2 to fb01max                
   2 to maxChannels            \ Midi-channel
   0 to para-channel           \ system channel

ModInit if
         7 3 ps-as             \ set PMD and AMD to max
  3  d11 0 0 d1-v-             \ carrier ON modulators OFF (best estimate)   
  2  d11 0 1 d1-v-
  1  d11 0 1 d1-v-
  0  d11 0 1 d1-v-
  
  3 0 do i 0 0 a-lsd loop      \ adjust and levelscalingdepth: off
        then

;




: fb01-thru  ( v p -- )
 

  to cc_val1       			\ get the current parameters
  to cc_val2

  

\ sustain pedal ----------------------------------------------------------------
  cc_val1 64 =
  if 
   fb01max 0 
   do
   cc_val2 cc_val1 midi-thru-channel i + mcc 
   loop 
  exit then

\ pitch randomization ----------------------------------------------------------
  cc_val1 1 =      \ mod wheel
  if cc_val2 to $rnd exit then

\ catch Volume control and make index ------------------------------------------
\  cc_val1 7 =
\  if cc_val2 10 / 10 * to cc_index exit then

\ catch Volume control and make index ----------------------------------------
  cc_val1 7 = 
  if
 \ cc_val2   0 = if -10 to cc_index exit then
 \ cc_val2 127 = if -20 to cc_index exit then
  cc_val2     1 = if -30 to cc_index exit then
  cc_val2    41 = if  0 to cc_index exit then
  cc_val2    81 = if 40 to cc_index exit then
  cc_val2   121 = if 80 to cc_index exit then
  then
  
  
\ general ======================================================================  
  cc_val1   
  case 

\ ------- hidden modulator index -----------------------------------------------
 109 of    08  cc_val2 
               2/ 64 +   \ scale: 0-127 to 64->127 (better resolution)
               setconf  exit endof 

\ ---------- LFO ---------------------------------------------------------------
  9 of   cc_val2 2* lfos 	exit		endof
  10 of   cc_val2 0  pd-s 	exit		endof
\ ---------- base freq ---------------------------------------------------------
  11 of     cc_val2 8 /  to base_freq endof
\ ---------- random freq -------------------------------------------------------
  12 of   3 base_freq Crnd 8 / grnd +  7 irnd  fre-dt
          2 base_freq Crnd 8 / grnd +  7 irnd  fre-dt
          1 base_freq Crnd 8 / grnd +  7 irnd  fre-dt
		  0 base_freq Crnd 8 / grnd +  7 irnd  fre-dt
		  3 d21 Crnd 42 / irnd  dup to if1 d2-if
          2 d22 Crnd 42 / irnd  dup to if2 d2-if
		  1 d23 Crnd 42 / irnd  dup to if3 d2-if
          0 d24 Crnd 42 / irnd  dup to if4 d2-if
				  endof

\ ---------- Op 4 (3) feedback -------------------------------------------------
   13 of  alg  cc_val2 16 / dup to fb  alg-f exit endof
\ ---------- LFO ---------------------------------------------------------------
   14 of   cc_val2 1                    ad-l exit endof
   15 of   cc_val2 31 /		              wf exit endof
\ ------- random freq (index) --------------------------------------------------
   16 of   cc_val2 to Crnd 		  			       exit endof
\ ------- algorithm ------------------------------------------------------------
   17 of   cc_val2      dup to alg  fb alg-f exit endof      \ (0-7)
 
  
\ experimental-algorithm-control
\	77 of cc_val2 0 ccSlider endof 
\	78 of cc_val2 1 ccSlider endof
\	
\	97 of cc_val2 1 max 2  ccSlider endof    \ x/ 
\	98 of cc_val2 1 max 4  ccSlider endof    \ /y
\	95 of cc_val2 1 max 3  ccSlider endof    \ x/
\	96 of cc_val2 1 max 5  ccSlider endof    \ /y
			
\   94 of cc_val2 7 1 max ccSlider endof 	\ vel r

\ irnd - frnd - nrnd : switches ------------------------------------------------
  18 of
     cc_val2 case 
	 0 of   ['] uniform-around-center is magic-number endof
	 43 of  ['] 1/f-around-center is magic-number endof
	 85 of  ['] neumann-around-center is magic-number endof
     endcase
  endof

\ master transpose -------------------------------------------------------------
  19 of
     cc_val2 case 
	 0 of   -24 to master-transpose endof
	 43 of  -12 to master-transpose endof
	 85 of    0 to master-transpose endof
	 127 of  12 to master-transpose endof
     endcase
  endof

  endcase 

\ ============================================================================== 
 


\ - indexed --------------------------------------------------------------------
\ ==============================================================================
  cc_val1
  cc_index +
  case 
  
  \ - 1 --------------------------------------------------------------------------
  31 of 3      cc_val2  4 / 31 - negate 0                 at-rsd endof
  32 of 3      cc_val2  4 / 31 - negate dup to d11 0 am?1 d1-v-  endof
  33 of 3      cc_val2  8 / 15 - negate dup to su1 re1  su-re  endof
  34 of 3      cc_val2  4 / 31 - negate dup to d21 if1  d2-if  endof
  35 of 3  su1 cc_val2  8 / 15 - negate dup to re1      su-re  endof
  36 of 3  d21 cc_val2 42 / dup to if1      d2-if  endof
  37 of 3      cc_val2  8 / dup to base_freq 7 irnd          fre-dt endof
  38 of 3      cc_val2          	   	      fout   endof
\ - 2 --------------------------------------------------------------------------
  41 of 2      cc_val2 4 / 31 - negate 0                at-rsd endof
  42 of 2      cc_val2 4 / 31 - negate dup to d12 0 am?2 d1-v- endof
  43 of 2      cc_val2 8 / 15 - negate dup to su2 re2  su-re  endof
  44 of 2      cc_val2 4 / 31 - negate dup to d22 if2  d2-if  endof
  45 of 2  su2 cc_val2 8 / 15 - negate dup to re2      su-re  endof
  46 of 2  d22 cc_val2 42 / dup to if2     d2-if  endof
  47 of 2      cc_val2 8 / 7 irnd          fre-dt endof
  48 of 2      cc_val2          	         fout   endof
\ - 3 --------------------------------------------------------------------------
  51 of 1      cc_val2 4 / 31 - negate 0 		              at-rsd endof
  52 of 1      cc_val2 4 / 31 - negate dup to d13 0 am?3  d1-v-  endof
  53 of 1      cc_val2 8 / 15 - negate dup to su3 re3  su-re  endof
  54 of 1      cc_val2 4 / 31 - negate dup to d23 if3  d2-if  endof
  55 of 1  su3 cc_val2 8 / 15 - negate dup to re3      su-re  endof
  56 of 1  d23 cc_val2 42 / dup to if3     d2-if  endof
  57 of 1      cc_val2 8 / 7 irnd          fre-dt endof
  58 of 1      cc_val2          	         fout   endof
\ - 4 --------------------------------------------------------------------------
  61 of 0      cc_val2 4 / 31 - negate 0       	          at-rsd endof
  62 of 0      cc_val2 4 / 31 - negate dup to d14 0 am?4  d1-v-  endof
  63 of 0      cc_val2 8 / 15 - negate dup to su4 re4  su-re  endof
\ 64 is sustain pedal so:  
  69 of 0      cc_val2 4 / 31 - negate dup to d24 if4  d2-if  endof  
  65 of 0  su4 cc_val2 8 / 15 - negate dup to re4      su-re  endof
  66 of 0  d24 cc_val2 42 / dup to if4     d2-if  endof
  67 of 0      cc_val2 8 / 7 irnd          fre-dt endof
  68 of 0      cc_val2          	         fout   endof

\ - 1 --------------------------------------------------------------------------
  71 of 3      cc_val2 16 /  vs endof                    \ velocity
  72 of 2      cc_val2 16 /  vs endof                    \ velocity
  73 of 1      cc_val2 16 /  vs endof                    \ velocity
  74 of 0      cc_val2 16 /  vs endof                    \ velocity
  75 of 3  d11 0  cc_val2 64 / dup to am?1  d1-v-        \ AmplitudeModulation?
        3  am?1 if 0 else 31 then 0 a-lsd         endof  \ adjust(min) output
  76 of 2  d11 0  cc_val2 64 / dup to am?2  d1-v-        \ AmplitudeModulation?
        2  am?2 if 0 else 31 then  0  a-lsd       endof  \ adjust(min) output
  77 of 1  d11 0  cc_val2 64 / dup to am?3  d1-v-        \ AmplitudeModulation?
        1  am?3 if 0 else 31 then  0  a-lsd       endof  \ adjust(min) output
  78 of 0  d11 0  cc_val2 64 / dup to am?4  d1-v-        \ AmplitudeModulation?
        0  am?4 if 0 else 31 then  0  a-lsd       endof  \ adjust(min) output

\ ---------------------- portamento --------------------------------------------
  81 of    11  cc_val2 setconf  endof
\ ------------ microtuning and pitch random distribution -----------------------
  82 of cc_val2 to u$rnd      endof
   1 of cc_val2 to  $rnd      endof  \ mod wheel
\ ------------------------------------------------------------------------------
  83 of     7  cc_val2 25 / setconf  endof               \ octave trans
  84 of     6  cc_val2      setconf  endof               \ detune

  \ - operators 1-4 ------------------------------------------------------------
  151 of 4 0 do i      cc_val2  4 / 31 - negate 0 at-rsd loop endof
  152 of 3 cc_val2  4 / 31 - negate dup to d11 0 am?1 d1-v- 
         2 cc_val2  4 / 31 - negate dup to d12 0 am?2 d1-v-
		 1 cc_val2  4 / 31 - negate dup to d13 0 am?3 d1-v-
	     0 cc_val2  4 / 31 - negate dup to d14 0 am?4 d1-v-
	  endof
  153 of 3 cc_val2  8 / 15 - negate dup to su1 re1  su-re 
         2 cc_val2  8 / 15 - negate dup to su2 re2  su-re
		 1 cc_val2  8 / 15 - negate dup to su3 re3  su-re
		 0 cc_val2  8 / 15 - negate dup to su4 re4  su-re
      endof
  154 of 3 cc_val2  4 / 31 - negate dup to d21 if1  d2-if
         2 cc_val2  4 / 31 - negate dup to d22 if2  d2-if
         1 cc_val2  4 / 31 - negate dup to d23 if3  d2-if
         0 cc_val2  4 / 31 - negate dup to d24 if4  d2-if 
      endof
  155 of 3  su1 cc_val2  8 / 15 - negate dup to re1 su-re 
         2  su1 cc_val2  8 / 15 - negate dup to re2 su-re
		 1  su1 cc_val2  8 / 15 - negate dup to re3 su-re
		 0  su1 cc_val2  8 / 15 - negate dup to re4 su-re
  
      endof
  156 of 3 d21 cc_val2 42 / dup to if1      d2-if 
         2 d22 cc_val2 42 / dup to if2      d2-if 
		 1 d23 cc_val2 42 / dup to if3      d2-if 
		 0 d24 cc_val2 42 / dup to if4      d2-if 
      endof
  157 of 4 0 do i cc_val2  8 / 7 irnd  fre-dt loop endof
  158 of 4 0 do i cc_val2               fout  loop  endof

 
  endcase
 

\ - NOT USED -------------------------------------------------------------------
\   73 of   cc_val2 64 / dup to op1 op2 op3 op4 oof endof  \ Operator on/off
\   83 of   op1 cc_val2 64 / dup to op2 op3 op4 oof endof  \ Operator on/off
\   93 of   op1 op2 cc_val2 64 / dup to op3 op4 oof endof  \ Operator on/off
\  103 of   op1 op2 op3 cc_val2 64 / dup to op4 oof endof  \ Operator on/off
\ ---------------------- pan ---------------------------------------------------
\  75 of     9  cc_val2 setconf  endof

\ ************** Visualizer ****************************************************
   fb01-visualisation? if
   erase-screen
   cc_val1 300 350 say.
   cc_val2 320 350 say.
   cur-SVT th 1fff and 12 /  x1 !
                    300 irnd y1 !
                     cc_val2 x2 !
                     cc_val1 y2 !
   box(unfilled)
   then
   
;


: fb01

  fb01-init
  
\  ['] fb01-micro-off 0 MIDI-action !
  ['] noop           0 MIDI-action !
  ['] fb01-micro-on  1 MIDI-action !
  ['] fb01-thru      3 MIDI-action !
  ['] mat-thru       5 MIDI-action !
  ['] mpb-thru       6 MIDI-action !
  ['] sys-action     7 MIDI-action !

;


