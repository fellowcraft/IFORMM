\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ MACHINE.ST - Atari ST hardware-specific stuff

\ FORMULA uses a clock interrupt and a software interrupt
\ (i.e., lowest priority hardware interrupt).

\ On the Atari ST, the horizontal retrace interrupt is used as
\ a software interrupt.
\ It is used to do event performance (so don't have to mask interrupts)
\ and process preemption (so don't have to worry about nested interrupts).
\ A software interrupt is triggered by lowering the hardware priority
\ to 0 (thus enabling horizontal retrace interrupt).

loaded definitions create _machine
only forth also
internals also definitions
decimal

\ interrupt vector addresses and default contents

7 array hardware-intvecs	\ basic hardware interrupt vectors

th 68 constant horizontal-retrace-vector	\ (level 2 interrupt)
th 70 constant vertical-retrace-vector		\ (level 4 interrupt)

\ The level 6 interrupt is a 68901 Multi Function Peripheral.
\ it generates auto-vectors ranging from $100 to $13c.

16 array TOS-68901-intvecs	\ the 68901 auto-vectors

th 114 constant sysclock-vector
th 118 constant 6850-vector

9 array TOS-kbd-routines	\ the TOS 6850 interrupt handler calls
				\ 9 different subroutines.

34 xbios: kbdvbase { -- l.base }	\ system call to get
\ base address of the table of TOS 6850 subroutine pointers
\ they are:
\ MIDI_input		\ D0-->buffer
\ keyboard_error
\ MIDI_error
\ ikbd_stat
\ mouse_packet		\ packet pointer is in A0.
\ joystick_packet
\ MIDI_vector		\ called when a valid MIDI byte available
\ ikbd_vector		\ ditto for keyboard

: save-intvecs 			\ save existing interrupt vectors
 7 0 do 
  th 64 i 2 << + @ 
  i hardware-intvecs !
 loop
 16 0 do
  th 100 i 2 << + @ 
  i TOS-68901-intvecs !
 loop
 9 0 do				
  kbdvbase i 2 << + @ 
  i TOS-kbd-routines ! 
 loop ;

: restore-intvecs 		\ restores all interrupt vectors
 7 0 do 
  i hardware-intvecs @
  th 64 i 2 << + !
 loop
 16 0 do
  i TOS-68901-intvecs @
  th 100 i 2 << + !
 loop
 9 0 do	
  i TOS-kbd-routines @
  kbdvbase i 2 << + !
 loop ;

1 hardware-intvecs constant TOS-horizontal-retrace
5 TOS-68901-intvecs constant TOS-clockrout
6 TOS-68901-intvecs constant TOS-6850rout
8 TOS-kbd-routines constant TOS-kbdrout

th 2300 constant default-mask
th 2700 constant all-mask

:cm (set-mask)		\ save mask on stack, then mask all interrupts
\ macro for code words
 sr sp -) wmove
 2 sp subq
 all-mask # sr wmove
;cm

:cm (restore-mask) 	\ restore previous mask from stack
 2 sp addq
 sp )+ sr wmove
;cm

code set-mask
 (set-mask)
c;

code restore-mask
 (restore-mask)
c;

:cm (set-default-mask)
 default-mask # sr wmove
;cm

code set-default-mask
 (set-default-mask)
c;

:cm (set-all-mask)
 all-mask # sr wmove
;cm

\ *********** software interrupt stuff

quan softint-mask-level	\ byte; count of softint mask level (0 = enabled)
quan softint-request	\ byte; true if softint has been requested or
\ is in progress

:cm (mask-softint)
 1 addr softint-mask-level l#) byte addq long
;cm

code mask-softint
 (mask-softint)
c;

:cm (unmask-softint)
 1 addr softint-mask-level l#) byte subq long
 0= if
  addr softint-request l#) byte tst long
  0<> if
   th 2000 # sr wmove
  then
 then
;cm

code unmask-softint
 (unmask-softint)
c;

\ ********** restoration words
forth definitions

: -clock		( restore system clock vector to TOS state )
\ disables timekeeping in FORMULA
 TOS-clockrout @ sysclock-vector ! ;

: -perf			( restore horizontal retrace vector to TOS state )
\ disables event performance & process wakeup in FORMULA
 TOS-horizontal-retrace @ horizontal-retrace-vector ! ;

: -MIDI			( restore MIDI/keyboard vector to TOS state )
\ disables FORMULA MIDI input handling
 TOS-6850rout @ 6850-vector ! ;

\ The 68901 is hooked up so that its registers have address increments of 2.
\ The 68901 operates in "software end-of-interrupt mode" which allows pending
\ interrupts to be detected by the interrupt routine, and also requires
\ that the appropriate "in service" bit be cleared at the end of the routine.
\ For example, isra bit # 5 MUST be cleared at the end of 
\ the user-clock interrupt routine.

\ 68901 reg definitions

internals definitions

th fffffa01 constant mfp	\ base address for 68901 regs
mfp  6 + constant iera		\ interrupt enable registers
mfp  8 + constant ierb
mfp 10 + constant ipra		\ interrupt pending registers
mfp 12 + constant iprb
mfp 14 + constant isra		\ interrupt in-service registers
mfp 16 + constant isrb
mfp 18 + constant imra		\ interrupt mask registers
mfp 20 + constant imrb
mfp 24 + constant tacr		\ timer a control register
mfp 30 + constant tadr		\ timer a data register

\ bit numbers for interrupts handled by 68901

5 constant timerA#		\ user clock, in A reg
5 constant timerC#		\ system clock, in B reg
6 constant 6850#		\ 6850's (for MIDI, keyboard), in B reg

\ the ST has 2 6850's, one for keyboard, one for MIDI

th 95 constant 6850-intoff	\ 6850 mask for transmit interrupt off
th b5 constant 6850-inton
th fffc00 constant kbd-cr	\ addr of control reg for keyboard port
th fffc02 constant kbd-dr	\ addr of data reg
th fffc04 constant MIDI-cr	\ addr of control reg for MIDI port
th fffc06 constant MIDI-dr	\ addr of data reg

\ some important bits in 6850
\ status register:
\ bit 0 says the receive buffer is full
\ bit 1 says transmit buffer is empty
\ bit 7 says interrupt was generated by this chip

:cm (mask-sysclock)		( mask system clock interrupt )
 (set-mask)			\ this is necessary due to a flaw in the
 timerC# # imrb l#) bclr	\ 68000/68901 interface.
 (restore-mask)			\ Hard to explain.
;cm

:cm (unmask-sysclock)
 timerC# # imrb l#) bset
;cm

code mask-sysclock		( mask system clock interrupt )
 (mask-sysclock)
c;

code unmask-sysclock
 (unmask-sysclock)
c;
		
th 134 constant userclock-vector

code mask-userclock		( mask user clock interrupt )
 (set-mask)
 timerA# # imra l#) bclr
 (restore-mask)
c;

code unmask-userclock		( unmask user clock interrupt )
 timerA# # imra l#) bset
c;

code disable-userclock		( disable timer a interrupt )
 (set-mask)
 timerA# # iera l#) bclr
 (restore-mask)
c;

code enable-userclock		( enable timer a interrupt )
 timerA# # iera l#) bset
c;

\ The master clock is at 2.4576 Mhz; 200 hz=2.4576Mhz/64*192

: set-userclock-freq	( period --- ; set timer a's freq  )
 5 tacr c!	\ divide by 64 prescale
   tadr c! ;	\ note that period spec is one byte, sys period=192

ifdef _NOTDEF
variable x

code test-userclock
 1 x l#) addq
 timerA# # isra l#) bclr
 rte
end-code

: testit	( --- ; test user interrupt )
 ['] test-userclock userclock-vector !
 192 set-userclock-freq
 enable-userclock unmask-userclock
;

ifend
