\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ TD -- time deformations at their *very* finest.

\ "tempo function" values have 8 fractional bits.
\ TD's maintain running integral (w/ 8 frac bits) in "value"
\ "delay" is remaining undeformed time advance (integer)

loaded definitions create _td
only forth also definitions
internals also decimal

vocabulary td-defs

internals definitions

code td-value	( delay pquan-addr --- value true | false ; call TD )
\ this clears the pquan when done
 sp ) a2 move
 a2 ) d0 move
 0= wif
  4 sp d) sp lea
  sp ) clr
 welse
  d0 a0 move
  4 sp d) poffset delay a0 d) move
  addr who l#) poffset retadr a0 d) move
  (switch-within-tree)
\ switch-within-tree returns with the other CB in a1
  poffset value a1 d) 4 sp d) move	\ return deformed delay
  poffset done a1 d) tst		\ is the TD done?
  0<> wif
   ' (free l#) jsr			\ yes --- free its CB
   sp ) a2 move
   a2 ) clr				\ and clear its slot
  wthen
  -1 d0 moveq
  d0 sp ) move				\ in any case, return true flag
 wthen
c;

: do-TDslots
 >r r@ pget delay	\ ds: deformed-delay;  rs: CB
 dup r@ paddr td1cb td-value
 if nip 8>> then
\ the following could be replicated for further TD slots, if you wanted
 r@ pget delay r@ paddr td2cb td-value
 if
  over r@ pget delay =
  if nip 8>>
  else
   r@ pget delay / ul* 8>>
  then
 then
 r> pto delay ;

' do-TDslots is do-aux

: td-init		( --- ; initialization for a TD )
 set-default-mask
 false to done
 0 to value ;

: td-fin		( --- ; finalization for a TD )
 delay 8<< addr value +!	\ take care of left-over advance
 true to done 
 pret ;

: td-create	( --- CB ; create time def )
 cbsize malloc
 dup init-passive
 ['] td-fin >body over tor ;

forth definitions

: :td
 [compile] :
 td-defs also
 td-state to cstate
; immediate

td-defs definitions

: td-return		( --- ; return td value )
 pret
 value 255 and to value ;	\ discard integer part of value

: ;td
 [compile] ;
 ['] td-defs (except also
 no-state to cstate
; immediate

: seg		( r1 r2 dt --- linear time def primitive )
 delay 0= if td-return then
 dup >r >r			\ dt tleft on return stack
 swap over over - 		\ r2 oldr r2-r1  on data stack
 begin delay r@ <
 while
  r> delay -			(s r2 oldr dr new-tleft )
  over over ul* r@ /		(s n-tl n-tl*dr/dt )
  swap >r			\ move new tleft back to ret stack
  3 pick swap -			(s r2 oldr dr newr )
  dup 3 pick + 2/ delay ul*	\ get delay*[newr+oldr]/2
  value + to value		\ add to value
  rot drop swap td-return	\ move newr to oldr
 repeat
 drop + 2/ r@ ul*		\ at end, deform remaining interval in seg
 value + to value
 delay r> - to delay		\ find left-over delay
 r> drop ;

: con		( r dt --- constant time def primitive )
 delay 0= if td-return then
 >r			\ r on data stack, time-left on return stack
 begin
  delay r@ <
 while
  r> delay - >r			\ decrement time left
  dup delay ul*			\ get delay*r
  value + to value
  td-return
 repeat
 r@ ul* value + to value	\ deform final subinterval
 delay r> - to delay ;		\ leave correct left-over time

: lpause		( dt --- put jump in time graph )
\ the pause happens BEFORE events scheduled for this instant
 8<< addr value +! ;

: rpause
\ the pause happens AFTER events scheduled for this instant
 delay 0= if td-return then
 lpause ;

: con.outer	( r dt --- ; like con, but length is in target time system )
 8<< 
 swap /
 con ;

: seg.outer	( r1 r2 dt --- ; like seg, but in target time system )
 >r 
 2dup + 2/		\ compute average tempo
 r>
 8<< 
 swap /
 seg ;
 
: inf-con	( r --- ; infinite constant TD segment )
 begin
  dup delay ul*
  value + to value
  td-return
 again ;

\ words to install TDs

internals definitions

: td1-setup	( CB --- ; )
 local-ptr pget td1cb ?dup if free then
 local-ptr pto td1cb ;

: td2-setup
 local-ptr pget td2cb ?dup if free then
 local-ptr pto td2cb ;

: gtd1-setup
 global-ptr pget td1cb ?dup if free then
 global-ptr pto td1cb ;

: gtd2-setup
 global-ptr pget td2cb ?dup if free then
 global-ptr pto td2cb ;

: ((::td	( compiled by ::td words )
\ following in dictionary: nargs, branch-addr, setup-CFA, pseudo-CFA
 r> dup @ 1+ swap na1+		\ nargs+1
 dup @ >r na1+			\ branch addr goes back on return stack
 dup @ >r			\ setup-CFA goes to return stack for now
 na1+ swap
\ current affairs: args pseudo-CFA nargs+1
 td-create >r
 r@ stack->cbstack
 r> r> execute ;		\ call the setup routine (with CB on stack)

: (::td		( setup-CFA --- patch-addr magic# ; )
 cstate ap-state = if		\ are we compiling?
  compile ((::td
  here to params-addr
  true to params-OK?
  0 ,				\ nargs (perhaps backpatched by params)
  here 0 token,			\ branch address (to be backpatched by ;;td)
  swap token,			\ setup-CFA
  [ assembler ] ['] (::-docol l#) jsr [ forth ]
  compile td-init
  td-state to cstate
  445566
  ['] ap-defs (except also
  td-defs also
 else
  ." ::td must be called within an active process definition." cr
 then ;

ap-defs definitions

\ these words are only valid within :ap definitions

: ::td1
 ['] td1-setup (::td ; immediate

: ::td2
 ['] td2-setup (::td ; immediate

: ::gtd1
 ['] gtd1-setup (::td ; immediate

: ::gtd2
 ['] gtd2-setup (::td ; immediate

td-defs definitions 

: ;;td		( patch-addr magic# --- ; )
 445566 ?pairs
 false to params-OK?
 compile unnest
 here swap !		\ backpatch branch address
 ['] td-defs (except also
 ap-defs also
 ap-state to cstate
; immediate

forth definitions

:ap itd1	( name ; ID --- ; install a new TD at an object )
 id->cb ?dup if		\ find the target process, error out if none
  '			\ find the TD word to run
  ::td1			\ fork a process running that word
   [ 1 params ]
   execute
  ;;td
  dup pget td1cb ?dup if free then	\ free the target's current td1
ifdef _RATIONAL_
\  dup paddr rscale td1cb pto rscale-ptr	\ TD's rscale-ptr points to target
 dup pget rscale-ptr td1cb pto rscale-ptr
ifend
  td1cb swap pto td1cb		\ make target's td1cb point to new TD
  0 to td1cb			\ unglue TD process from us
 then
;ap

:ap itd2
 id->cb ?dup if
  '
  ::td2
   [ 1 params ]
   execute
  ;;td
  dup pget td2cb ?dup if free then
ifdef _RATIONAL_
\  dup paddr rscale td2cb pto rscale-ptr
  dup pget rscale-ptr td2cb pto rscale-ptr
ifend
  td2cb swap pto td2cb
  0 to td2cb
 then
;ap
