\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ ------------------------------------------------------------------------------
\ PAINT MUSIC

\ Installation at Science World of British Columbia 

\ written: Vancouver 1989
\ revised: San Francisco 1990
\ adapted: New York 1998 (rev Los Angeles)

\ Draw a picture with the mouse, by holding down the LEFT mouse button.

\ Choose between BLACK or WHITE.

\ The programm will scan your picture and play it on MIDI channel 1 or 2.

\ Choose to STOP or PLAY or ERASE the picture.

\ To quit press any key 
\ -----------------------------------------------------------------------------


only forth also system also forth definitions 


alias endif then            \ Makes more sence  -> saw this alias the first


		      \ time in Berlin (see also Object Oriented Forth)	


decimal   \ don't get burnt 
                     

 
: text  
        
             x1 @ 28 +              \ text is in the middle of the previous
             y1 @ 8 +   print1     \ box 
      
      
;

\ ---------------------------------------------------------------------

variable midi.color     1  midi.color  ! 
variable music?      true music? !    
variable info   false info !   


\ C = COLOR         monitor
\ B = Black/white      "

638 100  matrix picture-brain   

picture-brain     @ constant row#    
picture-brain 4 + @ constant column#
row# column# * constant picture-length


: init-row 
\ make sure that the 2nd column is alwaysss different 
   row# 0 do
 16 2 i picture-brain element c! loop  ;    


: init-brain
   picture-brain 8 +
   picture-length erase 
 \  init-row 
;  


variable x  
variable y 

variable last.color 
variable new.color 

variable patch.color       

: linebox      0 x1 ! 18 2* y1 !  318 2* x2 !   50 2*  y2 !   ;

: canvasbox      0 x1 ! 70 2*  y1 !  318 2* x2 !    99 2* y2 ! ;  

: clearbox       230 2* x1 ! 183 2* y1 !  88 2*  x2 ! 15 2* y2 ! ; 

: redbox         130 2* x1 ! 173 2* y1 !  28 2*  x2 ! 25 2* y2 ! ;   
                 
: greenbox       160 2* x1 ! 173 2* y1 !  28 2* x2 ! 25 2* y2 ! ;    

\ --------CONTROL------------------- 
: stopbox       
     0 x1 ! 183 2* y1 !  44 2* x2 ! 15 2*  y2 !      
; 
: playbox    
     47 2* x1 ! 183 2* y1 !  44 2* x2 ! 15 2* y2 !  
;


table goodcolors  4 , 5 , 7 , 8 , 9 ,
                  12 , 13 , 14 , 0 ,


variable current-color  
:  change.color   
     
;

: shut-up  \ the cheap way 

  3 0 do 0 i YM-note-off loop  
   
;     

: redraw  ( x y -- )
  
                   
   swap 1- swap 36  +
   last.color @  0> negate  !pix  \ short form of:  0> if 1 else 0 then  
;

: position-line  ( n -- )
 
     \  vertical line at n downwards 
   dup >r x1 !  40  y1 !  r>  x2 ! 
     134 y2 ! line  
;    

variable lowest-note  24 lowest-note ! 

: delay 100 0 do loop ;  

: all-notes-off  127 24 do 0 i 0 mku delay loop
 		 127 24 do 0 i 1 mku delay loop
; 


: note-off 

    y @ 5 <<  
    last.color @    
    YM-note-off  


    y  @          
 
    row# - negate 
    lowest-note @  + 
     
    last.color @ 1-    

    0 rot rot  mku    
;    

: note-on
         
      2 irnd 14 + 
      y @         
      5 << 
   
      new.color @  YM-note-on       
   

      100 20 irnd + 
 
      y @    
      row# - negate 
      lowest-note @ + 
    
      new.color @  1- 

      mkd
;

\ from ATTACK/DECAY 


\ ----------Box fills----------------------

: on-fill  

     black-fill box(filled)   

; 

: off-fill   

     cross-fill 
     15 pattern-mask ! 
      black-line 
      box(filled) 
      box(unfilled)

;

variable status(control) true status(control) !    

: stop-box-action  ( -- ) 
       
       stopbox check.box 
       status(control) @ and 
          if   
               music? off
            shut-up          
         
          playbox off-fill 
               	  1 char-color !     \ black         
                  [""] PLAY   text 
  	  stopbox on-fill            
                  0 char-color !     \ white 
                  transparent-write  
                  [""] STOP   text 
                  replace-write  
 	
          false  status(control) !  
       endif        
;

: play-box-action   ( -- ) 
       playbox check.box
       status(control) @ false =  and  
         if        
             music? on     
           
          stopbox off-fill
                  1 char-color !         
                  [""] STOP text 
             
          playbox on-fill  
                  transparent-write       
                  0 char-color !  
                  [""] PLAY text 
                  replace-write 
          true  status(control) !
       endif 
;

variable note-length 0 note-length ! 
: save-mouse-pos  ( -- )   
 
   midi.color @
 
   mouse-x  note-length @  + 
   column# 4 - min 3 max   
 
   mouse-y  69 2*  -  
   2/ 
 
   picture-brain element c!   
              
          
;  

: pixelbox  ( lenght x y  -- )
    y1 ! x1 !  x2 ! 4 y2 ! ; 

: paint-mouse-pos ( -- ) 
          midi.color @  1 = if white-fill else black-fill endif             
   note-length @  mouse-x  mouse-y 
          pixelbox box(filled) 
; 

: draw-action
              canvasbox check.box  if                                      

                save-mouse-pos                            
                paint-mouse-pos 

             endif 
; 

: clear-action 
  clearbox check.box if 

               change.color  
                 shut-up
              grey-fill   
     
      0 x1 ! 69 2* y1 ! 320 2* x2 ! 170 2* y2 ! rectangle(filled)     
          canvasbox -1 x2 +!  box(unfilled) 
              init-brain
                   
           endif 
; 

variable stateII       

: red-box-action 
           redbox check.box 
           stateII @ and  if 

             white-line greenbox box(unfilled) 
             black-line redbox   box(unfilled)        

             1 midi.color !            
             stateII off   
          		    endif
;

   
: green-box-action 
           greenbox check.box
           stateII @  false = and  if  

             white-line redbox   box(unfilled)
             black-line greenbox box(unfilled) 

             2 midi.color !  
             stateII on 
               endif  
; 




:  draw 
               draw-action                  
;
: box-control 
               clear-action 
               stop-box-action    
               play-box-action 
               red-box-action               
               green-box-action 
;


\ white line box fuer line 

: new-linebox 
      white-fill  linebox  box(filled)
      grey-fill   linebox  box(unfilled)
                 
;

: canvas 
          
                black-fill 
                black-line         \ black is white (if reverse-screen is set)
         canvasbox box(unfilled)

; 

: init-screen  

          
             cursor-blink-off    
             erase-screen 

                      
       \  [""] Btitle.pi3 "seepic
                 
                canvas

                         0 char-color ! 
                          grey-fill
                clearbox  box(filled) 
                          box(unfilled)                        
 
                    x1 @ 34 + 
                    y1 @ 8  +  transparent-write say." ERASE PICTURE"   
                
                   playbox   box(unfilled)   
                    x1 @ 6 + 2*
                    y1 @ 3 + 2* say." Play" 

               
                  grey-fill greenbox box(filled)
             
                  x1 @ 10 + x1 !    y1 @ 10 + y1 ! 
                  x2 @ 20 - x2 !    y2 @ 20 - y2 ! 
                  black-fill box(filled) 
                 

                  grey-fill redbox   box(filled) 
      	             
                  x1 @ 10 + x1 !    y1 @ 10 + y1 ! 
                  x2 @ 20 - x2 !    y2 @ 20 - y2 ! 
                  replace-write white-fill box(filled) 
               
              

               grey-fill   linebox  box(unfilled)                        
               init-brain
 
             white-line greenbox box(unfilled) 
             black-line redbox   box(unfilled)         

              
          stopbox off-fill 
               	  3 char-color !     \ black         
                  [""] STOP text 
  	  playbox on-fill            
                  0 char-color !     \ white 
                  transparent-write  
                  [""] PLAY  text 
                  replace-write  
      
           1 char-color !	

               grey-fill
      0 x1 ! 69 2* y1 ! 320 2* x2 ! 170 2* y2 ! rectangle(filled)     
          canvasbox -1 x2 +!  box(unfilled) 


 ; 




\ The whole thing is top down so that's the main loop 

variable previous-ypos  0 previous-ypos ! 
variable job?           job? off
variable moved?         moved? off


: paintmusic 
   
      ['] noop is mouse-routine       \ no double program
    \ reverse-screen
    \ text-set 
      init-screen
      set-up-mouse 
      
 
   begin    


    key? if 
                ['] graphic is mouse-routine 
                1 char-color !
                all-notes-off
                erase-screen 
                set-up-mouse  
                exit 
                               
              endif
    
column#  4 do 
                   \ read picture from left end 

  
  mouse-moved? if restore-screen draw-mouse endif

  key? if leave then

  
 left-button  if 
              restore-screen
              mouse-y 170 2* < if
              mouse-y previous-ypos @ <> if
                        1 note-length !  else 
                        1 note-length +! endif 
                               draw 
                               else box-control
                               endif          
               draw-mouse  
               mouse-y previous-ypos !  
               endif 


      music? @ if                   \ check the stop button 
      job? on     
   
    i  position-line 
        
    
\ ------------------- inner loop --------------------------- 
      row#   1    do                         
        
     
       i  y !  
         
        j 1- i  picture-brain element
                    c@  \ same...    
        dup last.color ! 
        j    i  picture-brain element c@  
        dup new.color  !   
        
        =  if  
           else 
        new.color @ 0<> if
                        last.color @ 0<> if note-off endif      
                        note-on 
                   else note-off                        
                         endif
       
           endif
  
         j i redraw     
       loop 
\ --------------------------------------------------------------    
  
      
       
      else  job? @ if new-linebox all-notes-off job? off then 
                   leave 
      endif       
 

    loop                   

 
   again 


; 

