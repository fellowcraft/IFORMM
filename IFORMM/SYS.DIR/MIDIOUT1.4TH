\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ MIDIOUT1 - low-level MIDI output

\ The MIDI output driver keeps track of the last command sent
\ and uses "running status" when possible.
\ It also allows for "system exclusive states"
\ in which a series of commands are sent as part of a single
\ system exclusive message.

\ The variable "MIDI-state" is used as follows:
\ 1)  If the most recent command was a standard command,
\     the line is in a "standard state" and is represented by the command byte.
\ 2)  System exclusive states are represented by an index (1-127)
\     into an array of pointers to the byte strings used to enter the state.
\ 3)  If neither of the above holds (e.g. initially,
\     or right after a system exclusive message) the state is zero.

loaded definitions create _midiout1
only forth also
internals also definitions
decimal

variable MIDI-state
20 array sysexcl-table	\ pointers to system-exclusive strings.
			\ each is a 4-byte count followed by the bytes
\ ADD NEW ENTRIES HERE
\ 1 constant fb01-sysex

create MIDI-outbuf 256 allot		\ FIFO for MIDI output
\ the following are 1-byte quans (low byte of word)
\ keep the other bytes zero.
quan mhead	 \ index of next byte to output, if any
quan mtail	 \ index of last byte, or == mhead if empty
quan mcount	\ # of bytes in buffer

\ MIDI logging-related variables follow
forth definitions
quan MIDI-log-ptr
quan MIDI-log-end
quan log-MIDI?
quan log-MIDI-commands?
internals definitions
quan MIDI-cmd-start

: init-MIDI-output
 0 MIDI-state !
 0 to mhead
 0 to mtail
 0 to mcount
 0 to log-MIDI?
 0 to log-MIDI-commands?
;

code MIDI-transmit  ( MIDI transmit interrupt routine )
ifdef MAC
  (set-mask)
  addr mcount 3 + l#) byte tst long \ test to see if it is empty
  0<> if
    1 addr mcount 3 + l#) byte subq long  \ not empty -> decrement mcount
    MIDI-outbuf l#) a0 lea              \ get base address of MIDI output buffer
    addr mhead l#) a0 adda              \ add index into outbuf
    a0 ) 4 a1 d) bmove                  \ store the byte into the SCC register
    (delay)                             \ delay necessary for SCC
    1 addr mhead 3 + l#) byte addq long \ increment mhead
  else
    th 28 # a1 ) bmove                  \ reset TBE interrupt
    (delay)
  then
  (restore-mask)
  rts                                   \ rts to higher level interrupt routine
ifend
ifdef ATARI
\ called from 6850 interrupt handler
 addr mcount 3 + l#) byte tst long      \ anything more to output?
 0<> if
  1 # addr mcount 3 + l#) byte subi long        \ yes -- decrement count
  MIDI-outbuf l#) a0 lea
  addr mhead l#) a0 adda
  a0 ) MIDI-dr l#) bmove
  1 # addr mhead 3 + l#) byte addi long         \ increment head
  rts
 then
 6850-intoff # MIDI-cr l#) bmove        \ no - turn off transmit interrupt
 rts
ifend
end-code

\ Functions for MIDI output follow.  Register usage:
\	a0 contains base address of output buffer
\	a1 points to event record
\	d0 contains MIDI data byte
\	d1 is index of output buffer tail

code (M-out	 	\ output a MIDI data byte
 a2 sp -) move                         \ save a2 -> may be used by calling proc

\ logging code follows
 addr log-MIDI? l#) tst
 0<> if
  addr MIDI-log-ptr l#) a2 move
  d0 a2 )+ bmove
  a2 addr MIDI-log-ptr l#) move
 then
 
ifdef MAC
 (set-mask)                            \ mask interrupts
 addr mcount 3 + l#) byte tst long     \ anything in Q?
 0= wif                                \ no
  SCCRd l#) a2 move                    \ get base address of SCC chip
  TBE # aCtl a2 d) btst                \ is transmit buffer empty?
  0<> if
   SCCWr l#) a2 move                   \ yes
   d0 aData a2 d) bmove                \ write data byte to transmit buffer
   (delay)                             \ delay necessary for slow SCC chip
\ *** the following 3 instruction are not needed for correct MIDI output,
\ *** but they cause all MIDI output to be logged in the output buffer --
\ *** handy for debugging purposes
   d0 0 d1 a0 di) bmove                \ add data byte to outbuf
   1 d1 byte addq long                 \ increment mtail
   1 # addr mhead 3 + l#) byte addi long         \ increment head
  else                                 \ transmit buffer still has byte to send
   d0 0 d1 a0 di) bmove                \ add data byte to outbuf
   1 addr mcount 3 + l#) byte addq long \ increment mcount
   1 d1 byte addq long                 \ increment mtail
  then
 welse
  begin \ loop if output buffer is full until interrupt routine clears space
   255 # addr mcount 3 + l#) byte cmpi long 
  0= while
   (restore-mask)                      \ give SCC a chance to interrupt
   (set-mask)
  repeat
  d0 0 d1 a0 di) bmove			              \ move the byte
  1 addr mcount 3 + l#) byte addq long \ increment mcount
  1 d1 byte addq long                  \ increment mtail
 wthen
 (restore-mask)
ifend
ifdef ATARI
 begin
  255 # addr mcount 3 + l#) byte cmpi long
 0<> until
 d0 0 d1 a0 di) bmove                   \ move the byte
 1 # addr mcount 3 + l#) byte addi long
 1 d1 byte addq long
 6850-inton # MIDI-cr l#) bmove         \ enable buffer-empty interrupt
ifend
 sp )+ a2 move                        \ restore a2
 rts
end-code

code (set-state		\ d0= MIDI command byte
\ Enter a standard MIDI state.
\ If a system exclusive command byte is detected,
\ set the MIDI-state to zero.
 ' (M-out l#) jsr
 th f0 # d0 byte cmp long		\ system exclusive?
 0<> if 
  d0 MIDI-state l#) bmove		\ no, store command
 else
  MIDI-state l#) byte clr long		\ yes, store null
 then
 rts
end-code

code (set-complex-state		\ enter a system-exclusive state
\ d0 = index into sysexcl-table
 d0 MIDI-state l#) bmove
 2 # d0 asl			\ get offset into sysexcl-table
 0 sysexcl-table l#) a2 lea
 0 d0 a2 di) a2 move		\ get address of string
 a2 )+ d2 move			\ string length in d2
 begin
  a2 )+ d0 bmove
  ' (M-out l#) jsr
  1 d2 subq
 0= until
 rts
end-code

code (M-command	\ enter a new MIDI state
\ state byte is in d0
 MIDI-state-timer l#) d2 move
 MIDI-state l#) d0 byte cmp long	\ entering a new MIDI output state?
 0<> if 0 d2 moveq then
 d2 tst
 0= wif
   200 l# MIDI-state-timer l#) move
   MIDI-state l#) d2 bmove 	
   0<> if				\ yes, was the old state null?
    0>= if 				\ no -- was it complex?
     d2 d0 exg				\ yup, send an end of system exclusive
     th f7 # d0 bmove			\ command byte to FIFO.
     ' (M-out l#) jsr
     d0 d2 exg
    then
   then
   d0 byte tst long 		\ is d0 a command byte or a complex state ID?
   0>= wif
    ' (set-complex-state l#) jsr		\ it's a complex state ID
   welse
    ' (set-state	l#) jsr		\ it's a MIDI command byte
   wthen
 wthen
 rts
end-code

code (MIDI-command
\ word to move bytes from an event record to the MIDI output buffer.
\ a1 points to event record.
\ First byte is a MIDI state byte.
\ trashes a0, a2, d0-d2; a1 stays the same.
\ Not allowed to trash any other regs (since used from the synth manager)
\ NOTE: a2 (for sleazy reasons, see midiout2) ends up pointing past end.

\ are we logging MIDI (for MIDI file creation)?
 addr log-MIDI-commands? l#) tst
 0<> if
  addr MIDI-log-ptr l#) d0 move  \ if reached end of buffer, skip
  addr MIDI-log-end l#) d0 cmp
  u< if
   1 d0 addq                     \ round up to even address
   1 # d0 lsr
   1 # d0 lsl
   d0 a0 move
   addr cur-SVT l#) a0 )+ move   \ fill in current time
   a0 )+ byte clr long           \ length field, filled in later
   a0 addr MIDI-cmd-start l#) move
   a0 addr MIDI-log-ptr l#) move
   1 d0 moveq
   d0 addr log-MIDI? l#) move
  then
 then
 
 MIDI-outbuf l#) a0 lea			\ a0 = pointer to MIDI output buffer
 addr mtail l#) d1 move
 args-offset a1 d) d0 move		\ get first arg: MIDI state
 ' (M-command l#) jsr
 nargs-offset a1 d) d2 move		\ get total number of bytes to send
 1 d2 subq				\ nargs 1 too big, includes command
 args-offset 4 + a1 d) a2 lea		\ a2 points to unpacked byte array
 begin
  1 d2 subq				\ keep track of # bytes left to send
 0>= while				\ If any are left.....
  a2 )+ d0 move				\ get byte to send
  ' (M-out	l#) jsr			\ and send it
 repeat
 d1 addr mtail 3 + l#) bmove		\ store new tail

\ if logging, go back and fill in length
 addr log-MIDI? l#) tst
 0<> if
  addr MIDI-log-ptr l#) d0 move
  addr MIDI-cmd-start l#) a0 move
  a0 d0 sub
  d0 a0 -) bmove
  addr log-MIDI? l#) clr
 then

 rts 
end-code

code (MIDI-output
\ same, but raw byte output (no command suppression, no logging)
 MIDI-outbuf l#) a0 lea			\ a0 = pointer to MIDI output buffer
 addr mtail l#) d1 move
 args-offset a1 d) a2 lea
 nargs-offset a1 d) d2 move
 begin
  1 d2 subq				\ keep track of # bytes left to send
 0>= while				\ If any are left.....
  a2 )+ d0 move				\ get byte to send
  ' (M-out l#) jsr				\ and send it
 repeat
 d1 addr mtail 3 + l#) bmove		\ store new tail
 rts
end-code

forth definitions

code MIDI-output-block   ( addr n --- ; output a table of bytes )
\ NOTE: this is meant to be called from process level
\ (e.g., to download a patch)
\ during a period when no notes are playing.
\ There is no mutual exclusion.

 MIDI-outbuf l#) a0 lea			\ a0 = pointer to MIDI output buffer
 addr mtail l#) d1 move
 sp )+ d2 move
 sp )+ a2 move
 begin
  1 d2 subq
 0>= while
  a2 )+ d0 bmove
  ' (M-out l#) jsr
 repeat
 d1 addr mtail 3 + l#) bmove		\ store new tail
c;

ifdef MAC

internals definitions

: +MIDI
 set-mask
 init-SCCA
 init-MIDI-input
 init-MIDI-output
 ['] MIDI-transmit midi-out-vector !
 ['] MIDI-input midi-in-vector !
 ['] spec-cond-int spec-cond-vector !
 restore-mask
;

ifend
