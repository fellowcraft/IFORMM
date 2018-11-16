\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

quan xoffset
quan yoffset

: mirrors
 erase-screen
 0  to xoffset
 0  to yoffset
 200 200                     \ 1 2
 begin
    1 grnd + 511 and dup >r    \ 2 1    511      \ r 1
    swap                                  \ 1 2         \ r 1
    1 grnd + 255 and dup >r     \  1 2         \ r 1 2
  r> r>
 swap 1 !pix            \
 key? if erase-screen abort then
 again
;

