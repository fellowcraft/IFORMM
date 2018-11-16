\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ FRACTION --- convenient notation for rhythmic values 
\ and fixed point numbers with 8 fractional bits.
\ The notations are:

\ A.B interprets and compiles to (A*256)/B
\ A|B interprets and compiles to A B r>i
\ A(B interprets and compiles to A B (r>i
\ +fraction patches the feature into ] and [
\ -fraction returns things to normal.

loaded definitions create _fraction
only forth also
internals also definitions decimal hidden also

quan num-type	\ holds ascii "|", ".", or "("
\ dpl is a Forthmacs variable that is set by "convert":
\ -1 if no decimal point, else chars to the right of the decimal point

: (frac-literal?	( addr --- value flag )
\ addr is the address of a packed string (length, bytes)
\ return true if the string is a literal (including fractional notation)
\ if so, return the value, ignoring the separator symbol
\ the separator symbol is in num-type, and its position is in dpl

 >r 0
 r@ dup 1+ c@ 45 =	\ neg-flag
 dup >r -		\ skip - if needed (sleazy)
 -1 dpl !		\ dpl holds decimal point count
 begin			(s value char-ptr )
  convert		\ convert up to first non-numeric (also sets dpl)
  dup c@ >r		\ get that char
  ascii | r@ = 		\ is it |, ., or ( ?
  ascii ( r@ = or
  ascii . r@ = or
  dup if
   r> to num-type
  else
   r> drop
  then
 while
  0 dpl !
 repeat
(s value char-ptr )
 r> if			\ test neg-flag
  swap negate swap	\ negate if needed
 then
 r> count + =		\ see if final char-ptr is end of string
;

: frac-literal?		( str-addr --- str-addr false | literal true )
\ check if the string is a literal (including fraction notation)
\ set num-type, dpl if so
 >r r@ (frac-literal?
 if
  r> drop true
 else
  drop r> false
 then ;

: interpret-frax		( value --- ; called after frac-literal? )
 dpl @ 0>= if			\ compound number?
\ yes --- compute divisor to split number
  dpl @ if		
   1 dpl @ 0 do
    base @ *
   loop
  else
   1
  then
\ s: num divisor
\ split into cases according to separator char
  num-type ascii . = if		\ fixed point?
    swap 8<< swap /
  else
   /mod				\ s: denom num
   over 0<> if 			\ fractions cannot have 0 denominator
    num-type ascii | = if
     swap r>i
    else
     num-type ascii ( = if
      swap (r>i
     then
    then
   then
  then
 then ;

: compile-frax	( value --- ; )
 dpl @ 1+ 0<> if		\ compound literal?
\ yes --- compute divisor to split number
  dpl @ if
   1 dpl @ 0 do
    base @ *
   loop
  else
   1
  then
  num-type ascii . = if
   swap 8<< swap /
   [compile] literal
  else
   /mod
   over 0<> if
    num-type ascii | = if
     [compile] literal [compile] literal ['] r>i token,
    else
     num-type ascii ( = if
      [compile] literal [compile] literal ['] (r>i token,
     then
    then
   then
  then
 else
  [compile] literal
 then
;

: frac[
 ['] frac-literal? ['] literal? (is
 ['] interpret-do-defined ['] do-defined (is
 ['] interpret-frax ['] do-literal (is
 ['] interpret-do-undefined ['] do-undefined (is state off ; 
immediate

: frac]
 ['] frac-literal? ['] literal? (is
 ['] compile-do-defined ['] do-defined (is
 ['] compile-frax ['] do-literal (is
 ['] compile-do-undefined ['] do-undefined (is state on ;

: +fraction
 ['] frac] ['] (] (is
 ['] frac[ ['] ([ (is
 [compile] [ ;

: -fraction
 ['] ((] ['] (] (is
 ['] (([ ['] ([ (is
 [compile] [ ;
