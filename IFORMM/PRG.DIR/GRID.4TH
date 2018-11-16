\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ start the interactice matrix:
\ grid

\ steer it on the numerical keypad:

\       8     -  
\     4 5 6   +

\ 8 =  up     
\ 2 =  down
\ 4 =  left 
\ 6 =  right
\ + =  increase value
\ - =  decrease value

\ reading the matrix:
\ V@ ( y x -- n )  
              
\ example: 0 0 V@



only forth also ap-defs also internals also forth definitions

quan xat
quan yat 
quan prev-xat
quan prev-yat

create Vpos 22 22 * allot 
       Vpos 22 22 * 0 fill 

create Xpos             0 w,  32 w,  64 w,  96 w, 128 w, 
                      160 w, 192 w, 224 w, 256 w, 288 w, 
                      320 w, 352 w, 384 w, 416 w, 448 w,
                      480 w, 512 w, 544 w, 576 w, 608 w,
                      640 w, 728 w, 
                                  

create Ypos            0 w,  20 w,  40 w,  60 w,  80 w, 
                      100 w, 120 w, 140 w, 160 w, 180 w, 
                      200 w, 220 w, 240 w, 260 w, 280 w,
                      300 w, 320 w, 340 w, 360 w, 380 w,
                      400 w, 420 w,    
                   


: get-matrix-value  ( -- n )

  Vpos 
   xat 2/ 
   yat 2/ 22 * + 
   /c*
   + 
   c@ 

;

: V@  ( y x  -- n )
  >r >r 
  Vpos r> 22 * + 
       r>    
   /c*
   + 
   c@ 

;

: +Key 

  Vpos 
   xat 2/ 
   yat 2/ 22 * + 
   /c*
   + 
   dup  c@ 1+  255 min 
   swap c!
    
;

: -Key 

  Vpos 
   xat 2/ 
   yat 2/ 22 * + 
   /c*
   + 
   dup  c@ 1-  0 max
   swap c!
    
;   


: key-action 
 
  19 y2 ! 26 x2 !

  get-matrix-value  
  Xpos xat + w@ 2+ 
  Ypos yat + w@ 2+ say. 

  white-line 
  Xpos prev-xat + w@  x1 ! 
  Ypos prev-yat + w@  y1 !
  box(unfilled)  

  black-line
  Xpos xat + w@ x1 !
  Ypos yat + w@ y1 !
  box(unfilled)
 
  xat to prev-xat  

  yat to prev-yat    
  
;

: init-das

 40 0 do i to xat 
  get-matrix-value  
  Xpos xat + w@ 2+ 
  Ypos yat + w@ 2+ say.
 
  20 0 do i to yat 
  get-matrix-value  
  Xpos xat + w@ 2+ 
  Ypos yat + w@ 2+ say.
  2 +loop
 
2 +loop
       0 to xat 0 to yat
       key-action
;


: grid
   erase-screen
   0 to xat 0 to yat
   init-das

  begin
     cursor-off
     key
          case 
           54 of xat 2 +  38 min  to  xat   key-action endof  
           52 of xat 2 -   0 max  to  xat   key-action endof
           50 of yat 2 +  18 min  to  yat   key-action endof
           56 of yat 2 -   0 max  to  yat   key-action endof
           43 of +Key  key-action endof  
           45 of -Key  key-action endof
          113 of  13 0 at exit  endof    
          endcase              
    again   

;

\ split-screen
\ ' edtest is mouse-routine
