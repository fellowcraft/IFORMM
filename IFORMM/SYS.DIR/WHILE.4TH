\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ WHILE ---- versions of the various WHILEs and REPEATs that support
\  BEGIN WHILE ...WHILE ...WHILE REPEAT

loaded definitions create _while
only forth also definitions

\ High level FORTH version:

th -1234 constant wiley		

: while   
 compile ?branch
 dup wiley <> if	\ first while?
  0 wiley		\ set up count and flag
 then
 >r >r			\ rs: #whiles wiley
 here -rot
 0 w,
 r> 1+			\ increment #whiles
 r>
; immediate

: repeat
 wiley = if
  >r
  compile branch ?<resolve
  r> 0 do
   here over - swap w!
  loop
 else
  ." repeat needs while" abort
 then
; immediate

\ Assembler versions:

assembler also definitions

: while
\ 1st instance:	( b-addr Condition --- w-addr addr count 11 )
\ subsequent instance:
( w-addr...b-addr count 11 Condition -- w-addr...w-addr b-addr count+1 11)
 [forth]
 >r
 dup 11 = if drop
 else 0
 then
 r> here dup rot complement-condition brif
 -rot
 1+ 11
;

: repeat   ( w-addr...w-addr b-addr count 11 --- ; )
 [forth]
 11 = if
  swap
  never complement-condition brif	\ compile jump to begin-addr
  0 do
   dup here offset swap 1+ byte!	\ patch all WHILEs
  loop
 else
  ." repeat called with while in code definitions" abort
 then ; 

: wwhile
\ 1st instance:  addr cookie cond --- br-addr addr count crumb)
\ subsequent instances:
\ (br-addr ... addr count crumb --- br-addr ... newbr-addr addr c+1 crumb)
[forth]
 >r
 dup 7787 = if
  drop 0 12123
 then
 12123 = if
  here dup r> complement-condition wbrif
  -rot 1+ 12123
 else
  r> drop ." wwhile incorrectly called in code word " abort
 then ;

: wrepeat	( addr br-addr cookie --- )
 12123 ?pairs
 [forth]
 swap 7787 never wuntil
 0 do
  dup 2+ here woffset [forth] swap 2+ w!
 loop ;
