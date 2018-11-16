\ Copyright (c) 1989-2005 by Frank H. Rothkamm.  All rights reserved.

\        cr .( LINE2:  THE CALLS...  )  \  Graphics Interface

\ 	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
\ 	had to write it 'cause vdi calls seem to overwrite the afield values 
\ 	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 

decimal

\ parameter              values 
\ global
variable write-mod       \  0-3
\                                          
variable x1             \  0-639         	   x  coordinates source 
variable y1             \  0-399                   y 
variable x2             \  0-639                   x       "     desination
variable y2             \  0-399                   y
variable plane1-color   \  0-15 		   all resolutions (1=black)
variable plane2-color   \  0-15 		   only medium resolution
variable plane3-color   \  0-15        		   only meduim/low
variable plane4-color   \  0-15	         	   only low resolution 

\ line 

variable line-mask       \ 0-65535   mask for lines (16-bit) 

\ rectangle(filled) 
variable pattern-pointer \ addr    of word array of 16 16bit numbers   
variable pattern-mask    \ 0-?     number      of patterns (16bit maske)   
variable x1-clip         \ =x1               
variable y1-clip         \ =y1
variable x2-clip         \ =x2
variable y2-clip         \ =y2 
variable ?clipping        \ 0 or 1  on/off
variable multifill       \ 0 on plane1     1 on all planes   

\ mouseform 
variable x-action           \   
variable y-action           \ 
variable mask-color         \
variable mouse-color        \ 
variable mouse-form-pointer \ 
variable mouse-mask-pointer \ 

\ **text 

variable font-pointer 
variable font-width
variable char-color 
variable char-x 
variable char-y 
variable char-width 
variable char-height
variable source-x
variable source-y 
variable char-style 
variable light-mask 
variable italic-mask
variable thickning
variable italic-right
variable italic-left
variable ?scale    
variable scale-factor 
variable scale-direction 
variable chup 
variable ?mono-status 

create scratchptr    100 allot 
variable scratchptr2  \ 100 allot  

: !pix  ( x y value --  ) \ high level pixel setting routine
   intin @  w!
   ptsin @  swap  over 2+ w!  w!
   put-pix
;
: @pix  ( x y -- value )  \ high level pixel fetching
   ptsin @  swap over 2+  w!  w!  get-pix
;

: line  ( -- )  \  X1 Y1 X2 Y2  \   high level line routine
      x1 @ _x1 	w!  
      y1 @ _y1 	w! 
      x2 @ _x2 	w!
      y2 @ _y2 	w!
      plane1-color @ _fg_bp_1 	w!
      plane2-color @ _fg_bp_2 	w!
      plane3-color @ _fg_bp_3 	w!
      plane4-color @ _fg_bp_4 	w!
         line-mask @ _ln_mask 	w! 
      write-mod    @ _wrt_mod 	w!       
     		  -1 _lstlin  	w!   
    do-line
;


: polygon(unfilled)  ( address  #_of_points  -- )

  1-  4* over +  swap
   do   i     w@ x1 ! 
        i 2+  w@ y1 !
        i 4 + w@ x2 !
        i 6 + w@ y2 !   line   
   4 +loop

;

variable crntpts 20 allot

: getpts   \ (form Mach2 intro3.fth)   
           \ load a word array with coordinates

   x1 @ 1+            crntpts w!        \ 1       
   y1 @               crntpts 2 + w!
   x1 @ 1+ x2 @ +     crntpts 4 + w!    \ 2  
   y1 @               crntpts 6 + w!
   x1 @ 1+ x2 @ +     crntpts 8 + w!    \ 3
   y1 @ y2 @ +        crntpts 10 + w!  
   x1 @ 1+            crntpts 12 + w!   \ 4   
   y1 @ y2 @ +        crntpts 14 + w!    
   x1 @ 1+            crntpts 16 + w!   \ 5 = 1  
   y1 @ 1+            crntpts 18 + w! 


; 

: box(unfilled)    ( -- )                        
					\ every call leaves the x y values
					\ unchanged
        				\ i.e. <mybox>  box(filled)
					\	        box(unfilled) 
					\ will paint a filled and a unfilled 
					\ box with the same coordinates. 	

   x1 @ >r       y1 @ >r   		\ Keep coordinates !  
   x2 @ >r       y2 @ >r     

   getpts  crntpts 5 polygon(unfilled)  \ transform them and paint the box 

        r> y2 !       r> x2 !		\ Put the kept one's back !   
        r> y1 !       r> x1 !       

;                             

: rectangle(filled)  ( --  )  \ draw a filled rectangle
          y2 @  _y2 w! 
          x2 @  _x2 w!  
          y1 @  _y1 w! 
          x1 @  _x1 w!
     plane1-color @ _fg_bp_1 	w!
     plane2-color @ _fg_bp_2 	w!
     plane3-color @ _fg_bp_3 	w!
     plane4-color @ _fg_bp_4 	w!      
         write-mod @ _wrt_mod   w!
         x1-clip @  _xmn_clip w!      
         y1-clip @  _ymn_clip w! 
         x2-clip @  _xmx_clip w!
         y2-clip @  _ymx_clip w! 
            ?clipping @ _clip w!      
     pattern-pointer @ _patptr !
     pattern-mask @   _patmsk w!     
         multifill @ _multifill w!              
   fill-rec
;

: box(filled) 
   
   x1 @ >r       y1 @ >r   		\ Keep coordinates !  
   x2 @ >r       y2 @ >r     
 
     getpts  crntpts         w@ x1 !    \ transform coordinates and... 
             crntpts   2+    w@ y1 ! 
             crntpts   8 +   w@ x2 ! 
             crntpts   10 +  w@ y2 !                           
     
             rectangle(filled)          \ ...paint  

        r> y2 !       r> x2 !		\ Put the kept one's back !   
        r> y1 !       r> x1 !       

;

code polygon(filled)  ( y1 y2 addr n --  )  \ fast polygon inner loop
   sp )+          d0          lmove
   a-vars l#)     a1          lmove   
   ' contrl >body @  a1 d)    a2          lmove 
   d0             2 a2 d)     wmove
   ' ptsin >body @  a1 d)     d7          lmove
   sp )+    ' ptsin >body @  a1 d)    lmove 
   sp )+          d6          lmove
   sp )+          d5          lmove
   a3             sp -)       lmove   \ Save a3
   a1             a3          lmove   \ a1 gets clobbered so we use a3
   d5             d6          sub
   begin
	d5 ' _y1 >body @  a3 d) wmove
	hex a006 w, decimal
	1 d5 addq
   d6 dbra
   d7  ' ptsin >body @  a3 d) lmove
   sp )+          a3          lmove
c;

          
: check.box    
        \ given coordinates, will flag if mouse within them
   mouse-x x1 @  > 
   mouse-x x1 @ x2 @  + < and
   mouse-y y1 @  >
   mouse-y y1 @ y2 @ + < and
   and 
;


\ **text 

: (print 
    write-mod 		@ _wrt_mod 	w!   
    ?clipping   	@ _clip      	w! 
         x1-clip 	@ _xmn_clip 	w!      
         y1-clip 	@ _ymn_clip 	w! 
         x2-clip 	@ _xmx_clip 	w!
         y2-clip 	@ _ymx_clip 	w! 
     char-color 	@ _text_fg 	w! 
    font-pointer 	@ _fbase 	 !
    \ _def_font      @ _fbase     !
     font-width 	@ _fwidth 	w! 
  
    source-x 		@ _sourcex 	w!  
    source-y 		@ _sourcey 	w! 
    char-width 		@ _delx 	w!
    char-height 	@ _dely 	w! 
    char-style 		@ _style 	w! 
    light-mask 		@ _litemask 	w! 
    italic-mask 	@ _skewmask 	w!  
    thickning 		@ _weight    	w! 
    italic-right 	@ _r_off 	w! 
    italic-left 	@ _l_off 	w! 
 
     ?scale 		@ _scale 	w!  
     scale-factor 	@ _dda_inc 	w!
     scale-direction	@ _t_sclsts 	w!

    chup   		@ _chup 	w! 
    ?mono-status 	@ _mono_status 	w!  
                 th 8000 _xacc_dda 	w! 
     scratchptr   	  _scrtchp 	 ! 
     scratchptr2        @ _scrpt2       w!      
     textblt 
;


\ --------------------------------------------------------- / 
\ In Forth:      ."      ->   : greet           ." hallo "  ;          
\ With God:   say."      ->   : greet 100 100 say" hallo "  ;  
                         
\ In Forth:      .      ->    : calc   3 4 +             .  ;         
\ With God:   say.      ->    : calc   3 4 +  100 100 say.  ;

\ In Forth:      .(     ->     .( Smoke dope and watch TV )
\ With God:   say.(     ->  say.( Don't worry , be happy  )  
\ ---------------------------------------------------------- /

			  
:  type2 
   bounds ?do
           i c@  char-width @ *  source-x ! (print \ pause     
   loop 
;

: emit2  char-width @ * source-x ! (print ; 

: print1   ( x y addr -- ) \  i.e.    "" teststring 20 20 print1     
               		   \ 	:    [""] testword  20 20 print1 
     _desty w! 
     _destx w!            
      count  type2  
            
;

: say(.")   ( x y -- ) 
  _desty w! _destx w! skipstr type2 
; 

:  say."    ( x y -- ) 
     compile say(.") ," 
;
immediate

: say.(      ascii )  word count type2  ;    

: say.  ( x y )
       _desty w! _destx w!        \ get coordinates 
      (.)  type2 bl emit2  ;      \ dirty dirty   say number  


\ decimal
\ create mfdb
\   screen-base ,
\   I'm not sure the next line is right
\   getrez dup  4*  rez-table + dup w@ swap @ ,
\   16 / w,
\   0 w,
\   2* 1 max 4 swap - 1 max  w,
\   0 w,
\   0 ,

create (mfdb 24 allot
: mfdb
   (mfdb
   screen-base 
   (mfdb       !
   getrez dup  4*  rez-table + dup w@ swap @  
   (mfdb  4 +  ! 
   16 / 
   (mfdb  8 +  w! 
  \ 0 
  \ (mfdb  12 + w!
   2* 1 max 4 swap - 1 max  
   (mfdb 12 +  w!
   0 
   (mfdb 16 +  w!
   0 
   (mfdb 20 +  w!
;


\ rasmove (raster copy) is a fast low level bit map move routine

: rasmove  ( sx1 sy1 sx1 sx2 dx1 dy1 dx2 dy2 m -- )
  mfdb dup  contrl @  14 + 2!
   intin @  w!
   ptsin @  dup 14 +
    do  i w!  -2 +loop
   copy-raster
;


\ ---------------------COLOR------------------------------- 
\ asume that there is the default setting of Color palettes 
\ !! white backgound !! 
\ medium-resolution got 4 colors (what a selection!)

: color  ( # -- )      
         dup 15 and  3 >>   plane4-color !
         dup 7  and  2 >>   plane3-color ! 
         dup 3  and  1 >>   plane2-color !
             1 and      
    plane1-color ! 
;

0 constant black        \ or white
2 constant green  
1 constant red    
3 constant white        \ or black


\ tuning of RGB values:  0-7 

\ background 

: R_back    8 <<  0 setcolor ;
: G_back    4 <<  0 setcolor ;
: B_back          0 setcolor ; 



