\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.
\
\ AUX -- words for calling auxiliary processes.
\ Aux procs include shapes, sequence generators and time deformations.
\ TDs are called automatically by the various flavors of time-advance,
\ through the deferred word DO-AUX.
\ An SG is called whenever its value is needed.
\ A SHAPE is called whenever its value is needed and its time-system has 
\ advanced.  
\ It is also possible to call a shape directly with an 'artificial' 
\ time advance.

loaded definitions create _aux
only forth also
internals also definitions

\ the following are defined in active processes
\ pquan global-ptr	\ CB or QHN where "global" bound procs are
\ (moved to "proc-cb" for mundane reasons)
pquan local-ptr		\ same, locals; 
 			\ also used to point to a shape's 'time-system'.  

\ the following are defined in auxiliary processes
pquan retadr		\ CB of calling process
pquan done 		\ 1 iff aux proc is finished

pquan input		\ 'input' value, generally incremental delay
pquan value		\ 'output' value
pquan value2

code pret	( --- ; return from a co-routine )
 addr who l#) a1 move
 poffset retadr a1 d) a0 move
 (switch-within-tree)
c;

code pcall	( CB ---  CB ; call a co-routine )
 sp ) a0 move
 poffset done a0 d) tst
 0= if
  addr who l#) poffset retadr a0 d) move
  (switch-within-tree)
 then
c;

code tcall	( CB --- CB ; call a co-routine, but only when its )
\ time-system has advanced.
 sp ) a0 move
 poffset done a0 d) tst			\ is it done?
 0= if					\ no
  poffset local-ptr a0 d) a1 move
  poffset time-position a1 d) d0 move	\ has time passed?
  poffset time-position a0 d) d0 sub
  0<> if				\ yes 
    d0 poffset input a0 d) move	
    poffset time-position a1 d)  poffset time-position a0 d) move
    addr who l#) poffset retadr a0 d) move
    (switch-within-tree)
  then
 then
c;

ap-defs definitions

: raise-local-context
 local-ptr pget parent to local-ptr
;

: lower-global-context
 global-ptr pget child to global-ptr
;

forth definitions

: pvalue	( input-value CB --- output-value )
\ Used for 'artificial' calls to shapes.
 swap over pto input
 pcall
 pget value ;

\ the following are defined in active processes and QHN's

internals definitions

pquan tsgcb		\ timing sequence generator
pquan sh1cb		\ volume shapes
pquan sh2cb
pquan td1cb		\ time deformations
pquan td2cb
pquan ashcb		\ articulation shape

: (clear-aux		( QHN | CB --- ; get rid of aux processes )
   >r
   r@ pget tsgcb ?dup if free 0 r@ pto tsgcb then
   r@ pget sh1cb ?dup if free 0 r@ pto sh1cb then
   r@ pget sh2cb ?dup if free 0 r@ pto sh2cb then
   r@ pget td1cb ?dup if free 0 r@ pto td1cb then
   r@ pget td2cb ?dup if free 0 r@ pto td2cb then
   r@ pget ashcb ?dup if free 0 r@ pto ashcb then
   r> drop
;

forth definitions

: clear-aux	( ID --- ; )
   id->cb ?dup if (clear-aux then ;

ap-defs definitions

: clear-my-aux ( --- ; )
 who (clear-aux ;

internals definitions

: (.aux		( CB | QHN --- ; print an object's auxiliary process CB's )
dup pget tsgcb ."  tsgcb:" ?dup if 6  .r else 0 . 4 spaces then
dup pget sh1cb ."  sh1cb:" ?dup if 6  .r else 0 . 4 spaces then
dup pget sh2cb ."  sh2cb:" ?dup if 6  .r else 0 . 4 spaces then
dup pget td1cb ."  td1cb:" ?dup if 6  .r else 0 . 4 spaces then
dup pget td2cb ."  td2cb:" ?dup if 6  .r else 0 . 4 spaces then
dup pget ashcb ."  ashcb:" ?dup if 6  .r else 0 . 4 spaces then
drop ;

forth definitions

: .aux	( ID --- ; )
 id->cb ?dup if (.aux then ;

