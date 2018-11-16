\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

: lines
 erase-screen

 200 200                       \ 1 2
 begin

mouse-x 1 max 0 do
  swap x1 ! y1 !
   x1 @ 2 grnd + 511 and xoffset + dup x2 !   \ 2 1    511      \ r 1
   y1 @ 2 grnd + 255 and yoffset + dup y2 !   \ 1 2         \ r 1 2
    line
  key? if erase-screen abort then
  loop            \
again

;
