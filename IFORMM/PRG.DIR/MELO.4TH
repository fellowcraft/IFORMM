\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

only forth also ap-defs also forth definitions 

-2 oct
create cm e , f , a- , a , b , c , e- ,

: cmrnd
  irnd /l* cm + @ 
;

pquan transpose

:ap dd2                  \   12.0  0  dd2  
   ::ap  [ 1 params ]  
  
        to transpose

    \  to $transpose  to $channel 
        
    begin
     
     12 irnd 2* to $volume
      
     	4 irnd 1+   
	1 
	tel       
     
     7 cmrnd 60 + transpose + $   
    
     brnd if
          4 irnd 1+ 
      	  1 
	  tel 
	  0 $ 
          then
 
   again
 
  ;;ap
 
;ap


:ap dd                   \ 12.0 dd
      
    ::ap  [ 1 params ]  

    to $transpose
    begin
     
     12 irnd 2* to $volume
      
     1 12 irnd 1+ tel       
     
     12 irnd 60 + $   
    
     brnd if
          1 12 irnd 1+ tel 0 $ 
          then
 
   again
   ;;ap
;ap
