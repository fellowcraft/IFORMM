\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ DLR-MIDI -- interfaces $-words to MIDI output

loaded definitions create _dlr-midi
only forth also
internals also definitions ap-defs also decimal

: MIDI-do-note	( pitch vol dur --- ; note routine for MIDI output )
 >r
 128 + 2/ 127 and
 swap $transpose $gtranspose + 8>> + 127 and swap
 over MIDI-note-on $channel or
 3 ['] MIDI-command-event event
 0 swap					\ vol pitch
 MIDI-note-on $channel or
 3 ['] MIDI-command-event r> future-event ;

: MIDI-do-pedal	( flag --- ; )
 if 127 else 0 then			\ cc value
 MIDI-sustain-pedal			\ cc number
 MIDI-control-change $channel or
 3 ['] MIDI-command-event event ;

forth definitions

: MIDI-change-patch	( new-patch --- ; )
 $channel MIDI-program-change or
 2 ['] MIDI-command-event event ;


' MIDI-do-note is $do-note
' MIDI-change-patch is $change-patch
' MIDI-do-pedal is $do-pedal
