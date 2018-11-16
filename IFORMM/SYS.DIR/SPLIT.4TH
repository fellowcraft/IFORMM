\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ Makes the bottom half of the screen scroll without affecting the top half.
\
\ split-screen		Scroll the bottom half of the screen
\ whole-screen		Scroll the whole screen

only forth also hidden definitions
: scroll-bottom  ( -- )
   (#lines 2/  1+ 0 at delete-line
   (#lines 1- 0 at
   #out off  1 #line +!
;
: half-#lines   ( -- n ) (#lines 2/ 1+ ;

only forth hidden also forth definitions

: split-screen  ( -- )
   ['] scroll-bottom is cr
   ['] half-#lines is #lines
;
: whole-screen  ( -- )
   ['] crlf          is cr
   ['] (#lines       is #lines
;

: scroll-bot2  ( -- )
   23 0 at delete-line
   (#lines 1- 0 at
   #out off  1 #line +!
;

: 2scroll-screen ( -- )
  ['] scroll-bot2 is cr
  23 is #lines
;

: scroll-bot1  ( -- )
   24 0 at delete-line
   (#lines 1- 0 at
   #out off  1 #line +!
;

: 1scroll-screen ( -- )
  ['] scroll-bot1 is cr
  24 is #lines
;

: scroll-bot3  ( -- )
   2 0 at delete-line
   (#lines 1- 0 at
   #out off  1 #line +!
;

: menue-screen ( -- )
  ['] scroll-bot3 is cr
  2 is #lines
;

only forth also definitions
