\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ( .actions -- nlist ) 
\ print out what's in the current MIDI arraymm

\ -----------------------------------------------------------------
\                        NORMAL THRU 

\ -----------------------------------------------------------
\                          VELOCITY VARIATIONS

table ppp
-12 ,  -12 , -12 , 0 , 0 , 0 , 12 , 12 , 24 ,

pquan InP
pquan InV

: doppler

  2dup to InP to InV           \ remember what's there

  swap drop      
  60 110 rndbetween            \ replace & randomize velocities
  swap
  0 mkd                        \ play

\ -----------------------------double notes---------------------------   

  InV 2 grnd +                \  randomize velocities

  9 irnd ppp                   \ get element from table
  dup 0= if                    \ if it 0 play a pause   
         else InP +            \ change note
         then 
  0 mkd                        \ play
;

: vel-rnd
 
  swap drop      
  25 110 rndbetween            \ replace & randomize velocities
  swap
  0 mkd                        \ play
  

;

string-array channel-message-names
   ," note_off"
   ," note_on"
   ," poly_pressure"
   ," control_change"
   ," program_change"
   ," channel_pressure"
   ," pitch_wheel_change"
   ," system-messages"
end-string-array
string-array system-message-names
   ," system_exclusive"
   ," quarter_frame"
   ," song_position_pointer"
   ," song_select"
   ," undefined"
   ," undefined"
   ," tune_request"
   ," end_of_exclusive"
   ," MIDI_clock"
   ," undefined"
   ," MIDI_start"
   ," MIDI_continue"
   ," MIDI_stop"
   ," undefined"
   ," MIDI_active_sensing"
   ," MIDI_system_reset"
end-string-array

: .actions
   cr ." ========== Definitions in MIDI-action ==========" cr cr
   8 0 do
      i dup channel-message-names ".
      25 to-column MIDI-action @ .name
      cr
   loop
   cr
;