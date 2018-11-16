\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ STACK -- utility words for manipulating the stack and action records.

loaded definitions create _stack
only forth also
internals also definitions

code tor	( n CB --- ; move word to another proc's return stack )
 sp )+ a0 move
 poffset rp-save a0 d) a1 move
 sp )+ a1 -) move
 a1 poffset rp-save a0 d) move
c;

code tod	( n CB --- ; move word to another proc's data stack )
 sp )+ a0 move
 poffset sp-save a0 d) a1 move
 sp )+ a1 -) move
 a1 poffset sp-save a0 d) move
c;

code fromd	( CB --- n ; move word from another proc's data stack )
 sp )+ a0 move
 poffset sp-save a0 d) a1 move
 a1 )+ sp -) move
 a1 poffset sp-save a0 d) move
c;

code fromr	( CB --- n ; move word from another proc's return stack )
 sp )+ a0 move
 poffset rp-save a0 d) a1 move
 a1 )+ sp -) move
 a1 poffset rp-save a0 d) move
c;

ifdef _STACKCHECK
: check-stacks	( CB --- ; check for stack over/underflow )
 >r
 r@ pget rp-save rstacksize + r@ paddr rstack <
 if ." return stack overflow in " r@ . abort then
 r@ pget rp-save r@ paddr rstack >
 if ." return stack underflow in " r@ . abort then
 r@ pget sp-save dstacksize + r@ paddr dstack <
 if ." data stack overflow in " r@ . abort then
 r@ pget sp-save r@ paddr dstack >
 if ." data stack underflow in " r@ . abort then
 r> drop ;
ifend

:cm (stack->record)		( args #args --- )
\ input and output: record pointer in a1
\ trashes a2, d0
 sp )+ d0 move			\ get #args
 d0 poffset nargs a1 d) move
 poffset args a1 d) a2 lea
 begin
  1 d0 subq
 0>= while
  sp )+ a2 )+ move
 repeat
;cm

:cm (make-action-rec)	( args nargs --- ; make action record )
\ returns record ptr in a1
\ trashes a0, a2, d0, d1, d2
 sp ) d0 move
 2 # d0 asl
 action-rec-size l# d0 add
 ['] (malloc l#) jsr
 (stack->record)
;cm

code make-action-rec
 (make-action-rec)
 a1 sp -) move
c;

:cm (record->stack)	 	( --- args )
\ input: record ptr in a1
 poffset nargs a1 d) d0 move	\ get # of args
 d0 d1 move
 2 # d1 asl			\ convert to # of bytes
 poffset args d1 a1 di) a0 lea
 begin
  1 d0 subq
 0>= while
  a0 -) sp -) move
 repeat
;cm

code record->stack	\ transfer record contents to caller's stack
 sp )+ a1 move
 (record->stack)
c;

code stack->cbstack		( args #args CB --- ; move args to CB )
\ used in message-passing
 sp )+ a0 move			\ target CB
 sp )+ d0 move			\ # of words
 2 # d0 asl			\ convert to # bytes
 d0 d1 move
 d0 poffset sp-save a0 d) sub	\ make room on target stack
 poffset sp-save a0 d) a0 move	\ get that SP
 begin
  4 d0 subq
 0>= while
  0 d0 sp di) 0 d0 a0 di) move
 repeat
 0 d1 sp di) sp lea
c;

code ndup	( words n --- words n words n )
 sp ) d0 move	\ n in d0
 d0 d2 move
 1 d2 addq
 2 # d0 asl	\ n*4 in d0
 begin
  0 d0 sp di)l d1 move
  d1 sp -) move
  1 d2 subq
 0= until
c;

code reverse	( args n --- sgra n ; reverse n parameters )
 sp ) d0 move		\ get n
 2 # d0 asl		\ sp+4*n is the addr of the bottom parameter
 sp d1 move
 d1 d0 add
 d0 a0 move		\ a0 points to bottom param
  4 d1 addq		\ sp+4 is the addr of top parameter
 d1 a1 move		\ a1 points to top param
 begin
  a0 a1 cmpa		\ keep reversing while a0>a1
 < while
  a0 ) d0 move
  a1 ) d1 move
  d1 a0 ) move
  4 a0 subq
  d0 a1 )+ move
 repeat
c;

code transpose	( matrix m n --- mraitx m n ; transpose matrix )
\ stack originally contains n groups of m words

 sp )+ d0 move		\ n in d0
 sp )+ d1 move		\ m in d1
 d1 d2 move
 d0 d2 mulu		\ m*n in d2
 d2 d3 move
 2 # d3 asl		\ m*n*4 in d3

\ copy the matrix

 sp a0 move		\ save original stack ptr in a0
 sp d4 move
 d3 d4 sub
 d4 sp move		\ make room on stack
 d2 d4 move		\ counter for words
 a0 a1 move		\ scanning ptr
 begin
  d4 tst
 0<> while
  -4 d3 a1 di) d5 move
  d5 a1 -) move
  1 d4 subq
 repeat

\ move the copy back in transposed order

 d0 d2 move		\ outer loop counter
 d0 d3 move
 2 # d3 asl		\ n*4 in d3
 begin
  d2 tst
 0<> while
  a0 a1 move
  d1 d4 move		\ inner loop counter
  begin
   d4 tst
  0<> while
   sp )+ d5 move
   d5 a1 ) move
   0 d3 a1 di) a1 lea
   1 d4 subq
  repeat
  4 a0 addq
  1 d2 subq
 repeat

 d1 sp -) move		\ restore sizes
 d0 sp -) move
c;
