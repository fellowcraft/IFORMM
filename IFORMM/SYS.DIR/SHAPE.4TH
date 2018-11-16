\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ SHAPE -- words for defining and using shapes.

loaded definitions create _shape
only forth also definitions
internals also

vocabulary sh-defs

code sh-value	( CB-ptr-address --- value true | false ; get shape value )
\ the basic idea: CB-ptr-address points to a slot pquan
\ returns false if nothing in that slot, or it's done
\ clears the pointer if shape is done
 sp ) a2 move		\ slot empty?
 a2 ) d0 move
 0= wif
  sp ) clr		\ yes, leave a false
 welse
  d0 a0 move		\ no, get CB
  poffset local-ptr a0 d) a1 move
  poffset internal-time a1 d) d0 move	\ is shape's time-position behind?
  d0 d1 move
  poffset time-position a0 d) d1 sub
  0<> wif				\ yes 
   d1 poffset input a0 d) move		\ put net delay in input
   d0 poffset time-position a0 d) move
   addr who l#) poffset retadr a0 d) move
   (switch-within-tree)			\ call the shape
\ switch-within-tree returns with the other CB in a1
   poffset done a1 d) tst			\ is the shape done?
   0<> wif
    ' (free l#) jsr			\ yes --- free its CB
    sp ) a2 move
    a2 ) clr				\ clear its slot
    sp ) clr				\ and return false
   welse
    poffset value a1 d) sp ) move	\ return shape value
    -1 d0 moveq
    d0 sp -) move			\ and a true flag
   wthen
  welse
   poffset value a0 d) sp ) move	\ same time pos -- return shape value
   -1 d0 moveq
   d0 sp -) move			\ and a true flag
  wthen
 wthen
c;

internals definitions

: sh-fin	( finalization routine for shapes )
 true to done
 pret ;

: sh-create	( --- CB ; create shape instance )
\ called from sh-setup, which then does other work (e.g., get initial value)
 cbsize malloc >r			\ get a CB
 r@ init-passive			\ initialize it for passive process
 false r@ pto done
 ['] sh-fin >body r@ tor		\ make sure it finishes nicely
 r> ;

forth definitions

: :sh
 [compile] : sh-defs also
 sh-state to cstate ; immediate

sh-defs definitions

: ;sh
 [compile] ;
 ['] sh-defs (except also
 no-state to cstate ; immediate

: ratio		( special words for legato shapes )
 0 to value2 ;

: relative
 1 to value2 ;

: absolute
 2 to value2 ;

: ocon		( val dt --- ; open constant-valued shape primitive )
 swap to value
 begin		( tleft on data stack )
  input - dup 0>
 while
  pret
 repeat
 negate to input ;

: ccon		( val dt --- ; closed constant-valued shape primitive )
 swap to value
 begin
  input - dup 0>=
 while
  pret
 repeat
 negate to input ;

: oseg		( y1 y2 dt --- open shape segment )
 dup >r >r		\ dt tleft on return stack
 dup rot -      	\ y2 dy on data stack
 begin
  r> input - dup 0>	\ y2 dy new-tleft on data stack
 while
  over over * r@ / 	\ y2 dy ntl ntl*dy/dt
  3 pick swap -
  to value pret >r
 repeat
 negate to input
 2drop r> drop ;

: cseg		( y1 y2 dt --- closed shape segment )
 dup >r >r
 dup rot -
 begin
  r> input - dup 0>=
 while
  over over * r@ /
  3 pick swap -
  to value pret >r
 repeat
 negate to input
 2drop r> drop ;

: inf-con	( y --- ; infinite constant shape segment )
 to value
 begin pret again ;

\ words for installing shapes

internals definitions

code sh-setup	( shape-CB target-CB slot-offset --- ; )
 4 sp d) a1 move			\ get target CB
 8 sp d) a0 move			\ get shape CB
 poffset internal-time a1 d) poffset time-position a0 d) move	
					\ shape gets target's time-position
 a1 poffset local-ptr a0 d) move	\ target is its 'local context'
 addr who l#) poffset retadr a0 d) move	\ get the shape's initial value
 poffset input a0 d) clr
 (switch-within-tree)
\ switch-within-tree returns with the other CB in a1
 poffset done a1 d) tst		\ did it die?
 0<> wif
  ' (free l#) jsr		\ yes --- free CB
  0 l# a1 move			
 wthen				\ a1 is new shape CB
 sp )+ d0 move	
 sp )+ d0 add			\ compute slot addr
 d0 a0 move
 a0 ) d0 move			\ get current contents
 a1 a0 ) move			\ update w/ new CB
 d0 tst
 0<> wif
  d0 a1 move
  ' (free l#) jsr
 wthen 
 4 sp addq
c;

: sh1-setup	( CB --- ; )
 local-ptr poffset sh1cb sh-setup
;

: sh2-setup
 local-ptr poffset sh2cb sh-setup
;

: gsh1-setup
 global-ptr poffset sh1cb sh-setup
;

: gsh2-setup
 global-ptr poffset sh2cb sh-setup
;

: ash-setup
 local-ptr poffset ashcb sh-setup
;

internals definitions

: ((::sh	( compiled by ::sh words )
\ following in dictionary: nargs, branch-addr, setup-CFA, pseudo-CFA
 r> dup @ 1+ swap na1+		\ nargs + 1
 dup @ >r na1+			\ branch addr goes back on return stack
 dup @ >r			\ setup-CFA goes to return stack for now
 na1+ swap
\ current affairs: args pseudo-CFA nargs+1
 sh-create >r
 r@ stack->cbstack
 r> r> execute ;		\ call the setup routine (with CB on stack)

: (::sh		( setup-CFA --- patch-addr magic# ; )
 cstate ap-state = if		\ are we compiling?
  compile ((::sh
  here to params-addr
  true to params-OK?
  0 ,				\ nargs (to be backpatched by params)
  here 0 token,			\ branch address (to be backpatched)
  swap token,			\ setup-CFA
  [ assembler ] ['] (::-docol l#) jsr [ forth ]
\ here we may compile in any initialization routines
  sh-state to cstate
  112233
  ['] ap-defs (except also
  sh-defs also
 else
  ." ::sh must be called within an active process definition." cr
 then ;

ap-defs definitions

: ::sh1 
 ['] sh1-setup (::sh ; immediate
  
: ::sh2 
 ['] sh2-setup (::sh ; immediate

: ::gsh1 
 ['] gsh1-setup (::sh ; immediate
  
: ::gsh2 
 ['] gsh2-setup (::sh ; immediate

: ::ash
 ['] ash-setup (::sh ; immediate

: ::sh		( --- CB ; define a slotless shape )
 ['] noop (::sh ; immediate

sh-defs definitions 

: ;;sh		( patch-addr magic# --- ; )
 112233 ?pairs
 false to params-OK?
 compile unnest
 here swap !		\ backpatch branch address
 ['] sh-defs (except also
 ap-defs also
 ap-state to cstate
; immediate


