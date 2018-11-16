\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ QUEUE -- implementations of delay, absolute-time, and FIFO queues

loaded definitions create _queue
only forth also
internals also definitions

\ absolute-time queues are singly linked in increasing order of time-position.
\ link of last node is zero.

code (insert-deadline	\ insertion in deadline queue
\ entry: head ptr in a0, record in a1
\ exit: new head ptr in a0
\ trashes: d0, d1, d2, a2
 a0 d0 move
 0= if				\ handle empty queue as a special case
  a1 ) clr
  a1 a0 move
 else
  poffset deadline a1 d) d1 move	\ d1 is record's priority
  poffset deadline a0 d) d1 cmp
  u< if				\ new head of list?
   a0 a1 ) move
   a1 a0 move
  else
   a0 sp -) move		\ same head as before
   begin
    a0 ) tst
     0= if			\ at end?
     a1 a0 ) move		\ link to end
     a1 ) clr			\ zero empty tail ptr
    else
     a0 ) a2 move		\ no, get next object
     poffset deadline a2 d) d1 cmp	\ is it strictly later?
     u< if
      a1 a0 ) move		\ yes -- link in
      a2 a1 ) move
      d0 clr
     else
      a2 a0 move
      -1 d0 moveq
     then
    then
   0= until
   sp )+ a0 move
  then
 then
 rts
end-code

code insert-deadline	( rec-ptr head --- new-head )
 sp )+ a0 move			\ a0 is queue ptr
 sp )+ a1 move			\ a1 points to record
 ' (insert-deadline l#) jsr
 a0 sp -) move
c;

code (insert-time-position
\ entry: head ptr in a0, record in a1
\ exit: new head ptr in a0
\ trashes: d0, d1, d2, a2
 a0 d0 move
 0= if				\ handle empty queue as a special case
  a1 ) clr
  a1 a0 move
 else
  poffset time-position a1 d) d1 move	\ d1 is record's priority
  poffset time-position a0 d) d1 cmp
  u< if				\ new head of list?
   a0 a1 ) move
   a1 a0 move
  else
   a0 sp -) move		\ same head as before
   begin
    a0 ) tst
     0= if			\ at end?
     a1 a0 ) move		\ link to end
     a1 ) clr			\ zero empty tail ptr
    else
     a0 ) a2 move		\ no, get next object
     poffset time-position a2 d) d1 cmp	\ is it strictly later?
     u< if
      a1 a0 ) move		\ yes -- link in
      a2 a1 ) move
      d0 clr
     else
      a2 a0 move
      -1 d0 moveq
     then
    then
   0= until
   sp )+ a0 move
  then
 then
 rts
end-code

code insert-time-position	( rec-ptr head --- new-head )
 sp )+ a0 move			\ a0 is queue ptr
 sp )+ a1 move			\ a1 points to record
 ' (insert-time-position l#) jsr
 a0 sp -) move
c;

\ a FIFO queue is organized as a circular list linked head-to-tail
\ represented by a pointer to its tail or 0

code (fifo-append		\ add to end of a FIFO
\ entry: a0=tail, a1=record
\ exit: new tail in a1
\ trashes: d0
 a0 d0 move
 0= if			\ empty fifo
  a1 a1 ) move		\ link to self
 else
  a0 ) a1 ) move	\ link from new tail to head
  a1 a0 ) move		\ link from old tail to new tail
 then
 rts
end-code

code fifo-append	( rec tail --- new-tail ; append to end of FIFO )
 sp )+ a0 move
 sp )+ a1 move
 ' (fifo-append l#) jsr
 a1 sp -) move
c;
