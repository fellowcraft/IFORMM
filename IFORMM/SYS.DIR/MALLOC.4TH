\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ MALLOC -- a fast 'n dirty memory allocation system.

\ Allocation is in multiples of 16 bytes.
\ An array of free lists of blocks of various sizes is maintained
\ (entry 0 is for 16-byte blocks, entry 1 for 32-byte blocks etc.).
\ Each block is preceded by a word giving the corresponding byte offset
\ into the array.
\ The first word holds the link while it's on the free list.

loaded definitions create _malloc
only forth also internals also definitions system also
decimal

4096 constant maxalloc		\ largest allocation size
maxalloc 16 / array freeptrs

ifdef MAC
quan heap-size
200000 to heap-size
quan start-heap
quan end-heap
quan next-free
ifend
ifdef ATARI
quan default-free-mem
next-free-mem @ to default-free-mem
ifend

code free-heap
 sp )+ a0 move                        \ load pointer to start of FORMULA heap
 th a01f ,                            \ Call DisposPtr
c;

ifend

: init-mem-alloc		( initialize the system )

ifdef MAC
 heap-size NewPtr to start-heap
 start-heap 0= abort" can't allocate heap"
 start-heap heap-size + 1- to end-heap
 start-heap to next-free
ifend
ifdef ATARI
 default-free-mem next-free-mem !
ifend

 maxalloc 16 / 0 do		\ empty all free lists
  0 i freeptrs !
 loop 
;

variable nalloc   \ # of allocated blocks (detect memory leaks)
variable nfree

code (malloc		( allocate memory )
\ entry: size in d0
\ exit: ptr in a1
\ if out of memory, panics.
\ trashes a0, a1, d1, d2
1 nalloc l#) addq
 (set-mask)
 1 d0 subq
 4 # d0 asr
 2 # d0 asl			\ d0 is byte offset into freeptrs
 0 freeptrs l#) a0 lea
 d0 a0 adda			\ a0 points to freeptrs element
 a0 ) d1 move
 0<> if				\ is there a block on list already?
  d1 a1 move
  a1 ) a0 ) move		\ yes - unlink it
 else
  d0 d2 move			\ no - compute total allocated size
  4 d2 addq
  2 # d2 asl
  4 d2 addq
ifdef ATARI
  next-free-mem l#) d1 move     \ see if enough room above dictionary
  d2 d1 sub
  dp l#) d1 cmp
  u< if
ifend
ifdef MAC
  addr next-free l#) d1 move
  d1 d2 add
  addr end-heap l#) d2 cmp
  u> if
ifend
   d0 clr			\ no - quit FORMULA
   d0 a1 move
   ' panic l#) jmp
  else
ifdef ATARI
   d1 next-free-mem l#) move    \ yes - allocate
ifend
ifdef MAC
   d2 addr next-free l#) move  	\ yes - allocate
ifend
   d1 a1 move
   d0 a1 ) move			\ fill in size offset
   4 a1 d) a1 lea
  then
 then
 (restore-mask)
 rts
end-code

code (free		( free a record )
\ input: a1 contains ptr to record
\ trashes: a0
1 nfree l#) addq
 (set-mask)
 0 freeptrs l#) a0 lea		\ ptr to freeptrs slot in a1
 -4 a1 d) a0 adda
 a0 ) a1 ) move			\ link free recs to rec
 a1 a0 ) move			\ put rec at head of free list
 (restore-mask)
 rts
end-code

forth definitions

code malloc		( nbytes --- ptr ; allocate memory )
 sp )+ d0 move			\ d0 is size
 ' (malloc l#) jsr
 a1 sp -) move
c;

code free		( ptr --- ; free previously allocated space )
 sp )+ a1 move
 ' (free l#) jsr
c;

ifdef ATARI
: new-dict-size   ( nbytes --- ; set max dictionary size )
 ['] max-image >body >r
 r@ @ -          \ get the delta
 dup memtop +!   \ add it to memtop
 r> +! ;         \ and to dict size

: new-heap-size   ( nbytes --- ; set heap size )
 ['] max-image >body @ + origin + memtop ! ;
ifend

ifdef MAC
: new-heap-size   ( nbytes --- ; )
 to heap-size ;
ifend
