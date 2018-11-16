\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ HANDLER --- interface between interrupt routines and I/O handler processes 

loaded definitions create _handler
only forth also definitions internals also

\ an input handler structure consists of 2 words: 
\ 1: the process CB 
\ 2: the input count
: input-handler	( <name> --- create an input handler structure )
 create 
 0 , 0 ,
 does> ;

code wait-for-input	( handler-structure --- ; )
 sp ) a0 move
 (set-mask)
 4 a0 d) tst				\ is there input?
 0= wif
  addr execution-queue l#) a1 move	\ no - sleep 
  a1 a0 ) move				\ put proc-CB in handler-slot
  a1 ) addr execution-queue l#) move	\ set new XQ-head
  (mask-softint)
  (restore-mask) 
  ' (switch-to-XQ* l#) jsr		\ and switch to it.
  (unmask-softint)
 welse
  (restore-mask)
 wthen
 sp )+ a0 move
 1 4 a0 d) subq				\ decrement count
c;

\ called from interrupt handler to wake process, if any
\ a0 points to the handler structure
code (wake-input-handler
 1 4 a0 d) addq		\ increment input counter
 ' (wake-process l#) jsr
 rts
end-code
