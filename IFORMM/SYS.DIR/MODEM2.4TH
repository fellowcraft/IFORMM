\ Copyright (c) 1987-2006 by Mitch Bradley, David Anderson & Frank H. Rothkamm.  All rights reserved.

\ Serial line handling.  Defines a vocabulary "modem" which contains:
\
\ m-key  ( -- char )	Get a character from the serial line
\ m-key? ( -- flag )	True if a character is waiting
\ m-emit ( char -- )	Output a character to the serial line
\    
\   The following commands establish serial line parameters.
\   They all have the stack diagram  ( -- )
\
\ 19200-baud  9600-baud  4800-baud  2400-baud  1200-baud  300-baud
\ 0-stop-bits  1-stop-bit  1.5-stop-bits  2-stop-bits
\ 8-bits  7-bits
\ no-parity  odd-parity  even-parity
\ no-flow-control  use-xon/xoff  use-rts/cts
\
\   Important:  They do not take effect until the set-line command is
\   executed.
\
\ set-line	Make the established serial line parameters take effect
\
\ There are some (I presume) uninteresting parameters for which words
\ are not defined (example - 2000-baud).  Comments in the code describe
\ the appropriate magic numbers to use should you need to define them.
\
\ Warning: I have seen evidence that the act of setting the serial line
\ parameters causes a single spurious 'ff' character to be output on the
\ serial line.  I think this may be a bug in either the Atari BIOS or
\ the serial line chip.

vocabulary modem

only forth also system also definitions

1 bios: bconstat { w.dev -- w.flag }
3 bios: bconout { w.dev w.char -- }

only forth also system also modem also definitions

th fffc04 constant MIDI-cr	\ addr of control reg for MIDI port
th fffc06 constant MIDI-dr	\ addr of data reg

forth definitions

\ : midi-normal th 95 MIDI-cr c! ;
\ : midi-fast th 94 MIDI-cr c! ;

defer m-key defer m-key? defer m-emit

modem definitions

\ alias ser-key  c_auxin  ( -- char )
\ alias ser-key? c_auxis  ( -- flag )
\ alias ser-emit c_auxout ( char -- )

: midi-key 3 bconin th ff and ;
: midi-key? 3 bconstat ;
: midi-emit 3 bconout ;



: ser-key 1 bconin th ff and ;
: ser-key? 1 bconstat ;
: ser-emit 1 bconout ;

alias s$  ser-emit

forth definitions
: midi-net 
  ['] midi-key is m-key
  ['] midi-key? is m-key?
  ['] midi-emit is m-emit
;

: serial-net 
  ['] ser-key is m-key
  ['] ser-key? is m-key?
  ['] ser-emit is m-emit
;
 
serial-net

only forth also modem also definitions
decimal

\ Translates baud rate to the appropriate magic number

variable baud-rate
: baud: ( n -- ) ( Input stream: name )
  create ,
  does>  @ baud-rate !
;
0 baud: 19200-baud  1 baud: 9600-baud  2 baud: 4800-baud
4 baud: 2400-baud   7 baud: 1200-baud  9 baud:  300-baud

\ Other baud rates are available, though perhaps not useful
\ Here is the full list:
\  19200 ( 0 )   9600 ( 1 )   4800 ( 2 )   3600 ( 3 )   2400 ( 4 )
\  2000  ( 5 )   1800 ( 6 )   1200 ( 7 )    600 ( 8 )    300 ( 9 )

variable #stop-bits
: stop: ( n -- ) ( Input stream: name )
  create , does> @ #stop-bits !
;

    0 stop: 0-stop-bits
th 08 stop: 1-stop-bit
th 10 stop: 1.5-stop-bits
th 18 stop: 2-stop-bits

variable #data-bits
: 8-bits ( -- )      0 #data-bits ! ;
: 7-bits ( -- )  th 20 #data-bits ! ;
\ 6-bits is th 40, 5-bits is th 60;  do people really use 6 or 5 bits?

variable parity
: no-parity   ( -- )    0 parity ! ;
: odd-parity  ( -- ) th 4 parity ! ;
: even-parity ( -- ) th 6 parity ! ;

variable flow-control  0 flow-control !

: flow: ( n -- ) ( Input stream: name )
  create , does> @ flow-control !
;
0 flow: no-flow-control
1 flow: use-xon/xoff
2 flow: use-rts/cts

wvariable ucr  th ffff ucr w!   \ USART control register image
wvariable rsr  th ffff rsr w!   \ receive status register image
wvariable tsr  th ffff tsr w!   \ transmit status register image
wvariable scr  th ffff scr w!   \ sync character register image

td 15  xbios: rsconf { w.scr w.tsr w.rsr w.ucr w.flowctl w.speed -- }

: set-ucr ( -- )
  th 80             \ This bit is the divide-by-16 bit
  #stop-bits @ or   #data-bits @ or   parity @ or
  ucr w!
;
: set-line ( -- )
  set-ucr
  scr w@  tsr w@  rsr w@  ucr w@  flow-control @  baud-rate @
    rsconf

;

: Drumulator-init

9600-baud      
2-stop-bits
set-line

;
