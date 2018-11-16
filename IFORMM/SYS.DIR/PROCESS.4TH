\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ PROCESS -- basic process creation and context-switching primitives

\ More or less independent of the scheduling mechanism

loaded definitions create _process
only forth also
internals also definitions

ifdef MAC
windows also
ifend

\ A non-executing process may be in either of two states:
\ 1) "Non-preempted" state:
\   a return address is on its hardware return stack,
\   (** reminder: hardware return stack == Forth data stack == a7 **)
\   and its a5-a7 are saved in the "ip-save", "rp-save" and "sp-save" pquans.
\   You can context switch to it by restoring a5-a7 and doing an rts.
\   A newly-created process must be set up in this state.
\   Context switches are always done with software interrupts masked;
\   the process must call unmask-softint at some point after return.
\ 2) "Preempted" state:
\   Atari: an exception frame and all regs are on the return stack,
\     and a7 is saved in "sp-save".
\     To switch to it, restore a7, pull regs and rte.
\   Mac: processes are preempted within "deferred tasks"; their stacks look like
\     a0-a3, d0-d3, other stuff
\     return address to deferred task manager
\     a4-a6, d4-d7
\     old contents of th d92 ("deferred task in progress" flag)
\     a7 is saved in "sp-save".
\     You switch to a process by restoring a4-a6/d4-d7 and doing an rts

:cm (restore-forth-state*)
\ restore Forth registers from a given CB, and make it the current process.
\ input: CB in a0
 poffset ip-save a0 d) th e000 # long movem	\ load ip, rp, sp
 a0 addr who l#) move	

ifdef MAC
 poffset my-wdp a0 d) the-current-window l#) lmove
ifend
;cm

:cm (save-forth-state*)
\ save the Forth registers for the current process
\ leaves a1 pointing to the CB
 addr who l#) a1 move
 th e000 # poffset ip-save a1 d) movem	\ save current ip, rp, sp
ifdef MAC
 the-current-window l#) poffset my-wdp a1 d) lmove
ifend
;cm

:cm (restore-machine-state*)
\ restore the state of a preempted process
\ input: CB in a0
 a0 addr who l#) move
 poffset sp-save a0 d) sp move		\ restore sp

ifdef MAC
 poffset my-wdp a0 d) the-current-window l#) lmove
 sp )+ th d92 l#) word move long
 sp )+ th 70f0 # long movem
ifend
ifdef ATARI
 sp )+ th 7fff # movem                  \ restore other registers
ifend
;cm

code (switch-within-tree*
\ Non-preemptive context switch within a single tree
\ Used for bound processes, e.g.
\ input: CB ptr in a0
 (save-forth-state*)
 (restore-forth-state*)
 rts				\ resume suspended process
end-code

:cm (switch-within-tree)
\ JSR used to ensure processing resumes with next instruction
 (mask-softint)
 ['] (switch-within-tree* l#) jsr
 (unmask-softint)
;cm
