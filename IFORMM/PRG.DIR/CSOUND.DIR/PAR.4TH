\  Stochastic Placement of Events
\  Produces Score for Csound
\  uniform distribution of partials
\  1997/2003

variable #events   	 365  #events ! 
variable total 		60000  total  !	   \  100 = 1 sec

variable maxfreq 	 2000 maxfreq ! 	\ in Hz.  Gaussian distribution      
variable minfreq 	   20 minfreq !	    \ 

variable maxdur 	  30000   maxdur ! 	\ 100 = 1 sec
variable mindur 	  15000   mindur ! 

variable attack% 	50 attack% ! 	\  % attack to decay ratio  

variable maxdb        9000 maxdb !      \ in centidb (1/10 of a db)
variable mindb        3000 mindb !

variable panStart     100 panStart !
variable panEnd       100 panEnd !


\ ------------------------------------------------------------------------------

variable duration    
variable attack
variable release
variable start
variable db
variable alldb

: 1T  1 .tab ;


\ ------------------------------------------------------------------------------
\ ------------ integer to floating point display converters --------------------

: ns.
 (.) type
;

: F.
  100 /mod 
  ns. 
  46 emit 
  dup 10 < if 48 emit ns. space else ns. space then
  
;

\ ----------------------envelope (attack&release)-------------------------------

: make2parts ( -- )  \  2 part envelope, what's not attack is release (decay)

mindur @ maxdur @ rndbetween dup 100 * 10000 attack% @ irnd 1 max / / dup  attack ! - release !
  
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

variable fundamental  30 fundamental !

: rnd-freq
   minfreq @ maxfreq @ rndbetween 
   fundamental @ / fundamental @ *  
   freq !
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

." ;  mindb "  mindb @  F. ." dB - maxadb " maxdb @ F. ." dB" cr    
cr

." f1  0  2048  10  1" 
cr
." ;  Osc   start    dur      amp      freq    attack    rel      panS     panE" 
cr

#events @  0 ?do

generate-envelope          
rnd-freq
rnd-db

." i1  "             \  use the same Sound Oscillator 
1T
start @   F.         \  starttime
1T
duration @  F.       \  duration     
1T
db @ 
dup alldb +! F.      \  amp 0-32000 (90dB) 8000(70 db) 
1T
freq @ .             \  frequency (Hz) 
1T
attack @    F.       \  attack
1T
release @   F.       \  release
1T
panStart @  irnd F.
1T
panEnd @  irnd F.

cr

loop

." e"

cr

factors
 
;


: generate ( filename -- file ) 
  rm x
  append-to-file x cscore   
   
;



