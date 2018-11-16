\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ DEFINE: basic double-colon constructs: ::ap and ::gp

loaded definitions create _define
only forth also ap-defs also
internals also definitions
decimal

\ 'Double colon' words indicate that execution of the enclosed code
\ is to run as a separate process or event
\ ::ap ;;ap  indicates the code runs as an active process
\ ::ev ;;ev  indicates the code runs as a high-level event
\ Since that code will not share the same stack as the caller,
\ the number of parameters it requires must be explicitly declared.
\ Normal syntax for this is:
\	::ap [ n params ] ... code ... ;;ap
\ where n is the number of parameters that must be transferred
\ NOTE: the params declaration is optional
\ (i.e., you don't need to declare 0 parameters).

\ The dictionary format of these words is (for ::ap)
\ (::ap
\ nargs
\ branch-address
\ jsr (::-docol
\ ... high-level code

forth definitions

: params		( n --- ; set # of parameters )
 params-OK? if
  params-addr !
 else
  ." can't use params here" cr exit
 then
; immediate

internals definitions

code ::ap-init-active	( CB --- ; )
 sp )+ a0 move
 addr who l#) a1 move
 poffset parent a1 d) tst	\ is caller top-level?
 0= if				\ yes
  poffset parent a0 d) clr
  ' wakeup-process l#) a2 lea
  a2 poffset wakeup-routine a0 d) move
  poffset mindel a1 d) poffset mindel a0 d) move
  poffset maxdel a1 d) poffset maxdel a0 d) move
ifdef _AUX_
  a0 poffset global-ptr a0 d) move
ifend
  BP-flag # poffset flags a1 d) btst	\ is caller a background process?
  0= if				\ no
   poffset time-position a1 d) poffset time-position a0 d) move
  else				\ yes - caller is a BP
   addr cur-SVT l#) d0 move
   poffset time-position a1 d) d0 cmp	\ is caller's TP behind cur-SVT?
   u> if			\ yes - new process gets cur-SVT for its TP
    d0 poffset time-position a0 d) move
   else				\ caller's TP is not behind cur-SVT -- inherit
    poffset time-position a1 d) poffset time-position a0 d) move
   then
\ The following line place the new process
\ one wakeup-buffer slot ahead of the BP caller.
\ This ensures that, when using MIDI clock, notes don't sound
\ until the clock starts.
   4 poffset time-position a0 d) addq
  then
  poffset time-position a0 d) d0 move
  poffset mindel a0 d) d0 sub
  d0 poffset deadline a0 d) move
 else				\ caller is not top-level
  poffset parent a1 d) poffset parent a0 d) move
  poffset time-position a1 d) poffset time-position a0 d) move
\ ifdef _AUX_
  poffset global-ptr a1 d) poffset global-ptr a0 d) move
\ ifend
 then
\ ifdef _AUX_
 poffset time-position a0 d) poffset internal-time a0 d) move
\ ifend
c;

: (::ap			( args --- ; compiled by ::ap )
\ the tricky part: the process's initial (pseudo-)CFA has to go on its
\ data stack ON TOP of its initial args.
 r@ @ 1+		\ get nargs+1
 r> na1+ dup @ >r	\ get branch address and arrange to branch
 na1+ swap		\ get pseudo-CFA of ::ap code
\ current affairs: args pseudo-CFA nargs+1
 active-create >r
 r@ ::ap-init-active
 r@ stack->cbstack
 r> awaken ;

code (::-docol		\ pseudo-CFA for ::xx definitions; called w/ jsr
 sp )+ ip move
 (unmask-softint)
c;

forth definitions

: :ap
 [compile] :
 ap-defs also
 ap-state to cstate ;

ap-defs definitions

: ::ap			( --- patch-addr magic# ; )
 cstate ap-state = if
  compile (::ap
  here to params-addr
  true to params-OK?
  0 ,			\ nargs, can be backpatched by params
  here 0 token,		\ branch address to be backpatched
  [ assembler ]
  ['] (::-docol l#) jsr
  [ forth ]
  1234			\ magic#
 else
  ." ::ap must be called within an active process definition" cr
 then
; immediate

: ::ap"
  [compile] ::ap
  compile assign-proc-ID 
  [compile] proc-name" 
; immediate


: ;;ap			( patch-addr magic# --- ; )
 1234 ?pairs
 false to params-OK?
 compile unnest
 here swap !
; immediate

: ;ap
 [compile] ;
 ['] ap-defs (except also
 no-state to cstate
; immediate

ifdef _GROUP_
internals definitions

code ::gp-init-active	( CB --- ; )
 sp )+ a0 move
 addr who l#) a1 move
 a1 poffset parent a0 d) move
 poffset internal-time a1 d) poffset time-position a0 d) move
\ ifdef _AUX_
 poffset global-ptr a1 d) poffset global-ptr a0 d) move
\ ifend
 poffset parent a1 d) tst		\ is caller top-level?
 0= if					\ yes
  BP-flag # poffset flags a1 d) btst	\ is caller a background process?
  0<> if				\ yes
   addr cur-SVT l#) d0 move
   poffset time-position a1 d) d0 cmp	\ is caller's TP behind cur-SVT?
   u> if			\ yes - caller process gets cur-SVT for its TP
    d0 poffset time-position a1 d) move
   then
  then
 then
\ ifdef _AUX_
 poffset time-position a0 d) poffset internal-time a0 d) move
\ ifend
c;

: (::gp			( args --- ; compiled by ::gp )
\ the tricky part: the process's initial (pseudo-)CFA has to go on its
\ data stack ON TOP of its initial args.
 r@ @ 1+		\ get nargs+1
 r> na1+ dup @ >r	\ get branch address and arrange to branch
 na1+ swap		\ get pseudo-CFA of ::ap code
\ current affairs: args pseudo-CFA nargs+1
 active-create >r
 r@ ::gp-init-active
 r@ stack->cbstack
 r> start-group ;

ap-defs definitions

: ::gp			( --- patch-addr magic# ; )
 cstate ap-state = if
  compile (::gp
  here to params-addr
  true to params-OK?
  0 ,			\ nargs, can be backpatched by params
  here 0 token,		\ branch address to be backpatched
  [ assembler ]
  ['] (::-docol l#) jsr
  [ forth ]
  696969			\ magic#
 else
  ." ::gp must be called within an active process definition" cr
 then
; immediate

: ;;gp			( patch-addr magic# --- ; )
 696969 ?pairs
 false to params-OK?
 compile unnest
 here swap !
; immediate

ifend

forth definitions

:ap ::ap"       ( ::ap" <name>"; allocates an id and a name to process )
[compile] ::ap
 compile assign-proc-ID
[compile] proc-name"
;ap
immediate

:ap fork	( name ; --- ; start a process )
 '
 ::ap" (forked)"
  [ 1 params ]
  execute
 ;;ap
;ap
