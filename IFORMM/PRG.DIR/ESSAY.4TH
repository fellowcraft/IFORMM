\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ generates a 500 word essay, poem, proposal in a new human language 
\ which has a somewhat greater probability to resemble the english language
\ than 1 million monkeys that typing on typewriters and produce a work
\ of Shakespeare.

: essay
  depth if else 
  ." Usage: [1] [2] essay" cr
  ." ----------------------" cr
  ." Options:" cr
  ." 1" 9 emit ." regular text" cr
  ." 2" 9 emit ." display word numbering" cr exit  
  then
   
\ 65 90 rndbetween emit
 500 1 do  
	 \ word generation
	 8 irnd 1+ 0 do  
     97 122 rndbetween emit
	 loop
	 \ sentence/space generation
	 10 irnd 0 = if 
	 ." . " 65 90 rndbetween emit  
	 else
	 ."  "
 	 then
  	 \ display option 
	 
	 i 10 mod 0 = if cr 
	       dup 2 = if 40 emit i (.) type 41 emit 
		           then
		          then      
  loop
  drop 
  ." ."
;
