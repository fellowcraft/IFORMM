\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ DEBUG -- various debugging tools

loaded definitions create _debug
only forth also definitions
internals also

: .eq		( print execution queue )
 ." summary of execution queue contents" cr
 ." (CB-addr, deadline, name)" cr
 mask-softint
 execution-queue
 begin
  dup .
  dup pget deadline . 
  dup pget name ?dup if .id else ." (anonymous)" then
  cr
  pget next-proc
  ?dup 
 0= until
 unmask-softint ;

: .wq		( --- ; print summary of wakeup queue )
 ." summary of wakeup buffer contents" cr
 ." (rec-addr, wakeup-time, name)" cr
 set-mask
 256 0 do
  i wakeup-array @ ?dup
  if
   cr ." entry " i . ." :" cr
   >r r@
   begin
    event-flag over test-flag 0=
    if
     dup .
     dup pget wakeup-time .
     dup pget name ?dup if .id else ." (unnamed process or group)" then
     ?cr
    else
     dup .
     dup pget wakeup-time .
     ." (event) "
     ?cr
    then
    pget next-proc
    dup r@
   = until
   r> 2drop
  then
 loop
 restore-mask ;
 
\ ***************************
\ event logging for debugging
\ ***************************
\ you can put lines of the form

\ 56 l# d0 move
\ (logadd)

\ into your assembly code, then look at the timestamped "log" afterwards.
\ Especially handy for debugging interrupt-level stuff!!

internals definitions
decimal

1024 array log	\ 512 2-word entries: code, SVT

quan logptr
quan logenable
quan logleft	\ entries left

: (logadd)  \ code in d0; trashes a0
 [ assembler ]
 addr logenable l#) tst
 0<> if
  1 addr logleft l#) subq
  0>= if
   addr logptr l#) a0 move
   d0 a0 )+ move
   addr cur-SVT l#) a0 )+ move
   a0 addr logptr l#) move
  then
 then
;

code logadd
 sp )+ d0 move
 (logadd)
c;

: loginit
 0 log to logptr
 1 to logenable
 512 to logleft
;

hidden also

: logdump
 #line off
 0 log
 begin
  dup logptr <>
 while
  dup @ . 4 +
  dup @ . 4 +
  cr
  ?end-of-screen
 repeat
 drop
;
