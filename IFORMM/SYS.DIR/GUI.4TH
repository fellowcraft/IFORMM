\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ----------------------
\ g       u    i
\ General User Interface
\ -----------------------

\ gui ( -- )

\ Highest level call to invoke the Graphic User Interface.
\ You exit it and return to Forth by simply pressing a key.

\ .guiactions ( -- nlist ) 

\ see what's currently installed


\ you must supply:

\ 1.  gui-setup
\ word that initializes all your variables, arrays etc.
\ and draws the screen before any action (mouse-movement) takes place.  
\ This can be anything, but should not be an infinite loop.

\ 2. gui-action
\ word that does the action.  In most cases it'll be:  mouse-button is
\ pressed, do this, etc. This can be anything, but should NOT be an
\ infinite loop.


\ define your word for the defered:
\ gui-setup
\ gui-action

\ example:
\ ' my-setup  is gui-setup      \ store your setup  in  slot number 0
\ ' my-action is gui-action       \ store your action in  slot number 0

\ you can then call gui and have fun watching everything work at once.

\ ------------------------------------------------------------------------------


defer gui-setup              \ store the setup
defer gui-action             \ store the action

: clear-gui ['] noop is gui-setup !  ['] noop is gui-action  ;
            

quan Toggle true to Toggle

: gui ( -- )              \      ( General User Interface )
 
erase-screen	    		    \ clear the screen first
mouse-off	                \ turn off default mouse-handler current


gui-setup                 \ INITialize the setups


set-up-mouse              \ now put the mouse on the screen

begin

  left-button  Toggle and  mouse-moved? or
  if              
                    
  restore-screen         	\ put the screen back the way it was

  gui-action              \ DO action
 
  draw-mouse		          \ draw the mouse

  then
   
  left-button right-button or mouse-moved? not and
                if   false to Toggle
                else  true to Toggle
                then
   
key? until	    		\ do this until the any key is pressed

kl	            		\ turn off any music process, if any
erase-screen	    		\ clear the screen again
mouse-on	    		\ restore the mouse-handler
;


