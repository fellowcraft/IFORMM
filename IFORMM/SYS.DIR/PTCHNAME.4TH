\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ PTCHNAME -- words for symbolic naming of 12-tone pitches

loaded definitions create _ptchname
only forth also
internals also definitions

pquan octave-offset		\ pitch offset representing current octave

ap-defs also definitions

: oct		( n --- ; set current note to c in octave n; c3 = middle c )
 2+ 12 * to octave-offset ;

: -oct
 octave-offset 12 - to octave-offset ;

: +oct
 octave-offset 12 + to octave-offset ;

: r		( zero means rest )
 0 ;

internals definitions

: n#		( n --- pitch-index; find n + k*12 closest to cur )
 octave-offset + ;

: +n		( n --- pitch-index; next strictly higher than current )
 octave-offset + 12 + ;

: -n		( n --- pitch-index; next note strictly lower )
 octave-offset + 12 - ;

ap-defs definitions

: c- -1 n# ;	: c 0 n# ;	: c+ 1 n# ;
: d- 1 n# ;	: d 2 n# ;	: d+ 3 n# ;
: e- 3 n# ;	: e 4 n# ;	: e+ 5 n# ;
: f- 4 n# ;	: f 5 n# ;	: f+ 6 n# ;
: g- 6 n# ;	: g 7 n# ;	: g+ 8 n# ;
: a- 8 n# ;	: a 9 n# ;	: a+ 10 n# ;
: b- 10 n# ;	: b 11 n# ;	: b+ 12 n# ;

: -c- -1 -n ;	: -c 0 -n ;	: -c+ 1 -n ;
: -d- 1 -n ;	: -d 2 -n ;	: -d+ 3 -n ;
: -e- 3 -n ;	: -e 4 -n ;	: -e+ 5 -n ;
: -f- 4 -n ;	: -f 5 -n ;	: -f+ 6 -n ;
: -g- 6 -n ;	: -g 7 -n ;	: -g+ 8 -n ;
: -a- 8 -n ;	: -a 9 -n ;	: -a+ 10 -n ;
: -b- 10 -n ;	: -b 11 -n ;	: -b+ 12 -n ;

: +c- -1 +n ;	: +c 0 +n ;	: +c+ 1 +n ;
: +d- 1 +n ;	: +d 2 +n ;	: +d+ 3 +n ;
: +e- 3 +n ;	: +e 4 +n ;	: +e+ 5 +n ;
: +f- 4 +n ;	: +f 5 +n ;	: +f+ 6 +n ;
: +g- 6 +n ;	: +g 7 +n ;	: +g+ 8 +n ;
: +a- 8 +n ;	: +a 9 +n ;	: +a+ 10 +n ;
: +b- 10 +n ;	: +b 11 +n ;	: +b+ 12 +n ;
