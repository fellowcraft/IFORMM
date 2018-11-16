\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ GP-SCHED -- scheduling of hierarchical (grouped) processes

loaded definitions create _gp-sched
only forth also
internals also definitions ap-defs also

: gp-awaken		( CB --- ; )
\ insert a new CB with the caller's time position.
\ If the caller (creator) is in a group, the new process goes in
\ the same group after the caller
 parent if				\ is caller in a group?
  next-proc over pto next-proc
  to next-proc
 else				\ no - use real-time version
  RT-awaken
 then ;

realias awaken gp-awaken

code propagate-delay	( CB --- parent ; )
\ The given object has a delay (in external units) in its delay field.
\ Add that to its external time position, and reinsert in the queue.
\ Compute the resulting change in the parent group's internal time position,
\ and store that in the delay field of the parent.
\ Also propagate first-descendant up from the new queue head.
 sp )+ a1 move			\ object in a1
 poffset external-time a1 d) d0 move
 d0 d3 move			\ save QH's external time (parent's internal)
 poffset delay a1 d) d0 add	\ add delay to its time position
 d0 poffset external-time a1 d) move
 a1 ) a0 move			\ next in a0
 ' (insert-time-position l#) jsr	\ new QH returned in a0
 poffset parent a0 d) a1 move	\ parent in a1
 a0 poffset child a1 d) move	\ make it point to new QH
 poffset first-descendant a0 d) poffset first-descendant a1 d) move
 poffset external-time a0 d) d0 move	\ get new QH's external time
 d0 poffset internal-time a1 d) move	\ == group's new internal time
 d3 d0 sub			\ subtract parent's old internal time
 d0 poffset delay a1 d) move	\ that's the group's delay
 a1 sp -) move			\ return pointer to group
c;

: process-delay	 	( CB --- ; )
\ The object has an internal time advance in its "delay" field.
\ - convert the advance into external time units and store in delay
\ - if in a group:
\     update the external time position
\     update queue and pass resulting delay to parent group (iterate up tree)
\ - if top-level, just return.
\ Hence no need to mask interrupts.
 begin
ifdef _AUX_
  dup pget delay if dup do-aux then
ifend
  dup pget parent
 while
  propagate-delay
 repeat
 drop ;

internals definitions

: gp-time-advance	 	( delay --- ; advance calling process )
ifdef _AUX_		\ internal time exists only if aux flag is on
 dup addr internal-time +!	\ set up for GP-advance-object
ifend
 to delay
 who process-delay	\ let the delay percolate up
 mask-softint
 process-XQH-delay*	\ and handle what comes out at the top
 switch-to-XQ*
 unmask-softint ;

realias time-advance gp-time-advance
