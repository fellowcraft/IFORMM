\ (c) Frank H. Rothkamm  1990/99/04   	                    all rights reserved
\  This is a furious attempt to make the YM Sound Chip swing 
\  works now like a MIDI device: 
\  YM-note-on  ( velocity pitch   -- ) 
\  YM-note-off (          pitch   -- ) 

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
7 c,  tb 11111000 c, \       |     |7 Mixer Control                   BIT 7 6 5 4 3 2 1 0|
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

quan YM_velocity
quan YM_pitch
quan YM_voice

: YM-note-on ( velocity:0-127  pitch:0-127  -- )
  to YM_pitch
  to YM_velocity
	
\ ============== pitch =====================================
  YM_pitch 128 - negate 31 * to YM_pitch   \ reverse 8bit (128) to 12bit (4095)        


\ ============== voice 1 ===================================  
  YM_pitch tb 000011111111 and 
  4 irnd +                                       \ randomize
                                YMsound 1 + c!   \ LOW Bit
  YM_pitch 8 >>                 YMsound 3 + c!   \  HI Bit  
\ ============== voice 2 ===================================  
  YM_pitch tb 000011111111 and 
  4 irnd +                                       \ randomize
                                YMsound 5 + c!   \ LOW Bit
  YM_pitch 8 >>                 YMsound 7 + c!   \  HI Bit 
\ ============== voice 3 ===================================  
  YM_pitch tb 000011111111 and 
  4 irnd +                                       \ randomize
                                YMsound 9 + c!   \ LOW Bit
  YM_pitch 8 >>                 YMsound 11 + c!  \  HI Bit 	

\ ============== velocity ==================================
   YM_velocity 3 >> to YM_velocity
   YM_velocity YMsound 17 + c!
   YM_velocity YMsound 19 + c!
   YM_velocity YMsound 21 + c!

   YMsound Dosound 

;

: YM-note-off  ( pitch  -- )  
     0 swap YM-note-on 
; 


:ap playYM
::ap" chip"

begin 
     31 999 irnd  YM-note-on
  1 brnd if 8 else 16 then tel r $

     31 2104 irnd  YM-note-on      
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
