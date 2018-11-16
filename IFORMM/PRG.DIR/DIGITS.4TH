\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ forget 1million key drop .s cr

create Million 1000 allot 0 Million !
  
: million-read 
  [""] rand.txt read-open
  
  
  6 0 do ifd @ fgetc drop loop   \ skip 5 digit index 
  
  0
  begin 
  ifd @ fgetc 48 -
  dup 0 >= 
  if  
    swap 1+ dup -rot      \ increase counter                         
    Million + c!          \ store number
  else drop
  then
  dup 50 = until   
 
  drop
  close-files
;

\ Read a string of characters off a text file as a sequence of single digits, 
\ until a delimter is detected.
\ Transform this sequence into a single decimal number.  
\ Store it in array.

create 1million 400 allot 0 1million !
 
: get-number ( string  -- number ) 
  
  read-open 
   clear

 100  0 do  
  
  begin
  ifd @ fgetc 48 -     \ get char from file and convert to number
  dup 0 < until drop   \ until non-character / space
  
  depth 0 > if
    
  10                    \ inital dec multiplication factor
  
  depth  2 do           \ interations: depth of stack minus 1 minus inital dec 
           -rot         \ get dec out of the way
           swap         \ get next up digit (ie: for 1 that would be 10)
           rot          \ get dec
           dup          
           10 *         \ and make new_dec (multiplication factor) 10 100 ...
           -rot         \ get new_dec out of the way
           *            \ multiply next up digit and dec
           rot          \ get lower digit back   
           +	        \ and add
          swap         \ put new_dec up in front
          loop   
       drop
 

 1million @ 1+ dup      \ self-incrementing array: get counter
 1million !             \ keep
 /n* 1million + !       \ store number 
 
            then 
  loop  
  
   close-files
;
