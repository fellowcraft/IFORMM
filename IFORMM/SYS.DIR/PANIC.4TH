\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ PANIC -- a facility for getting back to the Forth interpreter,
\ and restoring interrupt vectors, in panic situations.
\ Currently used for:
\ 1) panic button (undo key) handler
\ 2) out-of-memory error
\ 3) hardware exceptions

loaded definitions create _panic
only forth also
internals also definitions
decimal

code get-a34	( --- a3 a4 ; retrieves current values )
 a3 sp -) move
 a4 sp -) move
c;

get-a34

create a4-save token,
create a3-save token,

:cm (forth-context)
  a4-save l#) a4 move
  a3-save l#) a3 move
;cm

code forth-context		( --- ; establish forth context )
 (forth-context)
c;

\ stack space when have to reenter forth from interrupt level,
\ and stack pointers may be invalid.

 create temp-stack 200 allot

internals definitions

: (panic
 restore
 cr
 case
 0 of ." Out of memory." endof
 1 of ." Panic button detected." endof
 2 of ." Bus error." endof
 3 of ." Address error." endof
 4 of ." Illegal instruction." endof
 endcase
 cr ." -------- options: ----------------- "
 cr ." =================================== "
 cr ." showcrash     (Register Read Out) "
 cr ." crash-rstrace (Calling Word Sequence) "
 cr ." iformm        (Restart) "
 set-default-mask
 (abort	;

code panic
\ jump here from code words to get back in Forth and panic
\ d0 has error code
 (set-all-mask)				\ just in case

ifdef ATARI
 6850-intoff # MIDI-cr l#) bmove        \ turn off MIDI output int
 0 # th isrb l#) bmove                  \ clear 68901 interrupt in service bits
ifend

 (forth-context)
 sp0 @ l#) sp lea
 rp0 @ l#) rp lea
  ' (panic >body l#) ip lea
 d0 sp -) move
c;

code panic-be
 2 d0 moveq
 ' panic l#) jmp
end-code

code panic-ae
 3 d0 moveq
 ' panic l#) jmp
end-code

code panic-ie
 4 d0 moveq
 ' panic l#) jmp
end-code

hidden also

patch panic-be (.") .exception
patch panic-ae (.") .exception
patch panic-ie (.") .exception

