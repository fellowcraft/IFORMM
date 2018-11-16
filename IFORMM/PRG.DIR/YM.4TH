\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ 90/99/04    	                   
\ Oxygen8-uc33-MS20 input transform to YM2149

\   'Dosound()' ist der Makro fuer die XBIOS-Funktion 32.

32 xbios: Dosound  { l.addr -- } 

create YMsound

\ ================\ Atari ST soundchip Yamaha YM2149 /=========================
\ 
\                $FF8800|byte |Read data/Register select |R/W
\ -----------------  \  +-----------------------------------------------------+
0 c,           50 c, \  |0 Channel A Freq Low              BIT 7 6 5 4 3 2 1 0|
1 c,            1 c, \  |1 Channel A Freq High                     BIT 3 2 1 0|
2 c,           80 c, \  |2 Channel B Freq Low              BIT 7 6 5 4 3 2 1 0|
3 c,            1 c, \  |3 Channel B Freq High                     BIT 3 2 1 0|
4 c,          120 c, \  |4 Channel C Freq Low              BIT 7 6 5 4 3 2 1 0|
5 c,            1 c, \  |5 Channel C Freq High                     BIT 3 2 1 0|
6 c,            0 c, \  |6 Noise Freq                          BIT 5 4 3 2 1 0|
7 c,  tb 00111000 c, \  |7 Mixer Control                   BIT 7 6 5 4 3 2 1 0|
                     \  |  Port B IN/OUT (1=Output) -----------' | | | | | | ||
                     \  |  Port A IN/OUT ------------------------' | | | | | ||
                     \  |  Channel C Noise (1=Off) ----------------' | | | | ||
                     \  |  Channel B Noise --------------------------' | | | ||
                     \  |  Channel A Noise ----------------------------' | | ||
                     \  |  Channel C Tone (0=On) ------------------------' | ||
                     \  |  Channel B Tone ---------------------------------' ||
                     \  |  Channel A Tone -----------------------------------'|
8 c,  tb 00001111 c, \  |8 Channel A Amplitude Control           BIT 4 3 2 1 0|
                     \  |  Fixed/Variable Level (0=Fixed) -----------' | | | ||
                     \  |  Amplitude level control --------------------+-+-+-'|
9 c, tb 00001111 c,  \  |9 Channel B Amplitude Control           BIT 4 3 2 1 0|
                     \  |  Fixed/Variable Level ---------------------' | | | ||
                     \  |  Amplitude level control --------------------+-+-+-'|
10 c, tb 00001111 c, \  |10 Channel C Amplitude Control          BIT 4 3 2 1 0|
                     \  |  Fixed/Variable Level ---------------------' | | | ||
                     \  |  Amplitude level control --------------------+-+-+-'|
11 c,         100 c, \  |11 Envelope Period High           BIT 7 6 5 4 3 2 1 0|
12 c,           2 c, \  |12 Envelope Period Low            BIT 7 6 5 4 3 2 1 0|
13 c, tb 00001010 c, \  |13 Envelope Shape                         BIT 3 2 1 0|
                     \  |  Continue -----------------------------------' | | ||
                     \  |  Attack ---------------------------------------' | ||
                     \  |  Alternate --------------------------------------' ||
                     \  |  Hold ---------------------------------------------'|
                     \  |   00xx - \____________________________________      |
                     \  |   01xx - /|___________________________________      |
                     \  |   1000 - \|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\      |
                     \  |   1001 - \____________________________________      |
                     \  |   1010 - \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\      |
                     \  |   1011 - \|-----------------------------------      |
                     \  |   1100 - /|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/      |
                     \  |   1101 - /------------------------------------      |
                     \  |   1110 - /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/      |
                     \  |   1111 - /|___________________________________      |

quan YM_velocity
quan YM_pitch
quan YM_voice

: YM-note-on ( velocity:0-127  pitch:0-127  -- )
  master-transpose + to YM_pitch
  to YM_velocity
	
\ ============== pitch =====================================
  YM_pitch  128 - negate 31 * to YM_pitch   \ reverse 8bit (128) to 12bit (4095)        

\ ============== voice 1 ===================================  
  YM_pitch tb 000011111111 and 
  0 irnd +                                       \ randomize
                                YMsound 1 + c!   \ LOW Bit
  YM_pitch 8 >>                 YMsound 3 + c!   \  HI Bit  
\ ============== voice 2 ===================================  
  YM_pitch tb 000011111111 and 
  0 irnd +                                       \ randomize
                                YMsound 5 + c!   \ LOW Bit
  YM_pitch 8 >>                 YMsound 7 + c!   \  HI Bit 
\ ============== voice 3 ===================================  
  YM_pitch tb 000011111111 and 
  0 irnd +                                       \ randomize
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
     master-transpose + 0 swap YM-note-on 
; 



: YM-control

  MS20
  to cc_val1       			\ get the current parameters 
  to cc_val2
  
  cc_val1
  case
 
\ irnd - frnd - nrnd : switches ------------------------------------------------
  22 of
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
	 0 of   -12 to master-transpose endof
	 43 of    0 to master-transpose endof
	 85 of   12 to master-transpose endof
	 127 of  24 to master-transpose endof
     endcase
  endof

\ pitch randomization ----------------------------------------------------------
  1 of cc_val2 to $rnd endof  \ mod wheel
    

\ ------------------------------------------------------------------------------
\ cc to YM transform --------------------------------------------------------
\ ------------------------------------------------------------------------------

\ 1 -- ADSR (R=ASD) ENV ------------------------------------
    71 of   cc_val2 128 - negate 31 * 
            dup tb 000011111111 and YMsound 1 + c!   \ LOW Bit
               8 >>                 YMsound 3 + c!   \  HI Bit 
       YMsound Dosound 
       endof  
    72 of   cc_val2 128 - negate 31 * 
            dup tb 000011111111 and YMsound 5 + c!   \ LOW Bit
               8 >>                 YMsound 7 + c!   \  HI Bit 
       YMsound Dosound 
       endof
    73 of    cc_val2 128 - negate 31 * 
             dup tb 000011111111 and YMsound  9 + c!   \ LOW Bit
                8 >>                 YMsound 11 + c!   \  HI Bit 
       YMsound Dosound 
       endof  
   
endcase
;

: YM-thru-control 
  MS20
  to cc_val1       			\ get the current parameters 
  to cc_val2 
  
;

: YM
\ ['] YM-note-off    0 MIDI-action !
  ['] YM-note-on     1 MIDI-action !  
  ['] YM-control     3 MIDI-action !

;
