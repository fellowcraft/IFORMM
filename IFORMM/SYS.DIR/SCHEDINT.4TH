\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ SCHEDINT -- scheduling interrupt routines: system clock and software interrupt

\ Wakeup methods are performed from the software interrupt level to avoid
\ losing clock ticks and other important interrupts (e.g. MIDI input).
\ This allows event routines to be mildly time-consuming.

\ The system clock interrupt routine (the 200 Hz general timekeeper)
\ schedules a software interrupt when it finds wakeup calls may be due
\ (i.e. when systime is advanced beyond a non-empty array element).
\ To avoid a recursive software interrupt, it first checks whether
\ a software interrupt is already in progress.

\ The array element in WQ indexed by current system time (systime)
\ can be accessed from interrupt routines, or from process level with
\ interrupts masked.  Earlier elements are accessed by the software interrupt.
\ If time ever wraps around during a single software interrupt,
\ we're in trouble.  This problem could be solved by having the softint
\ mask interrupts, or by using "ownership" bits on array entries
\ (an interrupt routine knows that softint is using an element if it's
\ owned but its predecessor isn't).

loaded definitions create _schedint
only forth also definitions internals also
decimal
ifdef MAC
windows also
ifend

quan system-mindel
quan ticks    \ counter for clock interrupts (used by "conduct")

ifdef ATARI
vect key-handler                \ ptr to subroutine to call on keyboard input
                                \ for waking blocked process, etc.
code default-kh
 rts
end-code
' default-kh to key-handler     \ see TTY for more interesting version
ifend

variable MIDI-state-timer	\ limits the duration of MIDI running status


\ ******************************************
\       Software Interrupt Handler
\ ******************************************

code softint-handler
ifdef MAC
 th f0e # sp -) movem			\ save registers - others already saved by deferred task mgr
ifend
ifdef ATARI
 th 300 # sp ) word ori long            \ disable software interrupt on rte
 th fffe # sp -) movem                  \ save registers
ifend
 addr execution-queue l#) sp -) move	\ remember interrupted object

\ disable (unmask-softint) in wakeup routines
  1 addr softint-mask-level l#) byte addq long
 ' (wakeup-call l#) jsr			\ perform events and wake up processes
 1 addr softint-mask-level l#) byte subq long

 (set-all-mask)

\ Interrupts are masked at this point.

 addr softint-request l#) byte clr long		\ work is all done
 sp )+ a0 move					\ a0 is the interrupted object
 addr execution-queue l#) a2 move		\ a2 is the new XQH
 a2 a0 cmpa					\ are they the same?
 0= if
ifdef MAC
  sp )+ th 70f0 # long movem			\ restore registers
  (set-default-mask)
  rts
ifend
ifdef ATARI
  sp )+ th 7fff # long movem
  rte
ifend
 then

 \ no? -- we need to preempt
 \ a0 points to interrupted object, a2 to new XQH
 
ifdef MAC
 th 110 l#) clr	         \ make sure stack sniffer is OFF
 th d92 l#) sp -) word move long
 th d92 l#) word clr long     \ clear "deferred task in progress" flag
ifend

 addr who l#) a1 move			        \ a1 is interrupted process
 sp poffset sp-save a1 d) move			\ finish saving its state
 a1 poffset preempted-CB a0 d) move		\ tie it to object
 preempted-flag # poffset flags a0 d) bset	\ and mark object as preempted

ifdef MAC
 the-current-window l#) poffset my-wdp a1 d) lmove
ifend

\ switch to the new process.  NOTE: it came from the wakeup buffer,
\ and therefore was not preempted, so don't even bother to check.

 poffset first-descendant a2 d) a0 move
 (forth-context)				\ set up a3, a4 for Forth
 (restore-forth-state*)
 (mask-softint)
 (set-default-mask)

 rts
end-code

ifdef MAC

code popper    \ used to restore regs and return... see below
 sp )+ th 7fff # long movem
 (unmask-softint)
 rts
end-code


\ ****************************************
\   Software Interrupt Emulator (Mac only)
\ ****************************************

\ This is called when a softint was masked,
\ the mask level has just gone to zero again,
\ and the request flag was set.
\ (Mac only... on the Atari an actual softint is used)
code softint-emulator
 th fffe # sp -) movem
 addr execution-queue l#) sp -) move	        \ remember interrupted object
 1 addr softint-mask-level l#) byte addq long	\ disables (unmask-softint) in wakeup-routines
 ' (wakeup-call l#) jsr			  \ perform events and wake up processes
 1 addr softint-mask-level l#) byte subq long	\ set mask level back to 0
 (set-all-mask)

 addr softint-request l#) byte clr long		\ work is all done
 sp )+ a0 move					\ a0 is the interrupted object
 addr execution-queue l#) a2 move		\ a2 is the new XQH
 a2 a0 cmpa					\ are they the same?
 0= wif						\ if so, just restore regs and return
  sp )+ th 7fff # long movem
  (set-default-mask)
  rts
 wthen

\ switch to the new process. 
\ NOTE: it came from the wakeup buffer, and therefore was not preempted

 ' popper l#) a1 lea
 a1 sp -) move     \ arrange to pop regs on return
 (save-forth-state*)    \ a1 == who on return
 a1 poffset first-descendant a0 d) move
 
 poffset first-descendant a2 d) a0 move
 (forth-context)		\ set up a3, a4 for Forth
 (restore-forth-state*)
 (mask-softint)
 (set-default-mask)
 rts
end-code

' softint-emulator unmask-switch-addr token!

ifend

ifdef ATARI
\ arrange for software interrupt by lowering return priority
\ below that of the horizontal retrace interrupt
\ NOTE: THIS ASSUMES THAT THE STACK HAS 32 BYTES BEYOND
\ THE EXCEPTION FRAME (NOT JSRs, NO (set-mask) ALLOWED!!!)
:cm (schedule-softint)
 th f8ff # 32 sp d) word andi long
;cm
ifend

ifdef MAC

create DT-req    \ deferred task request block
0 ,
7 w,	\ qType
0 w,	\ dtFlags -- reserved
0 token,	\ procedure address
0 ,	\ parameter
0 , \ another reserved value

' softint-handler DT-req 8 + !

:cm (schedule-softint)
 DT-req l#) a0 lea
 th d9c l#) a1 move  \ d9c is global var pointing to the "deferred task install" routine
 a1 ) jsr
;cm

ifend

\ this gets called from either the MIDI input interrupt (on MIDI clock)
\ or from sysclock-handler (below).  It advances one "tick" of time.

code advance-clock
 addr cur-SVT l#) d0 move		\ get current system virtual time
 addr system-mindel l#) d0 sub		\ add offset (normally negative)
 addr execution-queue l#) a0 move
 poffset deadline a0 d) d0 cmp		\ is it less than soonest deadline?
 u< wif					\ skip if not
  (update-SVT)
  (update-cur-offset)
 wthen
 rts
end-code


\ ***********************************
\      clock interrupt handler
\ ***********************************

code sysclock-handler	( 200 Hz "system clock" interrupt routine )

ifdef ATARI
 th 2500 # sr wmove
 th f0f0 # sp -) movem          \ save d0-d3, a0-a3
 addr key-handler l#) a2 move   \ check for new keys, auto-repeat,
 a2 ) jsr                       \ panic button, etc.
ifend

ifdef MAC
 vT1C a1 d) d0 bmove		\ clear the interrupt
ifend

 1 addr ticks l#) addq

\ time out running MIDI status
 MIDI-state-timer l#) d0 move
 0<> if
  1 d0 subq
  d0 MIDI-state-timer l#) move
 then

\ if we're not using MIDI clock, advance SVT
 addr MIDI-clock l#) d0 move
 0= if
  ' advance-clock l#) jsr
 then

\ If the software interrupt is not already active,
\ check the wakeup buffer and set softint-request if needed.
\ If so and mask level is zero, schedule a software interrupt.

ifdef MAC
 (set-mask)  \ unneeded and erroneous on Atari
ifend
 addr softint-request l#) byte tst long
 0= wif  
  ' (wakeup-check l#) jsr
  addr softint-request l#) byte tst long
  0<> wif
   addr softint-mask-level l#) byte tst long
   0= wif
    (schedule-softint)
   wthen
  wthen
 wthen
ifdef MAC
 (restore-mask)
ifend
ifdef ATARI
 sp )+ th f0f # movem                  \ restore regs
 TOS-clockrout l#) sp -) move           \ jump to system timer routine
ifend

 rts					\ Mac: return to exception handler
end-code
 
forth definitions

: +clock
ifdef ATARI
 ['] sysclock-handler sysclock-vector !
ifend
ifdef MAC
 ['] sysclock-handler timer1-vector !
 3910 init-sysclock			\ set it to interrupt every 5 ms
ifend
;

internals definitions

: +perf		( install vector for software interrupt )
 0 to softint-request
ifdef ATARI
 ['] softint-handler horizontal-retrace-vector !
ifend
;
