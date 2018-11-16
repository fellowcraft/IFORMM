\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ MIDIOUT2 - MIDI event routines

loaded definitions create _midiout2
only forth also
ap-defs also internals also definitions

\ MIDI command codes
th 80 constant MIDI-note-off
th 90 constant MIDI-note-on
th a0 constant MIDI-poly-pressure
th b0 constant MIDI-control-change
th c0 constant MIDI-program-change
th d0 constant MIDI-after-touch
th e0 constant MIDI-pitch-bend

\ controller numbers (for control change)
th 40 constant MIDI-sustain-pedal
th 7b constant MIDI-all-notes-off

\ high-level words to call from ::ev events

code MIDI-command	( Bn ... B1 n --- ; send a MIDI command )
\ The arguments are pushed in reverse order of output.
\ B1 is a MIDI command byte or system-exclusive index.
\ This word should probably be called only from ::ev events
\ to avoid preemption problems.
 nargs-offset negate sp d) a1 lea
 ' (MIDI-command l#) jsr
 a2 sp move
c;

code MIDI-output	( Bn ... B1 n --- ; send MIDI bytes )
\ As above, but the bytes are output explicitly
\ (the first byte need not be a command byte)
 nargs-offset negate sp d) a1 lea
 ' (MIDI-output l#) jsr
 a2 sp move
c;

\ event routines

code MIDI-command-event		( direct MIDI output event routine )
 ' (MIDI-command l#) jsr
 ' (free l#) jsr
 rts
end-code

code MIDI-output-event
 ' (MIDI-output l#) jsr
 ' (free l#) jsr
 rts
end-code

\ words to schedule MIDI events

forth definitions

: mku	( vel key# channel# --- ; )
 MIDI-note-off or 3 ['] MIDI-command-event event ;

: mkd	( vel key# channel# --- ; )
 MIDI-note-on or 3 ['] MIDI-command-event event ;

: mpp	( pressure key# channel# --- ; )
 MIDI-poly-pressure or 3 ['] MIDI-command-event event ;

: mcc	( param cc# channel# --- ; )
 MIDI-control-change or 3 ['] MIDI-command-event event ;

: mpc	( cp# channel# --- ; )
 MIDI-program-change or 2 ['] MIDI-command-event event ;

: mat	( aftertouch channel# --- ; )
 MIDI-after-touch or 2 ['] MIDI-command-event event ;

: mpb	( bend channel# --- ; )
\ NOTE: bend has 14 significant bits (-8192...8191, 0 is no bend).
\ This normalizes and chops it up into 7-bit halves for you.
 >r
 8192 + dup 7 >> th 7f and
 swap th 7f and
 r> MIDI-pitch-bend or 3 ['] MIDI-command-event event ;

: mcl   ( --- ; timing clock )
 th f8 1 ['] MIDI-output-event event ;

: mstr  ( --- ; start )
 th fa 1 ['] MIDI-output-event event ;

: mstp  ( --- ; stop )
 th fc 1 ['] MIDI-output-event event ;

: mcnt  ( --- ; continue )
 th fb 1 ['] MIDI-output-event event ;

: mss   ( n --- ; song select )
 th f3 2 ['] MIDI-command-event event ;

: mspp  ( hi lo --- ; song position pointer )
 th f2 3 ['] MIDI-command-event event ;

: fmpp	( pressure key# channel# delay --- ; future polyphonic pressure )
 >r MIDI-poly-pressure or 3 ['] MIDI-command-event r> future-event ;

: fmcc	( param cc# channel# delay --- ; )
 >r MIDI-control-change or 3 ['] MIDI-command-event r> future-event ;

: fmat	( aftertouch channel# delay --- ; )
 >r MIDI-after-touch or 2 ['] MIDI-command-event r> future-event ;

: fmpb  ( bend channel# delay --- ; future pitch bend )
 >r >r
 8192 + dup 7 >> th 7f and
 swap th 7f and
 r> MIDI-pitch-bend or 3 ['] MIDI-command-event r> future-event ;

: notes-off
 16 0 do
  0 MIDI-all-notes-off i mcc
 loop
;

