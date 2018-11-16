\ TABLE.FTH  
\ Colletion of defining words to build data structures  
 

\ from: Anderson MASTERING FORTH 
: matrix   create  2dup , , * allot   ;  
: element dup >r @ rot * + r> 4 + +   ;   

\ from: L. J. Scanlon   Forth Programming  ( offset modified for 32/16 bit ) 
: table   create does> swap /n* + @ ; 
