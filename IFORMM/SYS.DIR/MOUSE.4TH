\ Copyright (c) 1986-1993 by David Anderson and Ron Kuivila.  All rights reserved.

\ MOUSE.ST --- mouse access on the Atari ST

\ +mouse ( --- ) installs mouse interrupt handling
\ This will maintain the quans mouse-x, mouse-y, left-button, right-button
\ (these can then be accessed from any process).

\ The mouse-handling process calls mouse-routine,
\ a deferred word (install your own)

\ Mouse input is not buffered, so the mouse process may not keep up with 
\ extremely fast key clicks.

loaded definitions create _mouse
only forth also definitions
internals also decimal

quan mouse-x			\ mouse x position
quan mouse-y			\ mouse y position
quan left-button		\ left button
quan right-button		\ right button
defer mouse-routine		\ handling routine pointer
' noop is mouse-routine

internals definitions

quan mouse-in-process		\ mouse handling process CB pointer
quan mouse-active		\ handshake flag between interrupt and process

code mouse-int	( mouse interrupt handler )
 -1 d0 moveq
 d0 addr mouse-active l#) move
 a0 ) d0 byte move	\ ptr to mouse record: ctrl mx my  all byte-size
 d0 d1 move		\ ctrl code, low 2 bits are l&r mouse clicks
 1 # d0 and
 d0  addr right-button 3 + l#) move
 1 # d1 lsr
 1 # d1 and
 d1 addr left-button 3 + l#) move
 1 a0 d) d0 move
 2 a0 d) d1 move
 d0 word ext
 d0 long ext
 d0 addr mouse-x l#) add
 d1 word ext
 d1 long ext
 d1 addr mouse-y l#) add
 
\ don't bother waking up the mouse-handler process
\ if the mouse routine is either crash or noop

 ' mouse-routine >body >user l#) d0 move
 ' crash l#) a0 lea
 a0 d0 cmp
 0= if
  rts
 then
 ' noop l#) a0 lea
 a0 d0 cmp
 0= if
  rts
 then
 addr mouse-in-process l#) a0 lea
 ' (wake-process l#) jsr
 rts
end-code

0 xbios: initmouse { a.vec a.param w.type -- } \ TOS call to initialize mouse

\ mouse-handling process.
\ calls the deferred word "mouse-routine" on each event

: (mouse-handler
 begin
  begin			\ loop because a new interrupt can happen
   set-mask		\ while we're handling an old one
   mouse-active
  while
   0 to mouse-active
   restore-mask
   mouse-routine	\ call the deferred word to handle input
  repeat
\ here when no more mouse input -- go to sleep
  who to mouse-in-process
  next-proc to execution-queue
  mask-softint
  restore-mask
  switch-to-XQ*
  unmask-softint
 again ;

forth definitions

:ap mouse-handler
 ::ap" mouse handler"
  immortal
  (mouse-handler
 ;;ap
;ap

: +mouse
\ Mouse in relative mode, interrupt increments variables
 0 to mouse-x 0 to mouse-y
 0 to left-button 0 to right-button
 0 to mouse-active
 0 to mouse-in-process
   th 00000101 pad !
    \ 01xxxxxx 0 at bottom of screen
    \ xx04xxxx mouse buttons act like keys   
    \ xxxx01xx sensitivity 1 mouse clicks in x direction
    \ xxxxxx01 sensitivity 1 mouse clicks in y direction   
 ['] mouse-int pad 1  initmouse
 mouse-handler
;

: -mouse
   th 00000101 pad !
    \ 01xxxxxx 0 at bottom of screen
    \ xx04xxxx mouse buttons act like keys   
    \ xxxx01xx sensitivity 1 mouse clicks in x direction
    \ xxxxxx01 sensitivity 1 mouse clicks in y direction   
 ['] mouse-int pad 1  initmouse
;
