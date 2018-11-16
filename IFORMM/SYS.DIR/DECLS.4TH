\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ DECLS - various declarations that it's convenient to have first

loaded definitions create _decls
only forth also definitions internals also

vocabulary ap-defs

defer restore
' noop is restore

internals definitions

quan main-process	\ CB of main process (i.e., the Forth interpreter)
quan MIDI-clock		\ what makes time go?
			\ 0 for internal clock, 1 for MIDI clock
quan formula-active

\ the following are defined in INITDEF.

defer init-active
defer fin-active
defer init-passive

\ ifdef _AUX_
defer do-aux ' noop is do-aux
\ ifend

\ cstate keeps track of what kind of word is currently being compiled.
quan cstate
0 constant no-state
1 constant ap-state		\ active process
2 constant sh-state		\ shape
3 constant td-state		\ time deformation
4 constant sg-state		\ sequence generator

\ the following are used while compiling ::xx ... ;;xx definitions
\ to handle the [ n params ] construct
quan params-OK?			\ true only within :: -type definition
false to params-OK?
quan params-addr		\ address to backpatch with # of params

\ the following are words that are redefined one or more times
\ depending on which features are enabled in FLAGS

: nada
 ." Aliased word not defined -- see DECLS" cr
 abort
; immediate

ap-defs definitions

alias time-advance nada		( delay --- ; advance time position )
\ defined in rt-sched, gp-sched, faq, timebnd

alias future-event nada		( args nargs proc-addr delay --- ; )
\ defined in fevent, faq

alias awaken nada		( CB --- ; awaken process )
\ defined in rt-sched, gp-sched

internals definitions

alias active-exit nada		( --- ; caller exits )
\ defined in rt-sched, gp-creat, faq
