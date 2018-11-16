\ SLIDER
\ may 7th,90 ; april 18, 95 ; april 97 ; march 98 ; september 99 ;
\ september 2000 ; december 2003 (restore)
\ (c) Frank H. Rothkamm
\ slider for mixboard 
\ --> first random process 


\ use the sliders to control variables in processes.

\ SliderInit ( value #Slider -- ) 
\ example: 100 1 SliderInit

\ Slider ( #Slider -- n )
\ example:     1 Slider 

\ slideractions ( -- does an action ) 
\  define action:
\ :  send-out-mod-wheel   
\    0 Slider 1 0 mcc 
\ ; 
\ install action:
\ ' send-out-mod-wheel 0 slideractions !  
\ use action:
\ type:    slider       and move leftmost slider 

\ see action:
\ .slideractions ( -- nlist )
\ prints out a list

\ --------------------------------------------------------------------------

only forth also internals also forth definitions 


variable allsliders        17 allsliders ! 
variable slider-length    128 slider-length !
variable slider-offset     20 slider-offset !
    
create old-y-pos      allsliders @ /w* allot
create current-y-pos  allsliders @ /w* allot
create xpositions     allsliders @ /w* allot
create ypositions     allsliders @ /w* allot
create slider-values  allsliders @ /w* allot


: display-numbers  ( box# -- prints value )
 
 /w* >r         r@ slider-values + w@   
                r@    xpositions + w@   
                r>    ypositions + w@ slider-length @ + 4 +
							     say.                                                  
; 


: display-slide-box  ( box# -- )  
 /w* >r   r@ xpositions + w@  x1 !        
          r> ypositions + w@  y1 !
                          10  x2 ! 
           slider-length @ 1+ y2 ! 
; 

: check-slide-box    ( box# -- )   
 /w* >r   r@  xpositions + w@  x1 !   
          r>  ypositions + w@  y1 !
                           10  x2 !
              slider-length @  y2 !
; 


: pos-box   ( box# y-position -- )  y1 ! 
            /w* xpositions + w@ 1+ x1 ! 8 x2 ! 1 y2 ! ;       


: .box         ( box# -- prints box# ) 
  dup /w* >r           r@ xpositions    + w@ 
                       r> ypositions    + w@ 15 -       
                       say. 
                                
; 

: Slider ( box# -- data ) 
    /w* slider-values + w@ 
; 

: SliderInit ( value box# -- data ) 
    /w* slider-values + w! 
; 



: convert-screen-to-value ( y-pos -- value )
 slider-offset @ - 
 slider-length @ - negate

;
 
: convert-value-to-screen ( val -- y-pos )
 slider-length @ - negate
 slider-offset @ +
;


: text-display

0 184 say." 0=f 1=U 2/3=X/Y 4/5=X/Y 6=v 7=U 8=l 9=U 10=p 11=U" 

;


: default-slider-setup 

                 1 char-color !

                 black-line  
                 allsliders @ 0 do 
  

  \ better notation would be:  slider-offset  i  ypositions!
  				 
  slider-offset @        i /w*  ypositions  + w!
 640 allsliders @ / i *  i /w*  xpositions  + w!				                
	
				                 white-fill  
                                 i display-slide-box box(filled)
                                 box(unfilled)    
            
              i /w* slider-values + w@ 
              convert-value-to-screen         
              i /w* current-y-pos + w!  
              
              i /w* current-y-pos + w@  
              i /w* old-y-pos + w! 

           black-fill i i /w* current-y-pos + w@ pos-box box(filled)    
           
                   i display-numbers 
                   i .box
                  loop     
 
                  text-display
             
;


\ ------ main gui word  ----

: default-slider-action
       allsliders @ 0 do   
      
       i check-slide-box check.box left-button and   
      
          if 
          
             mouse-y dup i /w* current-y-pos + w!  
             convert-screen-to-value i /w* slider-values + w!       
           
                
     
                white-fill i i /w*     old-y-pos + w@ pos-box box(filled)
                black-fill i i /w* current-y-pos + w@ pos-box box(filled) 
                i display-numbers 
                                    
                 i /w* current-y-pos + w@ 
                 i /w* old-y-pos     + w! 
         
          then
                
        loop 
;


\ -------------------------------


: pure-random-setup
  
 
  40 0 SliderInit
  24 1 SliderInit
  1  2 SliderInit
  16 3 SliderInit
  1  4 SliderInit
  16 5 SliderInit
  64 6 SliderInit
  1  7 SliderInit
 60  8 SliderInit
  2  9 SliderInit
  1   10 SliderInit     

  2   11 SliderInit 
  2   12 SliderInit
  63  13 SliderInit
  64  14 SliderInit
 
  1 15 SliderInit

;




: +or- brnd if + else - then ;

:ap pure-random         \ the first random stream 

 ::ap

 120 beats-per-minute

begin  

   brnd   if   2 Slider 3 Slider tel
          else 4 Slider 5 Slider tel 
          then 
      10 Slider irnd 1 max 0 do
      1 Slider irnd                \ around center freq
      0 Slider +   


       7 Slider irnd                \ around center vel  
       6 Slider +   
       2* 127 -                     \ adjust for -127 - 127 range   
      
       8 Slider         	    	    \ expontial growth:  6-760
       9 Slider irnd *                                  
       1 max                 	    \ length of note    

             
       MIDI-do-note
  loop 

      0 $
    
again

;;ap
;ap


quan atRND

: dev&mean  ( -- random value between 0-31 )

\ 2 sliders move random distribution "deviation" around a center "mean"
\ Slider 13 determines the probable limit of a value around Slider 14     
   
\ a maximum centered distribution is Slider 13 at half (63) 
\                                    Slider 14 at half (63) 

       13 Slider 4 /    \ value range 0-31 <-- slider range 0-127 
       irnd 2* 30 -     \ distrubution around center -31..0..+31
       14 Slider 4 /    \ value range 0-31 <-- slider range 0-127       
       +                \ move center between 0-31  
       0 max 31 min     \ keep in range
;


:ap pure-sound
::ap  
 
  120 beats-per-minute
  begin  

   brnd   if   11 Slider 1 max 32 tel
          else 12 Slider 1 max 32 tel 
  	  then 
      
\ distributed randomized attacks on all operators
\ _____________________________
   4 0 do  i dev&mean 
       \ dup i 20 * say. 
       0 at-rsd
       loop

       0 $
    
again

;;ap
;ap


: iboard
       \  pure-random-setup  --> MUST be called first
       pure-sound 
       pure-random
 
    clear-gui                     \ all slots are clear
['] default-slider-setup  0 gui-setups  ! 
['] default-slider-action 0 gui-actions !  
    gui
;

