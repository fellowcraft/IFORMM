\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ ( .actions -- nlist ) 
\ print out what's in the current MIDI array

\ -----------------------------------------------------------------
\                        NORMAL THRU 

\ -----------------------------------------------------------
\                          VELOCITY VARIATIONS

table ppp
-12 ,  -12 , -12 , 0 , 0 , 0 , 12 , 12 , 24 ,

pquan InP
pquan InV

: doppler

  to current-note 
  to current-velocity

  current-note 48 = if rnd-bubble exit then 

  9 irnd ppp to offset-note          \ get element from table
  
  current-note offset-note +           \ actual note        	       
  dup 127 > swap 1 < or                \ exceed boundaries?
  if  exit then                        \ exit
  
  offset-note current-note /n* equalArray + !  	\ keep pitch
  
  current-velocity
  current-note offset-note +
  midi-thru-channel  mkd
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