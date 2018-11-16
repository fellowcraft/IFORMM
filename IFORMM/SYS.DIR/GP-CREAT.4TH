\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ GP-CREAT -- creation and deletion of hierarchical active processes.

loaded definitions create _gp-creat
only forth also
ap-defs also internals also definitions

code unlink-non-singleton	( obj --- parent )
\ Unlink the first element of non-singleton group.
\ Compute the resulting internal delay for the parent,
\ and propagate the new queue head's first-descendant.
 sp )+ a1 move			\ a1 = this
 poffset parent a1 d) a0 move	\ a0 = parent
 a1 ) a2 move			\ a2 = next
 a2 poffset child a0 d) move
 poffset first-descendant a2 d) poffset first-descendant a0 d) move
 poffset external-time a2 d) d0 move
 poffset external-time a1 d) d0 sub
 d0 poffset delay a0 d) move
 a0 sp -) move
c;

: revive-group	( CB --- ; turn a group back into a process )
\ software interrupts are masked on return
 mask-softint
 0 over pto child
 group-flag over clear-flag		\ it's a process again!
 dup dup pto first-descendant		\ parent is its own first descendant
 execution-queue pto first-descendant ;	\ and also that of the XQH

: gp-active-exit		\ make the caller go away
 who fin-active
 parent if			\ is caller top-level?
  next-proc if			\ no -- does caller have sibling?
   who unlink-non-singleton	\ yes - unlink from group
   process-delay		\ propagate resulting delay to top
   mask-softint
   process-XQH-delay*		\ and handle delay at top
  else
   parent revive-group		\ no sibling -- revive parent group
  then
 else				\ caller is top-level
  mask-softint
  next-proc to execution-queue
 then
\ in any case, arrive here with softints masked
 who free
 switch-to-XQ*
 unmask-softint ;		\ never reached!!

realias active-exit gp-active-exit

: start-group	( CB --- ; start the first process in a group )
\ this is called from the process that executes the ::gp (i.e., the group)
 >r
 group-flag who set-flag		\ make the caller a group
 r@ to child
 0 r@ pto next-proc
 r@ to first-descendant
 mask-softint
 r> execution-queue pto first-descendant
 switch-to-XQ*			\ start up the new process
 unmask-softint ;		\ resume here when group is empty
