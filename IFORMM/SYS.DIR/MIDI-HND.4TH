\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.
\ modified:
\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ MIDI-HND -- process-level MIDI input handling

\ Non-Sysex handling:
\ The MIDI input process gets complete MIDI commands from the input buffer
\ by calling "get-MIDI-command".
\ This puts the process to sleep when there is no MIDI input to be had.

\ Sysex handling:
\   get-sysex-command ( buf len --- )
\   waits for a sysex msg to arrive

loaded definitions create _midi-hnd
only forth also
internals also definitions

code (get-MIDI-command	( --- data1 data0 command time | data0 command time )
\ get a command from the MIDI input buffer; sleep until command available.
\ Pushes 1 or 2 data bytes depending on command.

 MIDI-inbuf-head l#) d0 wmove
 MIDI-inbuf l#) a0 lea		\ here if there is a command
 d0 a0 word adda long
 d1 clr
 1 a0 d) d1 bmove		\ get its 1st or (if 2) 2nd data byte
 d1 sp -) move			\ push it
 a0 ) byte tst long
 0<> if				    \ were there 2 data bytes?
  2 a0 d) d1 bmove		\ yes -- get the 1st data byte
  d1 sp -) move			\ and push
 then
 3 a0 d) d1 bmove		\ get command byte
 d1 sp -) move			\ and push
 4 a0 d) sp -) move		\ push time
 8 d0 word addq long	\ advance FIFO pointer
 th 1ff # d0 word and long
 d0 MIDI-inbuf-head l#) wmove
c;

forth definitions

: get-MIDI-command
 MIDI-input-struct wait-for-input
 (get-MIDI-command ;

: get-sysex-command   ( buf len --- ; )
 over + to sysex-bufend
 dup to sysex-bufptr
 1 to sysex-state
 MIDI-sysex-struct wait-for-input
;

: +synch-to-MIDI
  1 to MIDI-clock ;

: -synch-to-MIDI
  0 to MIDI-clock ;
  
\ generic MIDI handler process starts here.
\ It uses 'MIDI-action', an array of CFA pointers, as a jump table indexed
\ by the 8 different MIDI commands.

\   MIDI commands (in hex) 
\   0x8y     Note Off
\   0x9y     Note On
\   0xAy     Aftertouch
\   0xBy     Continuous controller
\   0xCy     Patch change
\   0xDy     Channel Pressure
\   0xEy     Pitch bend
\   0xFy     (non-musical commands)
\      y     MIDI-channel (0-f)       

0 array MIDI-action
 ' 2drop token,		\ key up
 ' 2drop token,		\ key down
 ' 2drop token,		\ poly pressure
 ' 2drop token,		\ continuous controller
 ' drop token,		\ change patch
 ' drop token,		\ aftertouch
 ' 2drop token,		\ pitchbend
 ' noop token,		\ system commands


quan midi-in-channel
  
internals definitions

:ap MIDI-handler
  begin
   get-MIDI-command
   to time-position                   \ time
   dup th f and to midi-in-channel    \ command byte contains channel info
   4 >> 7 and                         \ turn command byte into index 
   MIDI-action @ execute              \ and execute
  again 
;ap

:ap (create-MIDI-handler
 ::ap" MIDI input handler"
  immortal
  MIDI-handler
 ;;ap
;ap

defer create-MIDI-handler

' (create-MIDI-handler is create-MIDI-handler
