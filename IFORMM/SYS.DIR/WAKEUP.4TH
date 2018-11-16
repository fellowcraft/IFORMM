\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ WAKEUP -- definition of, and operations on, the wakeup queue (WQ):
\	set of things waiting to get "woken up" at specific real times.
\	Each "thing" is currently either a CB or an event record.
\	The wakeup queue is implemented as an array of circular linked lists;
\	the array is indexed by low bits of wakeup time.

\ related code: wakeup methods for processes are in JOBCNTRL.

loaded definitions create _wakeup
only forth also
internals also definitions decimal

th 100 array wakeup-array	\ size is power of 2
th ff  constant wakeup-mask	\ size - 1
th 3fc constant wakeup-mask2	\ (size-1)*4

\ the following are offsets into wakeup-array
\ The invariant: at any point, the array slots of possible interest
\ are from first-offset to cur-offset, inclusive.
\ These may be equal.
\ If cur-offset catches first-offset (mod table size) we're screwed.
\ (this could be fixed, but I'm too lazy)

quan first-offset		\ first slot of interest
quan cur-offset			\ buffer offset corresponding to cur-SVT

code (rec->wakeup		( insert record in wakeup queue )
\ wake up at max of intended time (in record) and current SVT
\ input: record ptr in a1
 (set-mask)			\ mask ints now so cur-SVT doesn't change on us
 poffset wakeup-time a1 d) d0 move
 addr cur-SVT l#) d0 cmp
 u< if
  addr cur-SVT l#) d0 move
 then
 wakeup-mask2 l# d0 and		\ get index into wakeup array
 0 wakeup-array l#) a2 lea	\ base address
 d0 a2 adda			\ actual location
 a2 ) a0 move			\ get tail of list there
 ' (fifo-append l#) jsr		\ tack record on to end of list there
 a1 a2 ) move			\ store new tail
 (restore-mask)
 rts
end-code

code rec->wakeup	( rec --- ; put record in wakeup buffer )
 sp )+ a1 move
 ' (rec->wakeup l#) jsr
c;

code (arouse-process
\ put input handling processes into the wakeup queue,
\ with wakeup time == current SVT (i.e., now).
\ On entry, a1 points to CB (with time-position already set).
\ trashes d1, d1, a0
 BP-flag # poffset flags a1 d) btst 	\ background process?
 0= if					\ no---set deadline
  poffset time-position a1 d) d1 move
  poffset mindel a1 d) d1 sub		\ deadline = TP - mindel
  d1 poffset deadline a1 d) move
 then
 (set-mask)				\ as above, guard against cur-SVT change
 addr cur-SVT l#) d1 move
 d1 poffset wakeup-time a1 d) move	\ store in CB
 wakeup-mask2 l# d1 and			\ compute position in wakeup array
 0 wakeup-array l#) a2 lea 
 d1 a2 adda
 a2 ) a0 move				\ get old FIFO ptr
 ' (fifo-append l#) jsr			\ append new record
 a1 a2 ) move				\ store new FIFO tail
 (restore-mask)
 rts
end-code

code (wake-process
\ input: A0 points to process pointer word (zero or pointer to CB).
\ wake up this blocked process.
\ used by input interrupt routines (MIDI, keyboard, mouse)
 a0 ) tst
 0<> if
  a0 ) a1 move
  a0 ) clr
  addr cur-SVT l#) poffset time-position a1 d) move
  ' (arouse-process l#) jsr
 then
 rts
end-code

: init-wakeup
 cur-SVT wakeup-mask2 and
 dup to first-offset
 to cur-offset
 0 to softint-request
 0 to softint-mask-level
 256 0 do
  0 i wakeup-array !
 loop ;

:cm (update-cur-offset)
\ used in clock interrupt to update cur-offset
 addr cur-SVT l#) d0 move
 wakeup-mask2 l# d0 and
 d0 addr cur-offset l#) move
;cm

code (wakeup-check
\ called in the system clock routine to see if there's anything in the
\ wakeup buffer between first-offset and cur-offset, inclusive
\ (this is called after cur-offset is updated).
\ If so, set softint-request.
\ In any case, advance first-offset past empty slots other than the last one.
 addr first-offset l#) d0 move
 0 wakeup-array l#) a0 lea
 begin
  0 d0 a0 di) tst			\ something to do at this slot?
  0<> if					
   1 # addr softint-request l#) bmove	\ yes -- ask for softint
   d1 clr				\ this is to exit while
  else
   addr cur-offset l#) d0 cmp		\ scan up to (and including) now
  then
 0<> while
  4 d0 addq				\ go to the next slot
  wakeup-mask2 l# d0 and
 repeat
 d0 addr first-offset l#) move
 rts
end-code

quan for-now
quan not-now

code (wakeup-call
\ called in software interrupt handler to perform pending wakeups
\ (of processes and events).
\ All slots from first-offset up to and including cur-offset are checked.
\ Those entries with wakeup time <= cur-SVT are performed.

\ There is a tricky synchronization problem here, since
\ the system clock handler may advance cur-SVT (and perhaps cur-offset)
\ while this code is executing.
\ Our solution is as follows:
\ right after stashing first-offset in d0, store cur-offset in first-offset.
\ Search only up to and including this point.

 addr first-offset l#) d0 move	\ d0 holds offset throughout
 addr cur-offset l#) addr first-offset l#) move
 wbegin				\ loop until offset reaches the new first-offset
  0 wakeup-array l#) a3 lea
  d0 a3 adda			\ a3 is array pointer
  (set-all-mask)		\ need exclusive access to wakeup buffer
  a3 ) d2 move			\ FIFO tail object ptr in d2
  0<> wif			\ is the FIFO empty?
\ separate out the objects scheduled for this time or before.
\ a0 is current pointer into list
\ d1 is next object in list
\ for-now points to the first object for now, or zero.
\ a1 is last object for now
\ not-now points to the first object not for now, or zero.
\ a2 is last object not for now
\ d2 is cur-SVT
   d2 a1 move			\ tail ptr in a1
   a1 ) a0 move			\ head object ptr in a0
   a1 ) clr			\ zero out tail's link field
   addr for-now l#) a1 lea
   a1 ) clr
   addr not-now l#) a2 lea
   a2 ) clr
   addr cur-SVT l#) d2 move
   begin
    a0 ) d1 move		\ save link in d1
    poffset wakeup-time a0 d) d2 cmp
    u>= if			\ time to execute this object?
     a0 a1 ) move		\ yes - link to for-now list
     a0 a1 move
    else 	
     a0 a2 ) move		\ no - link to not-now list
     a0 a2 move
    then
    d1 a0 move			\ on to next object
    d1 tst
   0= until
   addr not-now l#) d1 move	\ anything not for now?
   0<> if
    d1 a2 ) move		\ yes - patch up array
    a2 a3 ) move
   else
     a3 ) clr
   then
   (set-default-mask)		\ unmask interrupts since done w/ buffer
   addr for-now l#) d2 move	\ anything scheduled for performance now?
   0<> if
    a1 ) clr
    d0 sp -) move		\ save perftime on stack
    begin
     d2 a1 move
     poffset wakeup-routine a1 d) a0 move
     a1 ) sp -) move
     a0 ) jsr
     sp )+ d2 move
    0= until
    sp )+ d0 move		\ restore perftime
   then
  wthen
  addr first-offset l#) d0 cmp
 0<> wwhile
  4 d0 addq
  wakeup-mask2 l# d0 and
 wrepeat
 rts
end-code
