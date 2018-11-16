\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ TTY-OUT --- display output with mutual exclusion for TOS calls.
\   This makes it possible for processes at different latencies
\   to do I/O without crashing

\ This file defines the semaphore and makes a few needed patches.

loaded definitions create _tty-out
only forth also
hidden also system also internals also definitions

semaphore: tos-sema		\ mutual exclusion for emit, key, etc.

\ Display output:
\ this is determined by the deferred word (emit, initially sys-emit.
\ usually it just needs to have a P and V put around it.

\ However TOS simulates a VT52 terminal where screen commands are transmitted 
\ as escape sequences.
\ These sequences must be completed w/o interruption, so the TOS semaphore 
\ must kept for the entire sequence.

\ Forthmacs more or less encapsulates escape sequences with the word "(esc".
\ Below semaphores are patched in.

: shemit
 tos-sema P
 sys-emit
 tos-sema V ;

\ special versions of "emit" for escape sequences

: Pemit
 tos-sema P
 sys-emit ;

: Vemit
 sys-emit
 tos-sema V ;

\ patch to install semaphore call around (ESC sequence
\ note: P and V are deferred so they can be safely called with
\ FORMULA turned off.

: PV(esc
 escape Pemit Vemit ;

' PV(esc is our-(esc
