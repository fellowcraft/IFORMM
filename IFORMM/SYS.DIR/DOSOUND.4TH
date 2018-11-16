\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\  1990/99/04   	                  
\  This is a furious attempt to make the YM Sound Chip swing 
\  works now like a MIDI device: 
\  YM-note-on  ( velocity pitch  voice 0 1 2  -- ) 
\  YM-note-off (          pitch  voice 0 1 2 -- ) 

\   'Dosound()' ist der Makro fuer die XBIOS-Funktion 32.

32 xbios: Dosound  { l.addr -- } 

create YMsound

\ ===================\ Atari ST soundchip Yamaha YM2149 /=================================
\ 
\                     $FF8800|byte |Read data/Register select                            |R/W
\ -----------------  \ +-----------------------------------------------------------------+      
0 c,           50 c, \       |     |0 Channel A Freq Low              BIT 7 6 5 4 3 2 1 0|
1 c,            1 c, \       |     |1 Channel A Freq High                     BIT 3 2 1 0|
2 c,           80 c, \       |     |2 Channel B Freq Low              BIT 7 6 5 4 3 2 1 0|
3 c,            1 c, \       |     |3 Channel B Freq High                     BIT 3 2 1 0|
4 c,          120 c, \       |     |4 Channel C Freq Low              BIT 7 6 5 4 3 2 1 0|
5 c,            1 c, \       |     |5 Channel C Freq High                     BIT 3 2 1 0|
6 c,           20 c, \       |     |6 Noise Freq                          BIT 5 4 3 2 1 0|
7 c,  tb 11110001 c, \       |     |7 Mixer Control                   BIT 7 6 5 4 3 2 1 0|
                     \       |     |  Port B IN/OUT (1=Output) -----------' | | | | | | ||
                     \       |     |  Port A IN/OUT ------------------------' | | | | | ||
                     \       |     |  Channel C Noise (1=Off) ----------------' | | | | ||
                     \       |     |  Channel B Noise --------------------------' | | | ||
                     \       |     |  Channel A Noise ----------------------------' | | ||
                     \       |     |  Channel C Tone (0=On) ------------------------' | ||
                     \       |     |  Channel B Tone ---------------------------------' ||
                     \       |     |  Channel A Tone -----------------------------------'|
8 c,  tb 00001111 c, \       |     |8 Channel A Amplitude Control           BIT 4 3 2 1 0|
                     \       |     |  Fixed/Variable Level (0=Fixed) -----------' | | | ||
                     \       |     |  Amplitude level control --------------------+-+-+-'|
9 c,  tb 00001111 c, \       |     |9 Channel B Amplitude Control           BIT 4 3 2 1 0|
                     \       |     |  Fixed/Variable Level ---------------------' | | | ||
                     \       |     |  Amplitude level control --------------------+-+-+-'|
10 c, tb 00001111 c, \       |     |10 Channel C Amplitude Control          BIT 4 3 2 1 0|
                     \       |     |  Fixed/Variable Level ---------------------' | | | ||
                     \       |     |  Amplitude level control --------------------+-+-+-'|
11 c,         100 c, \       |     |11 Envelope Period High           BIT 7 6 5 4 3 2 1 0|
12 c,           2 c, \       |     |12 Envelope Period Low            BIT 7 6 5 4 3 2 1 0|
13 c, tb 00001010 c, \       |     |13 Envelope Shape                         BIT 3 2 1 0|
                     \       |     |  Continue -----------------------------------' | | ||
                     \       |     |  Attack ---------------------------------------' | ||
                     \       |     |  Alternate --------------------------------------' ||
                     \       |     |  Hold ---------------------------------------------'|
                     \       |     |   00xx - \____________________________________      |
                     \       |     |   01xx - /|___________________________________      |
                     \       |     |   1000 - \|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\      |
                     \       |     |   1001 - \____________________________________      |
                     \       |     |   1010 - \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\      |
                     \       |     |   1011 - \|-----------------------------------      |
                     \       |     |   1100 - /|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/      |
                     \       |     |   1101 - /------------------------------------      |
                     \       |     |   1110 - /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/      |
                     \       |     |   1111 - /|___________________________________      |

: YM-note-on-old
 ( velocity:0-15  pitch:0_4104  voice:0_1_2  -- )
      dup >r        \ voice
      4*  >r        \ offset for pitch 
      dup
 8 >> dup YMsound  r@ 3 + \ 12bit intopo
                  +  c!    \ 8 bit high
 8 << - YMsound   r> 1+   \ 4 bit low   
                  + c! 

     r> 2*       \ offset for velocity  
   YMsound 17 + + c! 

   YMsound Dosound 

;



quan YM_velocity
quan YM_pitch
quan YM_voice

: YM-note-on
 ( velocity:0-15  pitch:0_4104  voice:0_1_2  -- )
    
	
	  dup >r        \ voice
      4*  >r        \ offset for pitch 
      dup
 8 >> dup YMsound  r@ 3 + \ 12bit intopo
                  +  c!    \ 8 bit high
 8 << - YMsound   r> 1+   \ 4 bit low   
                  + c! 

     r> 2*       \ offset for velocity  
   YMsound 17 + + c! 

   YMsound Dosound 

;

: MIDI-YM-on 
  to current-note 
  to current-velocity
  current-velocity 3 >> current-note 1 YM-note-on 
;

: YM-note-off 
  ( pitch voice_0_1_2  -- )  
    0 -rot  YM-note-on 
; 

: MIDI-YM-off 
   2drop
  \ drop 50 irnd 31 * 0 YM-note-off 
;

: YM
 ['] MIDI-YM-off      0 MIDI-action !
 ['] MIDI-YM-on       1 MIDI-action !  

;

:ap playYM
::ap" chip"

begin 
     31 999 irnd 1 YM-note-on
  1 brnd if 8 else 16 then tel r $

     31 2104 irnd 2 YM-note-on      
  1 brnd if 8 else 16 then tel r $ 
again 
;;ap
;ap   



\ create YMsound_3

\ 0 c,  100 c, 
\ 1 c,  3 c, 

\ 2 c,  232 c,   
\ 3 c,  3 c, 

\ 4 c, 255 c, 
\ 5 c,  8 c, 


\ 6 c, 0 c,
\ 7 c, tb 00111000  c,  \ all sounds on = 120

 \ Amplitude  Huellkurve an/aus  0-15

\ 8  c, tb 00001111 c,  
\ 9  c, tb 00001111 c,  
\ 10 c, tb 00001111 c, 


\ 11 c, 64 c,
 
\ 12 c, 156 c, 
\ 13 c, 0 c, 

\ 128 c, 1 c, 
\ 129 c, 0 c, 19 c, 1 c, 
\ 130 c, 0 c, 

\ 14 c, tb 00000000 c, \     |     |14 Port A                         BIT 7 6 5 4 3 2 1 0|
                     \       |     |  IDE Drive On/OFF -------------------+ | | | | | | ||    (F030)
                     \       |     |  SCC A (0=LAN, 1=Serial2) -----------' | | | | | | ||      (TT)
                     \       |     |  Monitor jack GPO pin -----------------+ | | | | | ||
                     \       |     |  Internal Speaker On/Off --------------' | | | | | ||    (F030)
                     \       |     |  Centronics strobe ----------------------' | | | | ||
                     \       |     |  RS-232 DTR output ------------------------' | | | ||
                     \       |     |  RS-232 RTS output --------------------------' | | ||
                     \       |     |  Drive select 1 -------------------------------' | ||
                     \       |     |  Drive select 0 ---------------------------------' ||
                     \       |     |  Drive side select --------------------------------'|
\ 15 c, tb 00000000 c, \     |     |15 Port B (Parallel port)                            |
