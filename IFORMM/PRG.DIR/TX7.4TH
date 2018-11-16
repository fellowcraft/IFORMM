\ Copyright (c) 1987-2013 by Frank Holger Rothkamm.  All rights reserved.

\ .................//////////////////////////////////////////////...............
\ -----------------                  T  X   7                   ---------------
\ .................\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\...............

quan all_levels  0 to all_levels


: TX7-control    \ 15 to para-channel

  cc_val1
  cc_index +   
  case

    \ LFO -------------------------------------------------------
   241 of  1          9            cc_val2 100 * 128 / dx7 endof \ LFO speed
   242 of  1         11            cc_val2 100 * 128 / dx7 endof \ LFO PMD
   243 of  1         15            cc_val2        16 / dx7 endof \ LFO PMD sens
   244 of  1          7            cc_val2        16 / dx7 endof \ feedback
    \ ------------------------------------------------------------
   245 of  1         12            cc_val2 100 * 128 / dx7 endof \ LFO AMD
   246 of  1         14            cc_val2  10 * 213 / dx7 endof \ LFO wave
   247 of  1         10            cc_val2 100 * 128 / dx7 endof \ LFO delay
   248 of  1          6            cc_val2             dx7 endof \ algorithm
    \ pitch EG ---------------------------------------------------
   231 of  0        126            cc_val2 100 * 128 / dx7 endof \ Rate 1
   232 of  1          2            cc_val2 100 * 128 / dx7 endof \ Level 1
   233 of  0        127            cc_val2 100 * 128 / dx7 endof \ Rate 2
   234 of  1          3            cc_val2 100 * 128 / dx7 endof \ Level 2
   235 of  1          0            cc_val2 100 * 128 / dx7 endof \ Rate 3 
   236 of  1          4            cc_val2 100 * 128 / dx7 endof \ Level 3
   237 of  1          1            cc_val2 100 * 128 / dx7 endof \ Rate 4
   238 of  1          5            cc_val2 100 * 128 / dx7 endof \ Level 4
    
\	86 of  1          2            cc_val2 100 * 128 / dx7
\	       1          3            cc_val2 100 * 128 / dx7
\	       1          4            cc_val2 100 * 128 / dx7
\		   1          5            cc_val2 100 * 128 / dx7 endof
\		   
\	87  of                         cc_val2         8 / to all_levels endof
  
\ experimental-algorithm-control -----------------------------------------------
\	77 of cc_val2 0 ccSlider endof 
\	78 of cc_val2 1 ccSlider endof
	
\	97 of cc_val2 1 max 2  ccSlider endof    \ x/ 
\	98 of cc_val2 1 max 4  ccSlider endof    \ /y
\	95 of cc_val2 1 max 3  ccSlider endof    \ x/
\	96 of cc_val2 1 max 5  ccSlider endof    \ /y
			
\    94 of cc_val2 7 1 max ccSlider endof 	\ vel rnd	  
   
  endcase 
 
  cc_val1
  cc_index +   
  case
 
  \ ----|subgroup|group--------|data-------------------------------------------|
  \ envelope op 1 ----------------------------------------------
  31 of  0        0  5 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  1
  32 of  0        4  5 21 * +   cc_val2 100 * 128 / dx7 endof \ level 1
  33 of  0        1  5 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  2
  34 of  0        5  5 21 * +   cc_val2 100 * 128 / dx7 endof \ level 2 
  35 of  0        2  5 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  3
  36 of  0        6  5 21 * +   cc_val2 100 * 128 / dx7 endof \ level 3
  37 of  0        3  5 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  4
  38 of  0        7  5 21 * +   cc_val2 100 * 128 / dx7 endof \ level 4
  \ others op 1 ------------------------------------------------
  41 of  0        20  5 21 * +   cc_val2 100 *  85 / dx7 endof \ detune
  42 of  0        19  5 21 * +   cc_val2 100 * 128 / dx7 endof \ freq fine
  43 of  0        18  5 21 * +   cc_val2         4 / dx7 endof \ freq coarse
  44 of  0        16  5 21 * +   cc_val2 100 * 128 / dx7 endof \ output level
  \ ------------------------------------------------------------
  45 of  0        17  5 21 * +   cc_val2        64 / dx7 endof \ osc mode
  46 of  0        15  5 21 * +   cc_val2        16 / dx7 endof \ velocity
  47 of  0        14  5 21 * +   cc_val2        32 / dx7 endof \ LFO AMD sens
  48 of  0        13  5 21 * +   cc_val2        16 / dx7 endof \ rate scaling
  \ envelope op 2 ----------------------------------------------
  51 of  0        0  4 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  1
  52 of  0        4  4 21 * +   cc_val2 100 * 128 / dx7 endof \ level 1
  53 of  0        1  4 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  2
  54 of  0        5  4 21 * +   cc_val2 100 * 128 / dx7 endof \ level 2 
  55 of  0        2  4 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  3
  56 of  0        6  4 21 * +   cc_val2 100 * 128 / dx7 endof \ level 3
  57 of  0        3  4 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  4
  58 of  0        7  4 21 * +   cc_val2 100 * 128 / dx7 endof \ level 4
  \ others op 2 ------------------------------------------------
  61 of  0        20  4 21 * +   cc_val2 100 *  85 / dx7 endof \ detune
  62 of  0        19  4 21 * +   cc_val2 100 * 128 / dx7 endof \ freq fine
  63 of  0        18  4 21 * +   cc_val2         4 / dx7 endof \ freq coarse
  64 of  0        16  4 21 * +   cc_val2 100 * 128 / dx7 endof \ output level
  \ ------------------------------------------------------------
  65 of  0        17  4 21 * +   cc_val2        64 / dx7 endof \ osc mode
  66 of  0        15  4 21 * +   cc_val2        16 / dx7 endof \ velocity
  67 of  0        14  4 21 * +   cc_val2        32 / dx7 endof \ LFO AMD sens
  68 of  0        13  4 21 * +   cc_val2        16 / dx7 endof \ rate scaling  
  \ envelope op 3 ----------------------------------------------
  71 of  0        0  3 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  1
  72 of  0        4  3 21 * +   cc_val2 100 * 128 / dx7 endof \ level 1
  73 of  0        1  3 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  2
  74 of  0        5  3 21 * +   cc_val2 100 * 128 / dx7 endof \ level 2 
  75 of  0        2  3 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  3
  76 of  0        6  3 21 * +   cc_val2 100 * 128 / dx7 endof \ level 3
  77 of  0        3  3 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  4
  78 of  0        7  3 21 * +   cc_val2 100 * 128 / dx7 endof \ level 4
  \ others op 3 ------------------------------------------------
  81 of  0        20  3 21 * +   cc_val2 100 *  85 / dx7 endof \ detune
  82 of  0        19  3 21 * +   cc_val2 100 * 128 / dx7 endof \ freq fine
  83 of  0        18  3 21 * +   cc_val2         4 / dx7 endof \ freq coarse
  84 of  0        16  3 21 * +   cc_val2 100 * 128 / dx7 endof \ output level
  \ ------------------------------------------------------------
  85 of  0        17  3 21 * +   cc_val2        64 / dx7 endof \ osc mode
  86 of  0        15  3 21 * +   cc_val2        16 / dx7 endof \ velocity
  87 of  0        14  3 21 * +   cc_val2        32 / dx7 endof \ LFO AMD sens
  88 of  0        13  3 21 * +   cc_val2        16 / dx7 endof \ rate scaling
  \ envelope op 4 ----------------------------------------------
  91 of  0        0  2 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  1
  92 of  0        4  2 21 * +   cc_val2 100 * 128 / dx7 endof \ level 1
  93 of  0        1  2 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  2
  94 of  0        5  2 21 * +   cc_val2 100 * 128 / dx7 endof \ level 2 
  95 of  0        2  2 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  3
  96 of  0        6  2 21 * +   cc_val2 100 * 128 / dx7 endof \ level 3
  97 of  0        3  2 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  4
  98 of  0        7  2 21 * +   cc_val2 100 * 128 / dx7 endof \ level 4
  \ others op 4 ------------------------------------------------
  101 of  0        20  2 21 * +   cc_val2 100 *  85 / dx7 endof \ detune
  102 of  0        19  2 21 * +   cc_val2 100 * 128 / dx7 endof \ freq fine
  103 of  0        18  2 21 * +   cc_val2         4 / dx7 endof \ freq coarse
  104 of  0        16  2 21 * +   cc_val2 100 * 128 / dx7 endof \ output level
  \ ------------------------------------------------------------
  105 of  0        17  2 21 * + cc_val2        64 / dx7 endof \ osc mode
  106 of  0        15  2 21 * + cc_val2        16 / dx7 endof \ velocity
  107 of  0        14  2 21 * + cc_val2        32 / dx7 endof \ LFO AMD sens
  108 of  0        13  2 21 * + cc_val2        16 / dx7 endof \ rate scaling
  \ envelope op 5 ----------------------------------------------
  111 of  0        0  1 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  1
  112 of  0        4  1 21 * +   cc_val2 100 * 128 / dx7 endof \ level 1
  113 of  0        1  1 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  2
  114 of  0        5  1 21 * +   cc_val2 100 * 128 / dx7 endof \ level 2 
  115 of  0        2  1 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  3
  116 of  0        6  1 21 * +   cc_val2 100 * 128 / dx7 endof \ level 3
  117 of  0        3  1 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  4
  118 of  0        7  1 21 * +   cc_val2 100 * 128 / dx7 endof \ level 4
  \ others op 5 ------------------------------------------------
  121 of  0        20  1 21 * +   cc_val2 100 *  85 / dx7 endof \ detune
  122 of  0        19  1 21 * +   cc_val2 100 * 128 / dx7 endof \ freq fine
  123 of  0        18  1 21 * +   cc_val2         4 / dx7 endof \ freq coarse
  124 of  0        16  1 21 * +   cc_val2 100 * 128 / dx7 endof \ output level
  \ ------------------------------------------------------------
  125 of  0        17  1 21 * +   cc_val2        64 / dx7 endof \ osc mode
  126 of  0        15  1 21 * +   cc_val2        16 / dx7 endof \ velocity
  127 of  0        14  1 21 * +   cc_val2        32 / dx7 endof \ LFO AMD sens
  128 of  0        13  1 21 * +   cc_val2        16 / dx7 endof \ rate scaling
  \ envelope op 6 -----------------------------------------------
  131 of  0        0  0 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  1
  132 of  0        4  0 21 * +   cc_val2 100 * 128 / dx7 endof \ level 1
  133 of  0        1  0 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  2
  134 of  0        5  0 21 * +   cc_val2 100 * 128 / dx7 endof \ level 2 
  135 of  0        2  0 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  3
  136 of  0        6  0 21 * +   cc_val2 100 * 128 / dx7 endof \ level 3
  137 of  0        3  0 21 * +   cc_val2 100 * 128 / dx7 endof \ rate  4
  138 of  0        7  0 21 * +   cc_val2 100 * 128 / dx7 endof \ level 4
  \ others op 6 ------------------------------------------------
  141 of  0        20  0 21 * +   cc_val2 100 *  85 / dx7 endof \ detune
  142 of  0        19  0 21 * +   cc_val2 100 * 128 / dx7 endof \ freq fine
  143 of  0        18  0 21 * +   cc_val2         4 / dx7 endof \ freq coarse
  144 of  0        16  0 21 * +   cc_val2 100 * 128 / dx7 endof \ output level
  \ ------------------------------------------------------------
  145 of  0        17  0 21 * +   cc_val2        64 / dx7 endof \ osc mode
  146 of  0        15  0 21 * +   cc_val2        16 / dx7 endof \ velocity
  147 of  0        14  0 21 * +   cc_val2        32 / dx7 endof \ LFO AMD sens
  148 of  0        13  0 21 * +   cc_val2        16 / dx7 endof \ rate scaling

  \ envelope op 1-6 -----------------------------------------------
  151 of  6 0 do 0 0  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ rate  1
  152 of  6 0 do 0 4  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ level 1
  153 of  6 0 do 0 1  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ rate  2
  154 of  6 0 do 0 5  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ level 2 
  155 of  6 0 do 0 2  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ rate  3
  156 of  6 0 do 0 6  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ level 3
  157 of  6 0 do 0 3  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ rate  4
  158 of  6 0 do 0 7  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ level 4
  \ others op 1-6 ------------------------------------------------
  161 of  6 0 do 0 18  i 21 * +   cc_val2         4 / dx7 loop endof \ freq coar
  162 of  6 0 do 0 19  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ freq fine
  163 of  6 0 do 0 20  i 21 * +   cc_val2 100 *  85 / dx7 loop endof \ detune
  164 of  6 0 do 0 16  i 21 * +   cc_val2 100 * 128 / dx7 loop endof \ output le
  \ ------------------------------------------------------------
  165 of  6 0 do 0 17  i 21 * +   cc_val2        64 / dx7 loop endof \ osc mode
  166 of  6 0 do 0 15  i 21 * +   cc_val2        16 / dx7 loop endof \ velocity
  167 of  6 0 do 0 14  i 21 * +   cc_val2        32 / dx7 loop endof \ LFO AMD s
  168 of  6 0 do 0 13  i 21 * +   cc_val2        16 / dx7 loop endof \ rate scal

  endcase

;

: TX7.LFO.sync ( 1|0 -- )
  1 13 rot dx7    
;


\ ---------------------- main---------------------------------------------------
: TX7-thru
\  MS20
  to cc_val1       			\ get the current parameters 
  to cc_val2
 
\   cc_val1 . 
\   cc_val2 . cr
 
\  DataEntry to FC--------------------------------------------------------------
  cc_val1 7 = 
  if cc_val2       4 midi-thru-channel mcc exit then
 
\  Sustain Pedal  --------------------------------------------------------------
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
\  cc_val1 7 = 
\  if
 \ cc_val2   0 = if -10 to cc_index exit then
 \ cc_val2 127 = if -20 to cc_index exit then
\  cc_val2     1 = if   0 to cc_index exit then
\  cc_val2    41 = if  40 to cc_index exit then
\  cc_val2    81 = if  80 to cc_index exit then
\  cc_val2   121 = if 120 to cc_index exit then
\    cc_val2 10 / 10 * to cc_index exit
\  then      
 
  TX7-control
  
;

create all_level_offsets_1 127 , 1 , 3 , 5 ,
create all_level_offsets_2   0 , 1 , 1 , 1 ,
quan   current_offset    0 to current_offset

: TX7-on-on
  
  to current-note 
  to current-velocity

\ catch high octave and make index ---------------------------------------------
 current-velocity 120 > if
  current-note 85 = if 200 to cc_index exit then  
  current-note 86 = if   0 to cc_index exit then
  current-note 87 = if  20 to cc_index exit then
  current-note 88 = if  40 to cc_index exit then
  current-note 89 = if  60 to cc_index exit then
  current-note 90 = if  80 to cc_index exit then
  current-note 91 = if 100 to cc_index exit then
  current-note 92 = if 110 to cc_index exit then
  current-note 93 = if 120 to cc_index exit then
  current-note 94 = if 130 to cc_index exit then
  current-note 95 = if 140 to cc_index exit then
  current-note 96 = if 150 to cc_index exit then
 endif

\  \ round robin of pitch envelope -> tuning  
\  all_level_offsets_2 current_offset /n* + @
\  all_level_offsets_1 current_offset /n* + @ 
\  all_levels
\  dx7
\  current_offset 1+ 3 and to current_offset   \ round robin
  
  all_levels 0 > if
  all_levels irnd all_levels 2/ - 50 + to current_offset
  1          2            current_offset dx7
  1          3            current_offset dx7
  1          4            current_offset dx7
  1          5            current_offset dx7
                  then 
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


: test-patch

  . cr
;

: tx7

  ['] off-on     0 MIDI-action !

  ['] TX7-on-on  1 MIDI-action !
      
  ['] TX7-thru   3 MIDI-action !
  
\ ['] test-patch 4 MIDI-action ! 
   
  ['] mat-thru   5 MIDI-action !

  ['] mpb-thru   6 MIDI-action !

  ['] sys-action 7 MIDI-action !

;
