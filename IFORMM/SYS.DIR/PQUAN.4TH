\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ PQUAN -- per-process variable stuff (actually quans)

\ quans and pquans act similarly; the name by itself gets the value
\ (in the current process), and "to" and "addr" work alike.
\ "pget", "pto" and "paddr" take CB on top of stack and apply to
\ another process's pquans.

\ The dictionary structure is as follows:
\ For quans, the PF is one word and contains the value.
\ For pquans, the PF is two words: the CB offset, followed by a
\ link pointing to the link field of the previously defined pquan.
\ The quan "pquanlist" points to the most recently defined pquan.

loaded definitions create _pquan
only forth also definitions

: quan		( name ; declare a quan )
 create 0 ,
;code
 sp ) a0 move
 a0 ) sp ) move
c;

: vect		( name ; declare a vector--a quan w/ relocation )
 quan here 4 - set-relocation-bit
;

quan who
			
internals also definitions

0 constant pquanid			\ backpatched after pquan definition
0 constant quanid

: notquan	( cfa --- ; report use of quan operation on non-quan )
 >name .id ." is not a quan" cr ;

: quan?	( cfa --- cfa ; print error & return 1 level up if not quan or pquan )
 dup 2+ @
 dup quanid <> swap pquanid <> and
 if notquan r> drop drop then ;

: pquan?	( cfa --- cfa ; same, check for pquan only )
 dup 2+ @
 pquanid <> if notquan r> drop drop then ;

code (to
 ip )+ a0 move
 sp )+ a0 ) move
c;

code (adr		\ same as (lit); need for decompiling
 ip )+ sp -) move
c;

: tto
 >body state @
 if compile (to token, else ! then ; 

: adr
 >body state @
 if compile (adr token, then ;

code (ito
 ' who >body l#) a0 move
 ip )+ a0 adda
 sp )+ a0 ) move
c;

: ito       ( n pquan-pfa --- ; pquan case of TO )
 >body @ state @
 if
  compile (ito ,
 else
  who + !
 then ; 

code (iadr
 ' who >body l#) d0 move
 ip )+ d0 add
 d0 sp -) move
c;

: iadr		( pquan-pfa --- who+offset ; get address of pquan )
 >body @ state @
 if
  compile (iadr ,
 else
  who +
 then ;

forth definitions

: to
 ' unalias quan? dup 2 + @
 case
  pquanid of ito endof
  quanid of tto endof
 endcase ; immediate

: addr
 ' unalias quan? dup 2 + @
 case
  pquanid of iadr endof
  quanid of adr endof
 endcase ; immediate

' who 2 + @ ' quanid 6 + token!		\ address of docon

internals definitions

vect pquanlist		\ top of list of currently defined pquans 
			\ this needs to be relocated
' NULL to pquanlist

code (pto
 sp )+ a0 move
 ip )+ a0 adda
 sp )+ a0 ) move
c;

code (pget
 sp )+ a0 move
 ip )+ a0 adda
 a0 ) sp -) move
c;

code (paddr
 ip )+ d0 move
 d0 sp ) add
c;

code (poffset
 ip )+ sp -) move
c;

forth definitions

: pto		( name ; value cb --- ; store into another proc's pquan )
 ' unalias pquan?
 >body @ state @
 if
  compile (pto ,
 else
  + !
 then ; immediate
 
: pget		( name ; cb --- value ; get value of another proc's pquan )
 ' unalias pquan?
 >body @ state @
 if
  compile (pget ,
 else
  + @
 then ; immediate

: paddr		( name ; cb --- address ; get address of another proc's pquan )
 ' unalias pquan? >body @ state @
 if
  compile (paddr ,
 else
  +
 then ; immediate

quan cbsize		\ current context block size

: pallot	( n --- ; allocate CB space )
 cbsize + to cbsize ;

: pquan		( name ; --- ; define a per-process quan )
 cbsize constant /n pallot
 here pquanlist token, to pquanlist		\ link to pquanlist
;code
 here ' pquanid 6 + token!
 addr who l#) a0 move
 sp ) a1 move
 a1 ) a0 adda
 a0 ) sp ) move
c; immediate

: poffset	( name ; --- offset ; return offset of a per-proc quan )
 ' unalias pquan?
 >body @ state @
 if
  compile (poffset ,
 then ; immediate 

: forget	( name ; --- ; updates size and links for pp quans )
 forget
 0 pquanlist
 begin
  here over <
 while swap drop dup @
 repeat		(s 0 list-top | lowest-forgotten list-top )
 ?dup if
  to pquanlist
  ?dup if
   /n - @ to cbsize
  then
 else
  drop 0 to cbsize ['] NULL to pquanlist
 then ;


