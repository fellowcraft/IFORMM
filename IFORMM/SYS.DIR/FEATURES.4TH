\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ FEATURES -- stuff we just, didn't, know, where else to put.

loaded definitions create _features
only forth also definitions
vocabulary internals
decimal

th 80000000 constant -infinity
th 7fffffff constant +infinity
: NULL ;   \ relocatable NULL pointer (use instead of 0)

ifdef ATARI

: array
 create /n* allot
 does> swap /n* + ;

ifend

code 8<<
 sp )+ d0 move
 8 # d0 asl
 d0 sp -) move
c;

code 8>>
 sp )+ d0 move
 8 # d0 asr
 d0 sp -) move
c;

internals also definitions

0 constant alias-id
alias :-) +
' :-) 2+ @ ' alias-id >body token!

: unalias               ( CFA --- CFA )
\ find the real meaning of an aliased word
  begin
    dup 2+ @ alias-id =
  while
    6 + @
  repeat
;

: realias		( aliased-word new-meaning ; --- ; )
\ change the meaning of an aliased word
 defined if
  >r
  defined ?dup if
   r@ 10 + !
   r@ 6 + !
  else
   drop ." realias: source not found" count type
  then
  r> drop
 else
  ." realias: alias not found" count type blword drop
 then ;

: :cm
 [compile] :
 assembler also
;

: ;cm
 [compile] ;
 ['] assembler (except also
; immediate
