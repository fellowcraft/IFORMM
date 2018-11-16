\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ RATIONAL -- rational time specification.

\ The scheme is as follows: every process has a pquan "rscale-ptr"
\ which points to the scaling factor for rational-integer conversion.
\ For active processes, this points to a pquan "rscale" of that process.
\ For shapes, TD's, and SG's, it points to the "rscale" of the creator.
\ Each process also maintains its own round-off error.
\ Durations may then be specified in rational form,
\ and are converted to integer by r>i.

loaded definitions create _rational
only forth also definitions
internals also decimal

pquan rscale		\ may hold scaling factor for rational conversion

: beats-per-minute	( n --- ; )
\ adjust rscale so that there are n quarter-notes per minute
\ assuming the SVT is in milliseconds
 240000 swap / to rscale ;

internals definitions

pquan rscale-ptr	\ pointer to a scaling factor (may be elsewhere)
pquan error		\ accumulated roundoff error

\ code (r>i)			\ convert rational tspec to integer
\ ( numerator denominator tempo old-error --- time-advance new-error )
\ computes num*tempo/denom + fractional-error
\ sp )+ d0 move			\ d0=error
\ sp )+ d1 move			\ d1=tempo
\ sp ) d2 move	 		\ d2=denominator
\ 4 sp d) d3 move		\ d3=numerator
\ d3 d1 mulu			\ tempo*num in d1
\ d2 d1 divu			\ tempo*num/denom (new-rem, quotient)
\ d1 d3 move			\ new-rem*2^16 in d3
\ th ffff0000 l# d3 and
\ d2 d3 divu			\ error = (new-rem*2^16)/denom
\ d1 swap
\ d3 d1 wmove			\ combine to get total fixed point advance
\ d0 d1 add			\ add in old error
\ word
\ sp ) clr
\ d1 2 sp d) move
\ d1 swap
\ 4 sp d) clr
\ d1 6 sp d) move
\ long
\ c;

\ **** I'm not convinced that we need the following -- DPA

code (r>i)	 ( num denom rscale old-error --- result new-error )
\ convert rational time interval to integer
\ errors are 16-bit fractions
\ result is integer part of (num*rscale)/denom + old-error;
\ new-error is fractional part
 sp )+ d0 move			\ d0=error
 sp )+ d1 move			\ d1=rscale
 sp ) d2 move	 		\ d2=denom
 4 sp d) d3 move		\ d3=num
 d2 d3 cmp	
 u> if		\ If num >denom, compute integer part of scaling separately
  d2 d3 divu			\ yes---compute numerator/denominator
  d3 d4 move
  d3 swap			\ d3=fractional part to do
  th ffff l# d3 and
  th ffff l# d4 and
  d1 d4 mulu			\ d4=integer part of scaling
 else
  0 d4 moveq			\ no---d4=0
 then
 d3 d1 mulu			\ tempo*num in d1
 d2 d1 divu			\ tempo*num/denom (new-rem, quotient)
 d1 d3 move			\ new-rem*2^16 in d3
 th ffff0000 l# d3 and
 d2 d3 divu			\ error = (new-rem*2^16)/denom
 d1 swap
 d3 d1 wmove			\ combine to get total fixed point advance
 d0 d1 add			\ add in old error
 sp ) word clr long
 d1 2 sp d) wmove
 d1 6 sp d) wmove
 d1 swap
 th ffff l# d1 and
 d4 d1 add
 d1 4 sp d) move
c;

forth definitions

: r>i		( num denom --- int-advance )
 rscale-ptr @ error (r>i) to error ;

: (r>i		( num denom --- int-advance ; same, but error not used )
 rscale-ptr @ th 8000 (r>i) drop ;
