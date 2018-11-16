\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ FORMULA --- initialization and interface words

loaded definitions create _formula
only forth also
ifdef MAC
windows also
ifend
internals also definitions decimal 

:ap idle-process		\ process that is always in execution queue
 ::ap
  +infinity to BP-deadline background
  immortal
  begin
  again
 ;;ap
;ap

:ap init-main-process	\ set up Forth interpreter as a process
 cbsize malloc
 to who
 who to main-process
 who init-active
 who to execution-queue		\ it starts as the head of execution queue
 0 to next-proc
 ['] wakeup-process to wakeup-routine
 cur-SVT to time-position
 first-BP-deadline to BP-deadline
 background
ifdef MAC
 the-current-window @ to my-wdp
ifend
\ ifdef _AUX_
 0 to internal-time
\ ifend
 100 to maxdel
 -20 to mindel
 0 to generation#
ifdef _RATIONAL_
 addr rscale to rscale-ptr
 2000 to rscale
ifend
 0 to parent
\ ifdef _AUX_
 who to global-ptr
\ ifend
ifdef _TUNING_
0 to tsptr
ifend
 assign-proc-ID
 proc-name" main-process"
;ap

: init-globals
 100000 to cur-SVT  \ make it big to avoid negative wakeup times
 0 to cur-SVT-frac
 1000 usec-per-SVT		\ SVT is in milliseconds
 0 to current-generation#
 0 to MIDI-clock
;

quan old-bye

: (formula-bye
  restore
  old-bye execute
;

: (restore     \ restore all vectors to their normal states
 formula-active if
  false to formula-active
  set-mask
ifdef _SEMAPHORE_
  -semaphore
ifend
ifdef _TOOLBOX_
 -toolbox
ifend
ifdef _DRAGHOOK_
 -drag-hook-sema
ifend
ifdef _APTEXT_
 dispose-ap-text-window
ifend
ifdef MAC
  -clock
  reset-SCCA
  +sniffer
  start-heap free-heap
ifend
ifdef ATARI
  -tty
ifend
  -mouse
  restore-intvecs
  restore-mask
  old-bye is bye
 then
;

' (restore is restore

forth definitions

: formula     ( --- ; initialize FORMULA )
 formula-active if
  exit
 then
\ ." FORMULA Version 4.0" cr
 save-intvecs
 ['] bye >body >user @ to old-bye
 ['] (formula-bye is bye
 true to formula-active
 init-mem-alloc
 init-ids
 init-globals            \ this must precede the next two
 init-main-process       \ make me into a process
 init-wakeup
ifdef _DOLLAR_
  init-$
ifend
ifdef _SM_
  init-SM
  ['] shift-convert to $pitch-convert
ifend

 set-mask
ifdef _SEMAPHORE_
 +semaphore
ifend
ifdef _TOOLBOX_
 +toolbox
ifend
ifdef _DRAGHOOK_
 +drag-hook-sema
ifend
ifdef _MIDI_
 +MIDI
ifend
 +perf
 +clock
ifdef MAC
 -sniffer
ifend
ifdef ATARI
 +tty
ifend
 +mouse
 restore-mask
ifdef _MIDI_
 create-MIDI-handler
ifend
 idle-process
;

: (cold-hook
  (cold-hook
ifdef ATARI
  next-free-mem @ to default-free-mem
ifend
\ formula
;

' (cold-hook is cold-hook

\ forth definitions

\ redefine save-rel to turn off formula;
\ otherwise state would be wrong on startup
\ : save-rel
\  formula-active swap
\  restore
\  save-rel
\  if formula then    \ resume formula if we were in it already
\ ;
