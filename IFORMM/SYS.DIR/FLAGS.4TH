\ Copyright (c) 1986 by David Anderson and Ron Kuivila. All rights reserved.
\ IFORMM modofications: 
\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ FLAGS - compile-time flags

decimal only forth also definitions

ifndef loaded
vocabulary loaded
: lneeds	( load-flag file-name ; --- ; )
 bl word				\ Get load flag from input
 ['] loaded >body >user vfind	\ See if flag word is in loaded voc
 nip bl word dup ". bl emit ?cr	\ Get file name and echo it
 swap 0<> if
  drop			\ Flag defined, don't need to load file
 else
  "load			\ Flag isn't defined, load file
 then
 key?				\ Check for key to cancel
 abort" Action aborted"		\ If pressed then abort
;
ifend

loaded definitions
create _flags
only forth also definitions

\ exactly one of the following must be defined
  create ATARI
\ create MAC

\ create _STACKCHECK_		\ check for stack overflow on context switch?
 create _GROUP_			\ process groups?
 create _AUX_			\ auxiliary processes (slots)?
 create _FAQ_			\ future action queue?
 create _RATIONAL_		\ support rational time specification?
\ create _TIMEBOUND_		\ support time-max etc.?
\ create _SM_			\ synthesizer manager?
\ create _TUNING_		\ microtonal tuning systems?
 create _PTCHNAME_		\ symbolic pitch names?
\ create _PITCHSET_  	        \ pitch sets (scales etc.)
 create _DOLLAR_		\ dollar words?
\ _DOLLAR_ requires _AUX_, _RATIONAL_, and _FAQ_
 create _MIDI_			\ MIDI input and output?
\ create _SEMAPHORE_		\ semaphores?
ifdef MAC
  create _TOOLBOX_		\ support for toolbox calls
\ create _DRAGHOOK_		\ enable Toolbox preemption during DragHook
ifend
