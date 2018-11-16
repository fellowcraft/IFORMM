\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ TTY-IN --- keyboard input handling

loaded definitions create _tty-in
only forth also
hidden also system also internals also definitions

\ Interface:
\ our-skey
\	The blocking key-input routine, called by (newexpect and key.
\	This is deferred to "fkey", which sleeps (rather than polls)
\	and does function-key handling (see FUNC-KEY).
\ key?
\	Deferred to "quick-key?" (below)

\ Implementation:
\	The TOS 6850 interrupt handler stashes keys into a buffer
\	(kbd-buf-rec, see below).
\	The FORMULA 200 Hz clock interrupt handler checks this TOS FIFO
\	and deals with the client process (the Forth interpreter)
\	through an input-handler struct

14 xbios: iorec { w.devno -- l.ibr }
quan kbd-buf-rec    \ initialized by +tty

variable old-kbd-tail-ptr
input-handler tty-in-struct

:cm (#keys-in-buffer)
\ leaves current number of keys in TOS buffer in d1
\ Z flag is set if 0
 d0 clr
 d1 clr
 addr kbd-buf-rec l#) a0 move
 6 a0 d) d0 wmove		\ get head pointer
 8 a0 d) d1 wmove		\ get tail pointer
 d0 d1 word cmp long			\ check that tail >= head
 u< if					\ if not, wraparound must have occurred
  4 a0 d) d1 word add long	\ so add buffer size to tail
 then
 d0 d1 word sub long			\ tail - head gives # bytes in buffer
 2 # d1 asr				\ 4 bytes per key
;cm

\ Called from sysclock-handler to deal with keyboard input.
\ Any number of keys may have been added to TOS buffer.
\ This checks for the UNDO key and panics if pressed.
\ Else it pokes the input handler structure,
\ waking up the sleeping process if there is one.

code ttyin-int-handler
 old-kbd-tail-ptr l#) d0 wmove		\ see if anything new in TOS FIFO
 addr kbd-buf-rec l#) a0 move
 8 a0 d) d0 word cmp long		\ since last time we checked
 0<> wif 				\ yes ---
  d1 clr
  8 a0 d) d1 wmove
  d1 old-kbd-tail-ptr l#) wmove
  a0 ) a0 move		\ check tail of buffer...
  0 d1 a0 di)  d2 move
  th 610000 l# d2 cmp			\ is it the UNDO panic button?
  0= wif				\ yes --- panic
   1 l# d0 move
   ' panic l#) jmp
  welse					\ no ---
   (#keys-in-buffer)			\ compute number of keys
   tty-in-struct l#) a0 lea		\ move to input handler struct
   d1 4 a0 d) move
   ' (wake-process l#) jsr		\ wake the process (if any)
  wthen
 wthen
 rts
end-code

code quick-key?		( --- flag ; )
\ this version of KEY? avoids calling TOS,
\ and therefore doesn't need to use semaphores.
\ (we assume only the main process ever does keyboard input)
 (set-mask)
 (#keys-in-buffer)
 (restore-mask)
 d1 tst
 0= if
  sp -) clr
 else
  -1 d0 moveq
  d0 sp -) move
 then
c;

\ The input count of the tty-input-structure becomes incorrect
\ while using the editor.  
\ This can generate an unpleasant side-effect if processes try to print 
\ things out: everything will halt until you hit a key

internals definitions

code correct-key-count
 (set-mask)
 (#keys-in-buffer)		\ get current  of unused keys
 d1 tty-in-struct 4 + l#) move	\ set input count to that number
 (restore-mask)
c;

forth definitions

: edit edit correct-key-count ;
alias ed edit

: -tty
 ['] skey is our-skey
 ['] sys-(key? is key?
 ['] sys-emit is (emit	
 ['] default-kh to key-handler ;
