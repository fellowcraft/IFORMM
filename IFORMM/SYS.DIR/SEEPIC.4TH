\ Copyright (c) 1987-2006 by Daniel Scheidt & Frank H. Rothkamm.  All rights reserved.
  
\ loads and save DEGAS files-> to the screen, memory & moves pictures from 
\ memory to screen
\ last update: 3/23/98 
\ added WBM (Wireless Bit Map) support as an interface to photoshop  3/4/04

\ all image operations work with a 32000 word long consecutive area of memory.
\ all images are loaded into allocated memory and then copied to the screen.

\ === procedure ======================-
\ create my_picture  32000 allot      \ create a memory location for picture
\ my_picture to *picture              \ set this location as default
\ """ my_picture.wbm ""load-wbm       \ load the picture (to default)
\ my_picture show                     \ copy it the screen


\ -------------
2 xbios: screen-base  { -- a.screen-base }
\ screenbase constant screen-base

: ""see-pic ( string -- )
  read-open
  34 ifd @ fseek	
  screen-base
  32000
  ifd @  fgets
  drop
\  close-files
;

: ""see-wbm ( string -- )
  read-open
  6 ifd @ fseek
  screen-base
  32000
  ifd @  fgets
  drop
\  close-files
;

create picture 32000 allot 

quan *picture 
picture to *picture        

: ""load-pic   (  string addr -- ) 
  read-open 
  34 ifd @ fseek	\ skip header
  *picture 
  32000
  ifd @  fgets
  drop
\ close-files
;

: ""load-wbm   (  string addr -- )
  read-open
  6 ifd @ fseek	\ skip header
  *picture
  32000
  ifd @  fgets
  drop
\  close-files
;


: loadpic:
 blword ""load-pic
; 

: seepic:
  blword ""see-pic
;

: show ( addr -- )       \ from address to screen
    screen-base 32000 cmove  
; 

: "savepic  ( string -- )
  new-file
  34 ifd @ fseek
  screen-base
  32000  ofd @  fputs
\  close-files
;

: savepic:
  blword "savepic
;

: screen-noise  ( -- )  \ copy random area of memory onto screen   
 erase-screen
 4 irnd 1+ 32000 * 2+ screen-base 32000 cmove
;



:  picture-logo
  
   erase-screen
   81 0 do
   *picture screen-base
   i  + 32000 cmove
   10 +loop

  
;

defer logo

' screen-noise is logo

