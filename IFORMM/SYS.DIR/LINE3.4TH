\ Copyright (c) 1989-2005 by Frank H. Rothkamm.  All rights reserved.

\	cr .( LINE3: The Creation... )         
\ LINE A THE CREATION              line3 HIGH LEVEL USER WORDS


\    A.  Appendix: LINE ( init )

		\ --------- /
		\ WRITE MOD /
		\ --------- /

      
: replace-write     0  write-mod ! ;
: transparent-write 1  write-mod ! ;
: invert-write      2  write-mod ! ;
: invtrans-write    3  write-mod ! ;

: scaled-font
  ?scale on
  80000000 scale-factor !
;
: normal-font
  ?scale off
;

        	\ ------------------------------------- /
		\  line + box(unfilled) + box(filled)
		\ ------------------------------------- / 
                   
                                 \ A /

		  \ pattern for line and box(unfilled) /
		  \ ---------------------------------  /
 

create linepattern   tb 1111111111111111 w,       
                     tb 1100110011001100 w,     ( +  2 ) 
                     tb 1111111111110000 w,     ( +  4 ) 
                     tb 1111111100000000 w,     ( +  6 )  
                     tb 1110000011100000 w,     ( +  8 ) 
                     tb 1010101010101010 w,     ( + 10 )
                     tb 0000000000000000 w,     ( + 12 )
                     tb 1111110000111111 w,     ( + 14 )


: white-line            linepattern 12 + w@ line-mask !   ;
: black-line            linepattern      w@ line-mask !   ;  
: dot-line              linepattern  2 + w@ line-mask !   ; 
: grey-line             linepattern 10 + w@ line-mask !   ; 
: dash-line             linepattern 14 + w@ line-mask !   ; 


          	              \ B /

	  \ pattern  for box(filled) and rectangle(filled) /
          \ ---------------------------------------------- / 

create crosspattern  tb 1000000000000001 w,     ( offset: ) 
                     tb 0100000000000010 w,     ( + 2 ) 
                     tb 0010000000000100 w,     ( + 4 )  
                     tb 0001000000001000 w,     ( + 6 ) 
                     tb 0000100000010000 w,     ( + 8 )
                     tb 0000010000100000 w,     ( + 10 ) 
                     tb 0000001001000000 w,     ( + 12 ) 
                     tb 0000000110000000 w,     ( + 14 )  
                     tb 0000000110000000 w,     ( + 16 ) 
                     tb 0000001001000000 w,     ( + 18 )                   
	             tb 0000010000100000 w,     ( + 20 ) 
 		     tb 0000100000010000 w,     ( + 22 )
		     tb 0001000000001000 w,     ( + 24 )
 		     tb 0010000000000100 w,     ( + 26 )
		     tb 0100000000000010 w,     ( + 28 ) 
                     tb 1000000000000001 w,     ( + 30 ) 


\ Absolute fills:
\ ( pattern-mask determine the how many lines will be read )

: white-fill    0 pattern-mask !
	          	linepattern 12 + pattern-pointer !  ;      
: black-fill    0 pattern-mask ! 
                   	linepattern      pattern-pointer !  ;
: dot-fill      0 pattern-mask ! 
        	      	linepattern  2+  pattern-pointer !  ;           
: grey-fill     0 pattern-mask !                          
                	linepattern 10 + pattern-pointer !  ;    
: dash-fill     0 pattern-mask !  
                        linepattern 14 + pattern-pointer !  ; 

 
: cross-fill           15 pattern-mask ! 
                         crosspattern      pattern-pointer !  ;
\ .... 

                        \ ------- / 
			\ pattern /
			\ ------- /                                     


create masonpattern 
                  tb 0000000000000000 w,  \  1   user-mask  16 x 16 points
                  tb 0000000100000000 w,   
                  tb 0000001010000000 w,   
                  tb 0000010001000000 w,   
 		  tb 0000100000100000 w,  \  5 
 	          tb 0101000110010100 w,   
 		  tb 0010001000001000 w,   
		  tb 0101000110010100 w,    
 		  tb 0000100100100000 w,    
		  tb 0000010001000000 w,  \ 10 
		  tb 0000001010000000 w,   
		  tb 0000000100000000 w,     
 		  tb 0000000000000000 w,   
		  tb 0000000000000000 w,   
 		  tb 0000000000000000 w,  \ 15 
		  tb 0000000000000000 w,

create conductpattern
                  tb 1000000000000000 w,  \  1  create usermouse 16 x 16 points
                  tb 0100000000000000 w,   
                  tb 0010000000000000 w,   
                  tb 0001000000000000 w,   
 		  tb 0000101111100000 w,  \  5 
 	          tb 0000110000010000 w,   
 		  tb 0000101100001000 w,   
		  tb 0001010101001000 w,    
 		  tb 0000101010100100 w,    
		  tb 0001010001000010 w,  \ 10 
		  tb 0001001000100010 w,   
		  tb 0000010000000001 w,     
 		  tb 0000001000000011 w,   
		  tb 0000000100000011 w,   
 		  tb 0000000011000110 w,  \ 15 
		  tb 0000000001111100 w,

create holycrosspattern 
                  tb 0000011111100000 w,  \  1  create usermouse 16 x 16 points
                  tb 0000001111000000 w,   
                  tb 0000001111000000 w,   
                  tb 0010001111000100 w,   
 		  tb 0011111111111100 w,  \  5 
 	          tb 0011111011111100 w,   
 		  tb 0011111111111100 w,   
		  tb 0010001111000100 w,    
 		  tb 0000001111000000 w,    
		  tb 0000001111000000 w,  \ 10 
		  tb 0000001111000000 w,   
		  tb 0000001111000000 w,     
 		  tb 0000001111000000 w,   
		  tb 0000001111000000 w,   
 		  tb 0000001111000000 w,  \ 15 
		  tb 0000001111000000 w,

 
: mason-fill            15 pattern-mask ! 
                          masonpattern      pattern-pointer !  ;
\ .... 

\ Clipping  

: clipping-on       1  ?clipping ! ;  
: clipping-off      0  ?clipping ! ;                   

 
\ *********************   Appendix:  *************************************

\                            A 


\ -------- INITIALISATION ------------------------------
\ ------------------------------------------------------


: LINE      ( -- ) \ high level line a initialization routine
    getrez -1 -1 setscreen  \ resolution
    init-a                   \  
    0  write-mod !           \ replace-mod          write on top  
      
    getrez 2 = if 
                  white color 
                  white char-color !   
               else                           
                  green color  
                  red char-color !             \ text 
               then
           
   
    black-line               \ solid and black are the lines   
    black-fill   
    15 pattern-mask !        \ preset  mask  
   
       
 \     font-picture font-pointer !  \ that's our font 
  
      _def_font    @ font-pointer !
         _fwidth  w@ font-width   !

\ ----------------------------------------------------------- 

    _dda_inc  @ scale-factor !
    _scale    @ ?scale       ! 
    _t_sclsts ( Jesus Christus, sprich dieses Wort ) @ scale-direction !  
  
\ make sure we see the little char actors

\     _delx @ char-width  !
\     _dely @ char-height !   
 
    8  char-width !         
    14 char-height ! 

    _litemask w@ light-mask !   
    _skewmask w@ italic-mask ! 
    _r_off    w@ italic-right ! 
    _l_off    w@ italic-left !

\ ------------------------
 
      0 x1-clip !                 \ clipping is as big as the screen... 
      0 y1-clip ! 
    640 x2-clip !
    400 y2-clip ! 
      0 ?clipping !              \ ... and no clipping       
      0 multifill !              \  fillpattern:  0=monochrom  1=color   
    
;

\ LINE            \ DO NOT USE IN COLON DEFINITION ! 

