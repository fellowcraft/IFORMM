\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

64 array boxactions

quan gsize  20 to gsize     \ general size of quadrats

: draw-boxes
   black-line
   erase-screen
    0 y1 !
    399 y2 !
    gsize 2- x2 !

  639 0 do i x1 !
        box(unfilled)
  gsize +loop

;

: Action
  left-button if
              grey-fill  mouse-x x1 ! mouse-y y1 ! 9 y2 ! 9 x2 !
              box(filled)
              then

 right-button if
              black-fill mouse-x x1 ! mouse-y y1 ! 9 y2 ! 9 x2 !
              box(filled)
              then

;

: Clear
   erase-screen
   draw-boxes

;

: init-boxes      64 0 do ['] Action i boxactions ! loop
                     ['] screen-noise 31 boxactions !
;


: paint

  mouse-off
  init-boxes
  Clear
  set-up-mouse
begin
  key?  if
         1 char-color !
         erase-screen
         mouse-on  exit
        then
  mouse-moved? if
           restore-screen
           mouse-x gsize / boxactions @ execute
           draw-mouse
                              then
again

;
