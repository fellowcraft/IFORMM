\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ Name: IFORM Direct Synthesis From Sine Waves
\ Date: December 14, 2003
\ Comment: Finally the Post-Csound implemenation of Direct Synthesis, the most
\ elemental way to produce sound.
\ thanks to: "Sine Wave Theory" http://www.dattalo.com


\ 64 array SINEa  
\ 314 constant PI 	\ 15

\ : sine-wave

\ 64 0 do 
\ PI 127 / i * 
\ dup . cr 
\ i SINEa !
\ loop

\ ;

table SINEb
0 , 3 , 6 , 9 , 12 , 16 , 19 , 22 , 
25 , 28 , 31 , 34 , 37 , 40 , 43 , 46 , 
49 , 51 , 54 , 57 , 60 , 63 , 65 , 68 , 
71 , 73 , 76 , 78 , 81 , 83 , 85 , 88 , 
90 , 92 , 94 , 96 , 98 , 100 , 102 , 104 , 
106 , 107 , 109 , 111 , 112 , 113 , 115 , 116 , 
117 , 118 , 120 , 121 , 122 , 122 , 123 , 124 , 
125 , 125 , 126 , 126 , 126 , 127 , 127 , 127 , 
127 , 


pquan deg
pquan quadrant?

: sine    \ ( degree --- x )  

\ degree = 0-255       [for computability a circle has 255 degrees]
\      x = {-127..127} [8 bit signed integer]

dup 64 < if SINEb exit then to deg

deg 255 > if deg . ." is out of range: 0-255" quit then 

deg 6 >> to quadrant?                  \ which Quadrant?
        
quadrant? 1 = if  127  deg - SINEb        then   \ y = sine[ 64 - x]
quadrant? 2 = if  deg  127 - SINEb negate then
quadrant? 3 = if  255  deg - SINEb negate then      	 
	 
;

: dw! ofd @ fputc ;   \ disk write: write a char (byte) to disk 
                      \ syntax: "" <name> new-file .... dw!....close-files 



\ Ian Wilson 
\ http://www.geocities.com/SiliconValley/Campus/8645/synth.html

\ Dim F, Pi as Single
\ Dim SR, A, L, Hz, O as Integer

\ Hz = 440
\ L = 1000
\ A = 32760
\ SR = 22000
\ Pi = 3.1415

\ F = (2 * Pi * Hz) / SR

\ For T = 0 to L

\ O = int(A * (sin(F * T)))

\ Next T



quan S.Duration
quan S.Frequency
  					  
: SoundD
 \ dup file-exists? if
 \ ." file exists -- overwrite? (y/n) "
 \ key ascii y <> if quit then
 \ then
 
 \  [""] SoundD 

  new-file

 \ highest possible pitch = 1/2 sampling rate = 2 samples per cycle
 \ 100 0 do
 \   64 sine dw!
 \  192 sine dw!
 \ loop
  
 \ -----------------------------------------------------------------------------
  S.Duration 10 << 
  64
  do
   i 10 >> 255 and
   sine dw!
  S.Frequency
  +loop
 \ -----------------------------------------------------------------------------

  
  \ 50 0 do
  \ 255 10 << 0 do
  \            i 10 >>
	\		 sine dw!
	\		 5 +loop
  \ loop
  
  close-files
;
