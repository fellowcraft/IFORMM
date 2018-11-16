\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ PROCUSER -- simple user interface to processes

\ This file contains the following facilities:
\ 1) symbolic names for processes
\ 2) small-integer ID's for processes
\ 3) interactive pquan manipulation
\ 4) process info display

\ JOBCNTRL has process control functions (kill, suspend, resume)

loaded definitions create _procuser
only forth also
internals also definitions

\ ********** symbolic naming

pquan name		\ pointer to symbolic name, or zero

: (pn")		( runtime word for proc-name" )
 skipstr drop 1- to name ;

forth definitions

: proc-name" 		( name ; --- ; name this process )
 compile (pn") ," ; immediate

\ *********** small integer ID's

internals definitions

pquan id			\ -1 means no ID

256 constant #ids		\ #ids must be power of 2
#ids array cb-ids		\ table, indexed by ID, of CB ptrs; 0 if free
variable lastid			\ byte offset to last ID used

: init-ids
 #ids 0 do
  0 i cb-ids !
 loop
 0 lastid ! ;

: free-id		( ID | -1 --- ; free an ID )
 dup 0>= if
  0 swap cb-ids !
 else
  drop
 then ;

code (assign-ID		( CB ---  ; allocate an ID to process )
 lastid l#) d0 move
 #ids 1- l#  d1 move
 0 cb-ids l#) a0 lea
 sp )+ a2 move
 begin			\ try to assign the next ID in order
  4 d0 addq
  #ids 1- 4* l# d0 and
  0 d0 a0 di) tst
 0= d1 dbuntil
 0 d0 a0 di) tst
 0= if			\ see if out of ID's
  d0 lastid l#) move  
  a2 0 d0 a0 di) move
  2 # d0 asr
  d0 poffset id a2 d) move	\ if not, fill in the CB's ID field
 then
c;

: id->cb		( id --- cb | 0 ; convert ID or CB to CB )
 dup #ids < if
  cb-ids @
 then ;

forth definitions

: assign-proc-ID
 who (assign-ID ;

\ ********** interactive pquan manipulation

: ipto		( pquan-name ; value ID --- ; store in a process's pquan )
  id->cb ?dup if
 		 [compile] pto
 	then ;

: ipget		( pquan-name ; ID --- value ; get a process's pquan )
  id->cb ?dup if
  		[compile] pget
  then ;

\ ******** process display

internals definitions

: .stack	( top bottom --- ; print stack from bottom to top )
 over - dup 0>		\ check for positive stack size
 if
  dup 40 >
  if			\ truncate after 40 bytes (10 items)
   ." ..." drop 40
  then
  over + 4 - do i ? -4 +loop 
 else
  0=
  if ." empty"
  else ." bad stack ptr"
  then
  drop
 then
 cr ;

forth definitions

: .cb		( ID | CB --- ; print a context block )
 id->cb ?dup 0= if exit then
 80 rmargin !
 >r pquanlist
 begin
  dup ['] NULL <>
 while
  20 .tab
  dup 4 - dup body> >name .id ." : " @ r@ + @ . @
  exit? if r> drop drop exit then
 repeat drop
 cr ." ds: " r@ pget sp-save r@ paddr dstack .stack
 cr ." rs: " r@ pget rp-save r> paddr rstack .stack ;

internals definitions

: (.cb-summary	( CB --- ; print summary of context block )
 ." ID: " dup pget id dup -1 = if drop dup then .
 ."  name: " dup pget name ?dup if .id else ." (anonymous) " then
 ."  type: " group-flag over test-flag if ." group" else ." process" then
 suspended-flag over test-flag if ."  [suspended]" then
 drop cr ;

: ((.gp*	( n CB --- ; print group hierarchy with indentation n )
\ softints must be masked since structure could change under us
 recursive
 over spaces
 dup (.cb-summary
 group-flag over test-flag
 if
  pget child
  begin		( n CB )
   dup
  while
   over 2+ over ((.gp*
   pget next-proc
  repeat
 then
 2drop ;		\ drop n

forth definitions

: .gp		( ID --- ; )
 id->cb ?dup if
  mask-softint
  0 swap ((.gp*
  unmask-softint
 then ;
 
: .all		( --- ; print summary of everything with an ID )
\ because of the ID table, this doesn't have to mask interrupts,
\ so it doesn't stop the music.
 #ids 0 do
  i cb-ids @
  ?dup if (.cb-summary then
 loop ;
