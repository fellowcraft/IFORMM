\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ LBRANCH - assembly control structures with 16-bit offsets
\ this version supports multiple WWHILEs

loaded definitions create _lbranch
only forth also
assembler also definitions

: woffset	( source target --- offset )
 [forth] swap - th ffff and ;

: wbrif		( target-addr cond --- ; compile a branch instruction )
 th 6000 [forth] or w, here swap woffset w, ;

: wif		( cond --- br-addr cookie ; )
 here dup rot complement-condition wbrif 7787 ;

: wthen		( br-addr cookie --- ; backpatch )
 7787 ?pairs
 dup 2+ here woffset [forth] swap 2+ w! ;

: welse		( br-addr cookie --- br-addr cookie ; )
 7787 ?pairs
 never wif [forth] drop swap 7787 wthen 7787 ;

: wwhile	( addr cookie cond --- addr br-addr cookie )
 [forth] swap 7787 ?pairs
 wif ;

: wbegin	( --- addr cookie )
 here 7787 ;

: wuntil	( addr cookie cond --- )
 [forth] swap 7787 ?pairs
 complement-condition wbrif ;

: wagain	( addr cookie --- )
 never wuntil ;

: wrepeat	( addr br-addr cookie --- )
  7787 ?pairs
  [forth] swap 7787 never wuntil 7787 wthen ;
