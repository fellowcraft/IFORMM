\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ RANDOM -- various random number generators

loaded definitions create _random
only forth also
internals also definitions

\ Our uniform RNG here uses an algorithm invented by John Reiser,
\ as described in volume 1 of Knuth

55 array rndtab
quan rndind

forth definitions

: rnd		( --- n ; get a random # in range 0 .. 2**32-1 )
 rndind 1- dup 0< if drop 54 then	\ decrement rndind mod 55
 to rndind
 rndind rndtab dup @			\ dst-addr, dst-contents on stack
 rndind 24 + dup 54 > if 55 - then	\ get index plus 24
 rndtab @				\ get the number at index plus 24
 + dup rot ! ;

: rndinit 	( n --- ; initialize rng using n )
 55 0 do 69069 ul* dup i rndtab ! loop drop
 0 to rndind
 100 0 do rnd drop loop ;

th 37472817 rndinit

internals definitions

code (scale	( n r --- m ; do the dirty work for irnd )
\ n must fit in 16 bits
 sp )+ d0 move
 d0 swap
 sp ) d1 move
 d0 d1 mulu
 d1 swap
 d1 2 sp d) wmove
c;

forth definitions

: irnd		( n --- m ; random # in range 0 .. n-1 )
 rnd (scale ;

: brnd		( --- 0 | 1 ; random bit )
 rnd wflip 1 and ;

: grnd		( n --- m ; random # from normal distribution with
		mean zero and std. dev. of n )
 0 12 0 do 1200 irnd + loop
 7200 - * 1200 / ;

internals definitions

pquan frnd2-tab 28 pallot
pquan frnd2-val

: (frnd2	( --- n ; 32-bit number from 1/f random sequence )
 0 rnd 1 or
 begin
  swap 1+ swap
  dup 0>=
 while
  1 <<
 repeat drop
 8 min
 0 do
  i /n* addr frnd2-tab + @ negate frnd2-val + to frnd2-val
  rnd th 1fffffff and dup i /n* addr frnd2-tab + !
  frnd2-val + to frnd2-val
 loop
 frnd2-val ;

forth definitions

: frnd2		( m --- n ; return 1/f element in range 0 .. m-1 )
 (frnd2 (scale ;

: frnd2-init
 0 to frnd2-val
 8 0 do
  rnd th 1fffffff and
  dup frnd2-val + to frnd2-val
  i /n* addr frnd2-tab + !
 loop ;

internals definitions

quan bitprob
quan bitmask
quan limit

forth definitions

: frnd3				( n1 n2 -- n3	; n1 is old frnd; n3 is new )
  1 to bitmask			\ 		0 to n2-1 is range
  th 80000000 to bitprob
  dup to limit 1-
  begin
    dup
  while
    rnd bitprob u< if		\ flip bit i with prob 1/(2**(i+1))
      swap bitmask xor swap
    then
    bitmask 1 << to bitmask 
    bitprob 1 >> to bitprob 
    1 >>
  repeat
  drop dup limit >= if
    limit 2* swap - 1-
  then ;

\ The following words deal with "PDF tables" describing
\ a distribution over 0 .. n-1
\ The table format is:
\  total weight
\  list of entries

: xtrnd	( table-addr n --- ; given a PDF table and number n )
\ (n < total weight) return the corresponding index
 >r
 na1+ dup
 begin		( weight-left on return stack; base, ptr on data stack )
  dup @
  r> swap -
 dup 0>= while
  >r na1+
 repeat
 drop swap - 2 >> ;

: trnd	( table-addr --- n ; get random sample from tabular PDF )
 dup @ irnd
 xtrnd ;
