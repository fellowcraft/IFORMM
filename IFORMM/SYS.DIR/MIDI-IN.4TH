\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ MIDI-IN -- interrupt-level MIDI input handling

loaded definitions create _midi-in
only forth also
internals also definitions

\ A summary of FORMULA's MIDI input handling:
\ - real-time commands (clock, start, etc.) are used to implement FORMULA's
\   sync-to-MIDI-clock features.  They are not available to the user.
\ - system-exclusive commands (patch dumps, presumably) are stored in
\   a user-supplied buffer.
\   When a complete command is present,
\   the process waiting on "MIDI-sysex-struct", if any, is awakened.
\ - other MIDI commands are stored in a 4-byte "command buffer"
\   (the format is given below).
\   When a complete command has arrived, it is stored, together with the time,
\   in a FIFO queue "MIDI-inbuf".
\   The process waiting on "MIDI-input-struct", if any, is awakened.

\ see MIDI-HND for the process-level part of MIDI input handling

input-handler MIDI-input-struct  \ process queue for regular commands
input-handler MIDI-sysex-struct  \ same for system exclusive
quan sysex-bufptr
quan sysex-bufend
quan sysex-state	\ 0 if nothing doing
			\ 1 if waiting for start of msg
			\ 2 if waiting for end of msg

variable cmd-buf	\ the command buffer
\ byte 0 is flag for 2-byte command
\ byte 1 is 2nd data byte of 2-byte command, or only byte of 1-byte command.
\ It's also used as a need-more? flag
\ byte 2 is 1st data byte of 2-byte command
\ byte 3 is command byte
cmd-buf constant 2byte?
cmd-buf 1+ constant 2nd-byte
2nd-byte constant need-more?
cmd-buf 2+ constant 1st-byte
cmd-buf 3 + constant last-cmd

\ FIFO queue for completed commands

variable MIDI-inbuf-head	\ word-size
variable MIDI-inbuf-tail
create MIDI-inbuf 512 
                  1 *           \ changed by Frank
                  allot      

: init-MIDI-input	( initialize for MIDI input )
 0 MIDI-inbuf-head !
 0 MIDI-inbuf-tail !
 0 cmd-buf !
 0 0 MIDI-input-struct 2!
 0 0 MIDI-sysex-struct 2!
 0 to sysex-state ;

\ The MIDI input interrupt routine.
\ "last-cmd" stores the last command byte, zero if none.
\ here's the logic:
\ - real-time messages
\   handle timing clock; ignore others
\ - system common messages
\   handle start/stop system exclusive; ignore others
\ - other command bytes:
\   set flags to indicate if the MIDI command byte received
\   requires 1 or 2 data bytes and stores the command in last-cmd,
\ - data bytes:
\   when get a complete command,
\   append the received command and the current time to MIDI-inbuf,
\   and wake up the MIDI input process.

code MIDI-input		\ routine to handle a MIDI byte; called from 6850-int
\ Atari: received MIDI byte in d0
ifdef MAC
 d0 long clr     \ get the data from the SCC chip register; a0 points to base
 4 a0 d) d0 bmove
ifend

\ if we're receiving a sysex command, check only for 0xf7
\ (view anything else as part of the sysex command)

 addr sysex-state l#) d1 move
 2 l# d1 cmpi
 0= wif
  addr sysex-bufptr l#) a0 move  \ append to buffer if there's room
  addr sysex-bufend l#) a0 cmpa
  0<> if
   d0 a0 )+ bmove
   a0 addr sysex-bufptr l#) move
  then
  th f7 # d0 byte cmpi long    \ end of sysex?
  0= if
   addr sysex-state l#) clr
   MIDI-sysex-struct l#) a0 lea
   ' (wake-input-handler l#) jsr
  then
  rts
 wthen

\ check for system real-time messages; completely ignore all but clock

 th f8 # d0 byte cmpi long
 u>= if
  0= if  \ clock?
   addr MIDI-clock l#) tst   \ are we synching to MIDI?
   0<> if
    ' advance-clock l#) jsr
   then
  then
  rts
 then

 d0 byte tst long
 0< wif				\ command byte?  

\ check for start of sysex
  th f0 # d0 byte cmpi long
  0= if
   addr sysex-state l#) d1 move  \ are we waiting for a sysex?
   1 l# d1 cmpi
   0= if
    1 d1 addq
    d1 addr sysex-state l#) move
    addr sysex-bufptr l#) a0 move
    d0 a0 )+ bmove
    a0 addr sysex-bufptr l#) move
   then
   rts
  then

\ at this point we've dealt with all the system commands we care about.
\ no-op all the others.
  th f0 # d0 byte cmpi long
  u>= if
   0 d0 moveq
   d0 last-cmd l#) bmove 
   rts
  then

\ here when we have a non-system command
  d0 last-cmd l#) bmove
byte
  th 60 # d0 and		\ cx and dx commands have 1 data byte
  th 40 # d0 cmp
long
  0= if
   0 d0 moveq
  else
   -1 d0 moveq
  then
  d0 2byte? l#) wmove
 welse   			\ here if data byte
byte
  last-cmd l#) tst 		\ return if no current command
  0= if rts then
  need-more? l#) tst		\ does this complete a command?
  0<> if			\ no, hold on to this byte 
   need-more? l#) clr
   d0 1st-byte l#) move
   rts
  then
  d0 2nd-byte l#) move
long
  MIDI-inbuf-tail l#) d1 wmove
  MIDI-inbuf l#) a1 lea
  cmd-buf l#) 0 d1 a1 di) move
  2byte? l#) need-more? l#) bmove	\ sets up for next command
  addr cur-SVT l#) 4 d1 a1 di) move	\ store time in buffer
word
  8 d1 addq				\ increment pointer mod 200
  th 1ff # d1 and
  d1 MIDI-inbuf-tail l#) move	 	\ update pointer
long
  MIDI-input-struct l#) a0 lea
  ' (wake-input-handler l#) jsr
 wthen 
 rts
end-code
