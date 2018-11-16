\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ logo animation

:  rnd-box
   540 irnd x1 ! 300 irnd y1 !
   100 irnd x2 ! 100 irnd y2 !
   box(unfilled)
;

:ap rnd-melodie
  ::ap
    120 beats-per-minute
    begin /32
       \   24 irnd 30 + dup
       \  12 irnd 1 max  0 do 3 + dup $ loop
    64 irnd 36 + $
    again
  ;;ap
;ap



: load-eniac [""] pic.dir\en.wbm ""load-wbm ;

create eniac-picture 32000 allot
eniac-picture to *picture
load-eniac
picture to *picture

: (logo
   rnd-melodie
   begin
     8 0 do rnd-box loop
   \ 550 brnd + 68 say." IFORM88.ORG "
   erase-screen
   key? until
   eniac-picture show
  \  reverse-screen
   kill-all

;

' (logo is logo
