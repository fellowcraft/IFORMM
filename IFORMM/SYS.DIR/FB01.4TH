\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.
               
only forth also ap-defs also internals also forth definitions

\  change   soundparameter  of     FB01
\				   TX81Z  
\				   Ensoniq-Mirage  
\  Format : ( Operator )  value1  ( value2 ... )  parameter 
\     i.e.:      3         12        7            fre-dt
\  this message must be complete , all required values for a parameter have 
\  to be set ! 
\  type   hi  ( for FB01 )  thi  ( for TX81Z ) 
\  for a list of all parameters and their possible values to change 
\  
\  (c) Copyright 1987 by Frank H. Rothkamm and Marcus Verwiebe
\   C.R.A.P.   Lilienthalst. 18A  1000 Berlin 61  West-Germany
\   Phone:     49-(0)30-6912963      

\ init-MIDI-output

quan fb01max 1 to fb01max

hex
 

 \ ------------------   systemexclusive  ---------------------------------------
 \ ------------- parameter change by midi-channel Table 2 ( p. 48) -------------
quan tmpp
quan tmpv
quan para-channel    \  pquan intern bei multiproz
: setpar  ( p v -- )  \ setzt fb01 para voice data change ---------------
  to tmpv to tmpp

fb01max 0 
do 
   f7               
   tmpv 10 /        
   tmpv 0f and      
   tmpp 40 +       
   15               
   10 i or  
   43                 
   f0                 
   8 ['] MIDI-command-event 
    event
loop
;
 \ end       addr       data     offs pa ch# ID status      n+1# 
 \ -----------------------------------------------------------------------------
\ ------------- parameter change by midi-channel ( Table 1) --------------------

: setconf ( p v -- )  \ setzt fb01 configuration change ---------------
  to tmpv to tmpp

fb01max 0 
do
   f7
   tmpv
   tmpp
   15
   10 i or
   43
   f0
   7 ['] MIDI-command-event
    event
loop
;
\ -----------------------------------------------------------------------


decimal

 \ -----------  algorithm   feedback -------------------------------------
: alg-f ( a f -- )        \  addr  wert2 wert1 
  th 0c rot rot td 3 <<  +  setpar   
;
 \ ------------ transposition  1/2 ton  ----------------------------------
: tra  ( t -- )          
    15  swap  dup 0< if 256 + else then setpar 
; 
 \ ------------ lfo pms ams ----------------------------------------------
: ps-as  ( p a -- )
  th 0d rot 5 << rot +  setpar
;
\ ------------- lfo waveform ---------------------------------------------
: wf   ( w -- )
  th 0e swap 5 << setpar
;
\ ------------- op 0 1 2 3 en/disable ------------------------------------
: oof  ( 0 1 2 3 -- )
 3 << swap 4 << + swap 5 << + swap 6 << + th 0b swap  setpar
;

\ ------------- lfo speed ------------------------------------------------
: lfos ( l -- )
  8  swap  setpar
;
\ ------------- lfo  amd   en(1)dis(0)able for lfo datas ---------------------
: ad-l  ( a l -- )
  7 << + 9 swap setpar  
;  
\ ------------- lfo  pmd    sync -----------------------------------------
: pd-s  ( p s -- ) 
  7 << +  th 0a swap setpar
; 
  
 

\ ******************* operator daten *************************************

 \ -----------  oper  outputlevel ----------------------------------------
: fout ( o l -- ) 
   >r 8 * th 10 + 127 r> - setpar
;

 \ ----------- oper freq detune1 ----------------------------------------- 
: fre-dt  ( o f dt -- )  
  rot 3 << th 13 + rot rot 4 << +  setpar 
;  
 \ ----------- oper sustain release --------------------------------------  
: su-re    ( o s r -- )                \ r : 0 = max
  rot 3 << th 17 + rot  4 << rot +  setpar 
;

 \ ----------- oper attack RateSalingDepth -------------------------------
: at-rsd   ( o a r -- )
  rot 3 << th 14 + rot rot 6 << +  setpar
;

\ ------------ oper decay2 InharmonicFrequencies -------------------------
: d2-if ( o d i -- )
  rot 3 << th 16 + rot rot 6 << +  setpar
;

\ ------------ oper decay1 VelocityAttack Modulatoreinaus   --------------
: d1-v-   ( o d v a )
  7 << rot rot 5 << + + swap 3 << th 15 + swap setpar
;

\ ------------ oper VelocitySensitivity \ KeyboardLevelScalingType ---------
: vs  ( o v  -- )
  4 << swap 3 << th 11 + swap setpar
;
   
\ ------------ oper adjust LevelScalingDepth -----------------------------
: a-lsd ( o a l -- )
  4 << + swap 3 << th 12 + swap setpar
;


: hi 
."                                FB01 " cr
." ------------------------------------------------------------------------- "
cr
."                          Operatoren : 0-3 " cr    
."   fout     fre-dt      su-re       at-rsd     d2-if      d1-v-      " 
cr
."  (0-127) (0-15|0-7) (0-15|0-15) (0-31|0-3) (0-31|0-3) (0-31|0-3|0-1) "
cr
."   vs       a-lsd " cr
."  0-7)   0-15|0-15) " cr
." ------------------------------------------------------------------------- "
cr
."  alg-f     tra     wf      oof     ps-as    lfos       ad-l        pd-s " cr
." (0-7|0-7) (0-255) (0-3) (0-1 4x) (0-7|0-3) (0-255) (0-127|0-1) (0-127|0-1) "
cr
;




