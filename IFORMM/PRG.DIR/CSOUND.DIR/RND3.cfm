<!--- \ Copyright (c) 1987-2008 by Frank H. Rothkamm.  All rights reserved.

\  Stochastic Placement of Events
\  Produces Score for Csound
\  uniform distribution
\  1997/2008

\  usage:  
\  fload xxx.PAR
\  fload xxx.GEN
\  append-to-file xxx.SCO cscore

\ ------------------------------------------------------------------------------

variable duration    
variable attack
variable release
variable start
variable db
variable alldb

\ ------------------------------------------------------------------------------
\ ------------ integer to floating point display converters --------------------

: ns.
 (.) type
;

: F.
  1000 /mod 
  ns. 
  46 emit 
  dup 10 < if  48 emit 48 emit ns. space  
           else
  dup 100 < if 48 emit ns. space endif
           else	   
           endif 
  dup 99  > if ns. space endif	 
 
;

\ -----------------------positive Gauss-----------------------------------------
variable bigg 0 bigg !
variable xx   0 xx !
: grnd2   
   0 
   12 0 
   do    1200 irnd + 
   loop  
   7200 - 
   * 
   1200 / 
   abs
\ ------------------------- graphic output ------------------   
\   dup bigg @ > if dup bigg ! then  
\   xx @ swap 1 !pix
\   1 xx +!
;  --->

<cfscript>

function grnd2(a,b) {

result = RandRange(a,b,"SHA1PRNG");
return result 
}


</cfscript>

<CFOUTPUT> #grnd2(10,20)# </CFOUTPUT>


<!--- : display-grnd2 ( # -- )
 \  erase-screen
  0 bigg !
  0 xx !  
    640 0 ?do
     dup grnd2 
  loop
   drop
   20 0 at bigg @ .
;
\ ---------------------------------
\ ------------------------------------------------------------------------------



\ ----------------------envelope (attack&release)-------------------------------

: make2parts ( -- )  \  2 part envelope, what's not attack is release (decay)

mindur @ maxdur @ rndbetween dup 
100 * 10000 attack% @ irnd 1 max / / dup  
attack ! - release !
  
;   

: rnd-envelope ( -- )
  make2parts
  attack @ release @  + duration ! 
;

\ ----------------------starttime-----------------------------------------------

: rnd-start ( -- )
 0 total @ rndbetween start !      \  start
;  

\ ------------------------envelope that fits-----------------------------------

: generate-envelope  ( -- )
begin  
 rnd-envelope
 rnd-start
start @ duration @ + total @ < 
until

;   

\ ----------------------------frequencies---------------------------------------

  variable freq

\ \ telsa's resonant earth frequencies: 6 18 30

\ table tesla 6 , 18 , 30 ,
\ table Octs 2 , 4 , 8 , 16 , 32 , 64 , 128 , 256 , 512 , 1024 , 2048 ,


\ : rnd-freq
   
\   begin
\   3 irnd tesla  11 irnd Octs * minfreq @ + 
\   dup freq !
\   maxfreq @ < until  
   
\ ;

  : rnd-freq
    minfreq @ maxfreq @ rndbetween freq !
  ;
  
\ ----------------------- decibels ---------------------------------------------

: rnd-db
mindb @ maxdb @ rndbetween db !   	\  amp 0-32000 (90dB) 8000(70 db) 
;
\ ------------------------decibel factors---------------------------------------

: factors
." ; all possible dbs: " #events @ 9000 * F.
cr
." ; all actual   dbs: "  alldb @ F.
cr
." ; Optimized Dividing Factor for Amp: " 
#events @ 9000 * 100 *   alldb @ /
\ #events @ *
F.

  

;

\ ---------------------------cscore---------------------------------------------

: cscore

 
   0 alldb !
  9 tabstops !

." ;  "  #events @ . ." #events total " total @ F. ." seconds" 
cr    

." ;  minfreq "  minfreq @ . ." Hz - maxfreq " maxfreq @ . ." Hz"     

   
cr

." ;  mindb "  mindb @  F. ." dB - maxdb " maxdb @ F. ." dB" cr    
cr

." f1  0  4096  10  1" 
\ ." f1 0 8 2     0 0   1 1 1  -1 -0.5 -1" 

cr
." ;  Osc   start    dur      amp      freq    attack    rel      panS     panE" 
cr
#events @  0 ?do

generate-envelope          
rnd-db
rnd-freq

." i1  "                        \  use the same Sound Oscillator  
1 .tab
start @   F.   			\  starttime
1 .tab
duration @  F.   		\  duration     
1 .tab
db @ 
dup alldb +!
            F.     	        \  amp 0-32000 (90dB) 8000(70 db) 
1 .tab
freq @ .                        \  frequency (Hz) 
1 .tab
attack @    F.   		\  attack
1 .tab
release @   F.			\  release
1 .tab
panStart @  irnd F.
1 .tab
panEnd @  irnd F.

\ ." ; "
\ duration @ start @ + F. 

cr

loop

." e"

cr

factors
 
;




 --->