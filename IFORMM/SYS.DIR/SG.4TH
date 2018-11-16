\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ SG -- sequence generators

loaded definitions create _sg
only forth also definitions
internals also

vocabulary sg-defs

code sg-value	( CB-ptr-addr --- value true | false )
 sp ) a2 move
 a2 ) d0 move		\ slot empty?
 0= wif
  sp ) clr		\ yes - return false
 welse
  d0 a0 move
  addr who l#) poffset retadr a0 d) move
  (switch-within-tree)
\ returns with other CB in a1
  poffset done a1 d) tst
  0<> wif
   ' (free l#) jsr
   sp ) a2 move
   a2 ) clr
   sp ) clr
  welse
   poffset value a1 d) sp ) move
   -1 d0 moveq
   d0 sp -) move
  wthen
 wthen
c;

internals definitions

: sg-fin
 true to done pret ;

: create-tsg	(  --- CB ; create a SG )
 cbsize malloc >r
 r@ init-passive
 false r@ pto done
 ['] sg-fin >body r@ tor
 r> ;

forth definitions

: :sg		( use this to define SG's called from other SG's )
\ ANY WORD DEFINED WITH THIS SHOULD GO IN SG-DEFS!!!!!
 [compile] :
 sg-defs also
 sg-state to cstate
 11336 ; immediate

sg-defs definitions

: ;sg
 11336 ?pairs
 [compile] ;
 ['] sg-defs (except also
 no-state to cstate ; immediate

: &		( result --- ; return value )
 to value pret ;

internals definitions

: (::tsg	( compiled by ::tsg )
\ on stack: args
\ following in dictionary: nargs, branch-addr, pseudo-CFA
 r> dup @ 1+ swap na1+		\ nargs+1
 dup @ >r			\ branch addr goes back on return stack
 na1+ swap			\ args pseudo-CFA nargs+1
 create-tsg
 tsgcb ?dup if  \ is there already a TSG?
   dup pget error  \ yes - get its roundoff error
   swap free       \ kill it
   over pto error  \ transfer error to new TSG
 then
 dup to tsgcb
 stack->cbstack ;		\ push params

ap-defs definitions

: ::tsg
 cstate ap-state = if
  compile (::tsg
  here to params-addr
  true to params-OK?
  0 ,			\ nargs, can be backpatched by params
  here 0 token,		\ branch address to be backpatched
  [ assembler ] ['] (::-docol l#) jsr [ forth ]
  sg-state to cstate
  882433
  ['] ap-defs (except also
  sg-defs also
 else
  ." ::tsg must be called within an active process definition." cr
 then ; immediate

sg-defs definitions

: ;;sg
 882433 ?pairs
 false to params-OK?
 compile unnest
 here swap !
 ['] sg-defs (except also
 ap-defs also
 ap-state to cstate ; immediate

forth definitions

:ap itsg
 id->cb ?dup if
  '
  ::tsg
   [ 1 params ]
   execute
  ;;sg
  dup pget tsgcb ?dup if free then
ifdef _RATIONAL_
  dup paddr rscale tsgcb pto rscale-ptr
  dup pget rscale-ptr tsgcb pto rscale-ptr
ifend
  tsgcb swap pto tsgcb
  0 to tsgcb
 then
;ap
