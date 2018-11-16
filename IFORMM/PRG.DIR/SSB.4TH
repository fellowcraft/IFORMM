\ Copyright (c) 1987-2012 by Frank H. Rothkamm.  All rights reserved.

only forth also ap-defs also forth definitions 

\ -2 oct
create starN
d   , d   , d   , f+  , a   , +d  , +f+ , +e  , +d , f+ , g   , a   , 
a   , +f+ , +e  , +d  , +c+ , b   , +c+ , +d  , a  , g  , f+  , d   , d   , d  ,
d   , a   , +d  , +d  , +f+ , +d  , f+  , g   , a  , a  , a   ,
+f+ , +e  , +d  , +c+ , b   , +c+ , +d  , +d  , a  , f+ , d   , +f+ , 
+f+ , +g  , +a  , +a  , +g  , +f+ , +e  , +f+ , +g , +g , +f+ , +e  , +f+ ,
+e  , +d  , +c+ , b   , +c+ , +d  , f+  , g   , a  , a  , a   , +d  , 
+d  , +d  , b   , b   , b   , +e  , +g  , +f+ , +e , +d , +c+ , a   , +d  , +e , +f+ , +g ,
+a  , +f+ , +d  , +d  , +e  , +f+ ,  +e , +d  , +d , a  , a   , +d  , +d  ,
+d  , b   , b   , b   , +e  , +f+ , +e  , +c+ , a  , +d , +e  , +f+ , +g  , +a , +f+ ,
+d  , +d  , +f+ , +e  , +d  , +d  ,   

create starR
1 , 3 , 2 , 2 , 2 , 4 , 1 , 1 , 2 , 2 , 2 , 4 ,
2 , 2 , 2 , 2 , 3 , 1 , 2 , 4 , 1 , 1 , 1 , 3 , 2 , 2 ,
2 , 2 , 2 , 2 , 2 , 2 , 2 , 2 , 4 , 1 , 1 ,
3 , 1 , 2 , 4 , 1 , 1 , 1 , 3 , 2 , 2 , 2 , 2 ,
1 , 3 , 2 , 4 , 1 , 1 , 2 , 2 , 2 , 4 , 1 , 1 , 2 ,
2 , 2 , 3 , 1 , 2 , 2 , 2 , 2 , 4 , 1 , 1 , 2 , 
2 , 2 , 1 , 3 , 2 , 2 , 1 , 1 , 1 , 1 , 4 , 2 , 3 , 1 , 1 , 1 ,
2 , 2 , 2 , 1 , 1 , 2 , 1 , 1 , 4 , 1 , 1 , 2 , 2 ,
2 , 2 , 2 , 2 , 3 , 1 , 2 , 4 , 2 , 3 , 1 , 1 , 1 , 2 , 2 ,
2 , 1 , 3 , 1 , 1 , 6 , 

:ap ssb 
::ap   	
::tsg  

124 0 do 
i /l* starR + @  
8 r>i & 
loop	       

;;sg
	           
    \ 12 irnd 2* to $volume
           
     124 0 do
	  		    
     i /l* starN + @  
	\ i . cr
	 $   
    
     loop
   
;;ap
;ap
