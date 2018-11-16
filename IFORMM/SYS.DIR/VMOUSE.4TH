\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ -----------************* G R A P H I C S *************----------------------

only forth also internals also forth definitions 


decimal


quan *mouse-routine

quan prev-mouse-x 640 to prev-mouse-x    
quan prev-mouse-y 400 to prev-mouse-y  

quan prev-!pix     

quan now-mouse-x
quan now-mouse-y

variable mouse-checksum  0 mouse-checksum !

: mouse-moved?  ( -- flag ; true if status changed ) 
  mouse-x mouse-y + dup >r  
  mouse-checksum @  
  <>
  r> mouse-checksum !
; 

create mouse-picture 32000 allot 

mouse-picture to *picture
\ "" pic.dir\mo.pi3 ""load-pic
  "" pic.dir\mouse.wbm ""load-wbm
picture to *picture


create (picture-area 24 allot

: picture-area
   (picture-area
   mouse-picture   
   (picture-area       ! 
   getrez dup  4*  rez-table + dup w@ swap @  
   (picture-area  4 +  ! 
   16 / 
   (picture-area  8 +  w! 
   2* 1 max 4 swap - 1 max  
   (picture-area 12 +  w!
   0 
   (picture-area 16 +  w!
   0 
   (picture-area 20 +  w!
;

\ create picture-area
\   mouse-picture ,
\   getrez dup  4*  rez-table + dup w@ swap @ ,
\   16 / w,
\   0 w,
\   2* 1 max 4 swap - 1 max  w,
\   0 w,
\   1 ,


create mouse-offscreen 32000 allot


create (mouse-area 24 allot


: mouse-area
   (mouse-area
   mouse-offscreen  
   (mouse-area  !
   getrez dup  4*  rez-table + dup w@ swap @  
   (mouse-area  4 +  ! 
   16 / 
   (mouse-area  8 +  w! 
   2* 1 max 4 swap - 1 max  
   (mouse-area 12 +  w!
   0 
   (mouse-area 16 +  w!
   0 
   (mouse-area 20 +  w!
;

\ create mouse-area
\   mouse-offscreen ,
\   getrez dup  4*  rez-table + dup w@ swap @ ,
\   16 / w,
\   0 w,
\   2* 1 max 4 swap - 1 max  w,
\   0 w,
\   0 ,

: screen->area  (  sx1 sy1 sx1 sx2 dx1 dy1 dx2 dy2 m --  )
   
   mouse-area  mfdb
   contrl @  14 + 2!
   intin @  w!
   ptsin @  
   dup 14 +
       do  i w!  
       -2 +loop
      copy-raster
;

: area->screen  (  sx1 sy1 sx1 sx2 dx1 dy1 dx2 dy2 m -- )

   mfdb mouse-area 
   contrl @  14 + 2!
   intin @  w!

   ptsin @  
   dup 14 +
       do  i w!  
       -2 +loop
      copy-raster
;

: mouse->screen  ( sx1 sy1 sx1 sx2 dx1 dy1 dx2 dy2 m -- )
   
   mfdb picture-area

   contrl @  14 + 2!
   intin @  w!

   ptsin @  
   dup 14 +
       do  i w!  
       -2 +loop
      copy-raster
;

\ ------------------------------------------------------------------
: restore-screen
    0 0 16 16  
    prev-mouse-x 
    prev-mouse-y   
    prev-mouse-x 16 +  
    prev-mouse-y 16 + 
    1 area->screen
;
\ -------------------------------------------------------------------


: remember-mouse-position
  
    mouse-x  639 min 0 max dup to mouse-x dup to now-mouse-x to prev-mouse-x     
    mouse-y  399 min 0 max dup to mouse-y dup to now-mouse-y to prev-mouse-y 
;

: remember-screen  
    now-mouse-x
    now-mouse-y   
    now-mouse-x 16 +  
    now-mouse-y 16 +   
    0 0 16 16
    1 screen->area  
; 

\ quan Toggle false to Toggle

: restore-mouse
    0  
  \ Toggle if 16 + then Toggle 1 xor to Toggle  \ toggle between two pics    
    0 16 16 
    now-mouse-x  
    now-mouse-y
    now-mouse-x 16 +
    now-mouse-y 16 +
    3 
    mouse->screen 
; 

\ --------------------------------------------------------------
: draw-mouse
  
      remember-mouse-position
      remember-screen
      restore-mouse     
;
\ --------------------------------------------------------------

: mouse-xy-draw

  mouse-y 0 max 400 min 605 17 say.
  mouse-x 0 max 640 min 605 3 say.

;

:ap mouse-xy-play
 ::ap 
  mouse-y 0 max 128 min  dup 128 = if drop 0 then 64 - to $volume  
  mouse-x 0 max 128 min  dup 128 = if drop 0 then $
  ;;ap
;ap

: yesbox 
   600  x1 ! 1 y1 !   
   38  x2 ! 32  y2 ! 
;

: draw-yesbox
  yesbox box(unfilled)
;

: flicker-box   
    line-mask @ dup 10 irnd 2* + line-mask !
                     draw-yesbox 
                     line-mask ! 
;


\ mouse handler will slow down & can crash Formula. 
\ So we make it a process.   
 
:ap (graphic   \ process will wake up when mouse is moved, 
               \ and will go to sleep when mouse not moved.
  
   restore-screen
   draw-mouse
   flicker-box
   mouse-xy-draw
   left-button if mouse-xy-play then

 
;ap    

:ap  graphic
   ::ap  
       immortal   
       (graphic
       active-exit
   ;;ap
;ap  

 
\ This will set up the mouse, starts clean on the screen 

: set-up-mouse
   mouse-x to prev-mouse-x
   mouse-y to prev-mouse-y
   draw-mouse
; 


:  mouse-off
    ['] noop is mouse-routine 
;

: mouse-on	( install Graphics handler )

\  whole-screen
\  +mouse         already installed in 4.0 
   mouse-picture picture-area !
   ['] graphic is mouse-routine
   set-up-mouse

;
