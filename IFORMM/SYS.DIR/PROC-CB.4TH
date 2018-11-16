\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ PROC-CB --  CB structure and event record structure

\ This file defines the structure of several different record types:
\ - process context blocks (CBs)
\ - event records (output events waiting to happen)
\ - future action records (procedures waiting to be called)
\ - messages
\ - differential action records
\ - time control structure stack entries
\ ...?

loaded definitions create _proc-cb
only forth also
internals also definitions
decimal

1000 constant dstacksize		\ data stack size
400 constant rstacksize		\ return stack size

\ The following pquans are required by at least two of the object types:

pquan next-proc			\ next process in linked lists
pquan time-position
pquan wakeup-time
pquan delay
pquan flags			\ only top 8 bits are used.  definitions below.
pquan wakeup-routine		\ address of routine to be invoked when
	\ object is awakened from wakeup queue (events, CB's, QHN's)
	\ or CFA of word to execute (future actions)

\ At this point things bifurcate.
\ Event and action records have a set of parameters, stored in nargs and args.
\ CB's and QHN's just have more pquans.

\ NOTE: the synth manager assumes that there are at least 16 bytes
\ of space before nargs

forth definitions

pquan mindel
pquan maxdel

internals definitions

alias nargs mindel
alias args maxdel
poffset args constant action-rec-size

\ alias for use in other structures, e.g. ports
alias pquan0 next-proc
alias pquan1 time-position
alias pquan2 wakeup-time
alias pquan3 delay
alias pquan4 flags
alias pquan5 wakeup-routine

\ CB-specific stuff (i.e., fields used by processes only) follows 
\ The following three fields are used to save the state
\ of a non-preempted process.
\ In FORTH, this is the state of the IP (a5), the RP (a6), and the SP (a7).
\ The code word that does context switching uses MOVEM for efficiency; so, 
\ the following fields are in the order movem stores them. 
\ DON'T MESS WITH THEM. (see definition of switch in the file PROCESS)

pquan ip-save			\ interpretive pointer save slot
pquan rp-save			\ return stack ptr save slot
pquan sp-save			\ data stack ptr save slot

alias arg0 maxdel
alias arg1 ip-save
alias arg2 rp-save

\ Careful about adding anything before here

pquan deadline
pquan parent			\ ptr to parent group (or zero if none)
pquan child
pquan preempted-CB
\ While an activity (top-level process or group) is preempted,
\ this pquan (in the top-level object)
\ points to the CB in which to resume the activity.

pquan first-descendant
\ In group CBÕs, points to the earliest descendant.
\ In non-group CB's, points to the CB itself.

alias external-time time-position

\ ifdef _AUX_
 pquan internal-time
 pquan global-ptr
\ otherwise
\ alias internal-time time-position
\ ifend

ifdef MAC
pquan my-wdp    \ Window Data Pointer for this process
ifend

dstacksize pallot	\ data stack size
pquan dstack		\ top of data stack
rstacksize pallot	\ return stack size
pquan rstack		\ top of return stack

\ handy offsets for routines defined later
\ 0 constant next-offset
poffset delay	    constant delay-offset
poffset nargs     constant nargs-offset
poffset args      constant args-offset

\ bit definitions for "flags" pquan

0 constant preempted-flag	\ relevant only for objects in execution queue
	\ i.e., top-level groups and processes.  Always clear when executing.
1 constant group-flag
2 constant suspend-pending-flag
3 constant suspended-flag
4 constant zombie-flag		\ set (in an active process) if it's
	\ already killed, and we're just playing out future events
5 constant event-flag		\ true in event records,
	\ false in future action records
6 constant BP-flag		\ 1 ==> it's a background process

code set-flag	( bit# CB --- ; works only for bits 0-7 )
 sp )+ a0 move
 sp )+ d0 move
 d0 poffset flags a0 d) bset
c;

code clear-flag	( bit# CB --- ; )
 sp )+ a0 move
 sp )+ d0 move
 d0 poffset flags a0 d) bclr
c;

code test-flag	( bit# CB --- flag ; )
 sp )+ a0 move
 sp )+ d0 move
 d0 poffset flags a0 d) btst
 0= if
  sp -) clr
 else
  -1 l# sp -) move
 then
c;
