\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

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

create eniac-picture 32000 allot
"" pic.dir\en.wbm ""load-wbm
eniac-picture is *picture

: logo
   rnd-melodie
   begin 8 0 do rnd-box loop
   eniac show
  \ brnd if normal-screen else reverse-screen then
  \ erase-screen
   key? until
  \ reverse-screen
   kill-all

;
