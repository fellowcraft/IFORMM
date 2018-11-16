\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

decimal

126 array boxactions

quan gsize  1 to gsize     \ general size of quadrats  
quan MidiMax 127 to MidiMax

: overtone-box
   
    1 y1 !    
	1 x1 !
    MidiMax 1+  y2 ! 
    126     1+  x2 !
     
   
;

quan prev-overtone-box

: init-overtone-boxes
  black-line overtone-box box(unfilled)
     

;

pquan tempX
pquan tempY

:ap test-note
 ::gp       mouse-x to tempX
            mouse-y to tempY
            40 tempX k5      \ select harmonic          
			/32 0 $
			41 tempY k5x      \ set level
			 ;;gp 
;ap


: Action
 
 
     
		 
	 left-button false =   overtone-box check.box   and if 
               
			  black-line
			  mouse-x x1 ! mouse-y y1 !
			  mouse-x x2 ! 127 y2 !
			  line
			  
			  white-line
			  mouse-x x1 ! 1 y1 ! 
			  mouse-x x2 ! mouse-y y2 !
			  line
			  
			  test-note
	         
			  then    
 
 
;


: mcon
clear-gui
['] init-overtone-boxes 0 gui-setups  !
2 0 do ['] Action i gui-actions ! loop
gui
;



