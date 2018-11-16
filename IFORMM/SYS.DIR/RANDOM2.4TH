\ Copyright (c) 1987-2006 by Daniel Scheidt & Frank H. Rothkamm.  All rights reserved.

\ .( random.fth ) cr
\ .( DJC Random number generators. ) cr
\ .( Transcription to Formula 29/4/89 Rothkamm 89 + Fredrickson 97 ) cr

\ Last modified:
\ DJC 88.05.28	Now a module.
\ DJC 88.05.31  Added rndspan.
\ DJC 88.11.13	Changed rndspan to rndwithin and added rndbetween which are
\		consistent with within and between.
\ DJC 89.02.11	Added alias for rand=rndspan for Dan and rndpct for % flips.
\ DJC 89.02.18	Fixed UNSAFE clauses to abort on error in line with standard.
\ DJC 89.02.18	Finally got around to replacing the xbios rng.
\
\ TODO: Document this.

decimal

\ Generation parameters:

\  : TESTING ;				\ Define to include testing words.

\ End of generation parameters.

\ Don't use the xbios RNG because it is slow and the LSB alternates!
\ 17 xbios: _random { -- l.rnd-number }	\ bios random number routine

\ The following random number generator is an extension of the shift
\ register, XOR algorithm which generates such good white noise.
\ Substitute 32-bit integers for each bit in the shiftregister.
\ Six integers in this version.  We add together the last two integers
\ to get the new one and shift all the others down the line, just as
\ in the six-bit shiftregister algorithm we XOR the last two bits to
\ get the new bit.  Since adding without carry is the same as XOR we
\ have the six-bit shiftreg algorithm in the LSB.  In the other bits
\ things are complicated by the carry.  I know of no analysis of the
\ algorithm but it seems to work.  
\
\ This code beats the xbios RNG by a factor of at least 4 in cycles.

create randregs				\ Shiftregister.
  1234567890 ,				\ These 
  2345678901 ,				\ stupid
  3456789012 ,				\ numbers
  4567890123 ,				\ are
  5678901234 ,				\ the
  6789012345 ,				\ seed.

hex
code _random ( -- )
  randregs l#)   a0   lea
  a0 )   003f #   long movem		\ D0-D5
  d4   d5   long add
  0= if   1   d5   moveq   then		\ This is only a redundant precaution.
  001f #   4 a0 d)   long movem		\ D0-D4
  d5   a0 )   long move
  d5   sp -)   long move
c;

decimal

: rnd  ( limit -- rndnum )    \ 
\ Return random number up to limit.

ifndef UNSAFE
  dup 0 <= abort" rnd: Limit is <= zero."
ifend

   _random swap  mod
;

: rndwithin ( lbound ubound -- rndnum )
\ Return a random number lbound <= rndnum < ubound.

ifndef UNSAFE
  2dup >= abort" rndwithin: ubound <= lbound."
ifend
      
  over - rnd +
;

alias rand rndwithin			\ Backward compatibility for Dan.

: rndbetween ( lbound ubound -- rndnum )
\ Return a random number lbound <= rndnum <= ubound.

ifndef UNSAFE
  2dup > abort" rndbetween: ubound < lbound."
ifend

  1+ over - rnd +
;

: rndpct ( percent -- flag )
\ Return TRUE 'percent' percent of the time.

  100 rnd >
;


ifdef TESTING
: testspeed ( -- )
\ 17 seconds for BIOS _random
\ 4 seconds for mine.   Take your pick...
  100000 0 do _random drop loop
;
: testrepeat
  _random 
  1000000 0 do dup _random = if ." Repeat" then loop
;

: testpct ( percent -- )
  0
  10000 0 
  do over rndpct + loop 
  negate 50 + 100 / .
;
ifend

\ ------------ max: -------------

\ rnd-shuffle take x numbers stored from addr y on and randomly switches 
\ their order    

\ EXAMPLE: 
\ make an array of 4 numbers:    create whatever 60 , 61 , 62 , 63 ,  
\ and shuffle them around:       whatever 4 rnd-shuffle 
            
variable new_place 
variable *shuffle
variable shuffle_length 
-1 constant empty_place   
 
:  rnd-shuffle     ( addr numbers  -- ) 
   shuffle_length ! 
   *shuffle ! 
 
  shuffle_length @ 0 ?do i /l* *shuffle @ + @  loop    \ put number on stack
  shuffle_length @ 0 ?do empty_place i /l* *shuffle @ + ! loop \ clear content

 shuffle_length @ 0 ?do  
  begin 
      shuffle_length @ rnd dup new_place ! 
      /l*  *shuffle @  + @  empty_place =      
  until       
      new_place @ /l*  *shuffle @  + !    
 loop      
;  
 

: grnd+   ( n --- n ) \ Output  
   0 
   12 0 
   do    1200 rnd + 
   loop  
   7200 - 
   * 
   1200 / 
   abs
; 


\ The following is a van Neumann Pseudo Random Generator. Probably the first
\ implementation  of a random number generator. This one was soon discarded as 
\ it ran into repetition and locks. This is of course what we are interested 
\ in here.

variable neumann_seed  4334 neumann_seed !

: nrnd  ( -- )

neumann_seed @ dup *        \ square it
100 /                       \ lower 2 digits out         
10000  /mod drop            \ upper 2 digits out  
dup neumann_seed !          \ keep for next   

;
