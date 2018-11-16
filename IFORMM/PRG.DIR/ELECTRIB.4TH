\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\ -------------------- Korg ER-1 knob input transform -----------------
\ ---------------------------------------------------------------------

\ the knobs send 3 values: cc 98 and 99 to identify the parameter
\ and then cc 6 to change the value.

\ this will transformed into a single cc of our chosing.

quan cc_previous1  true to cc_previous1   \ true is -1 and not 0-127 midi value
quan cc_previous2  true to cc_previous2  

quan cc_data_entry 6 to cc_data_entry
 

create in_knobs        	2 ,  6 ,  5 ,    8 ,      7 ,
                            	  4 ,    1 ,      0 ,

  		       12 ,  16 , 15 ,  18 ,      17 ,
                         	  14 ,  11 ,      10 , 

                       22 ,  26 , 25 ,   28 ,     27 ,
                             	  24 ,   21 ,     20 ,  

                       32 , 36 ,  35 ,   38 ,     37 ,
                              	  34 ,   31 ,     30 , 

                                         100 ,    101 , 
                       


create cc_knobs_1        

  50 , 51 , 52 ,  53 ,   54 , 
            55 ,  56 ,   57 ,

  70 , 71 , 72 ,  73 ,   74 , 
            75 ,  76 ,   77 ,

  80 , 81 , 82 ,  83 ,   84 , 
            85 ,  86 ,   87 ,

  110 , 111 , 112 ,  113 ,  114 , 
              115 ,  116 ,  117 ,

                  28 ,   29 ,  true ,


create cc_knobs_2        

  14 , 15 , 16 ,  17 ,   18 , 
            13 ,  19 ,   20 ,

  70 , 71 , 72 ,  73 ,   74 , 
            75 ,  76 ,   77 ,

  80 , 81 , 82 ,  83 ,   84 , 
            85 ,  86 ,   87 ,

  110 , 111 , 112 ,  113 ,  114 , 
              115 ,  116 ,  117 ,

                  28 ,   29 ,  true ,


quan cc_knobs			  \ pointer to (assignment) structure	 
cc_knobs_1 to cc_knobs  	  \ default

                 

:  mcc-thru-korg
      
\ --------------------------------------
  cc_val1 98 = if  			\ if the cc is a Korg knob identifier
              
 34 0 do
       cc_val2
       i /n* in_knobs + @    		\  compare against the knobs  
       = if
         i to cc_previous1 		\  remember it     
         then
      loop
      
               then

\ -------------------------------------
  cc_val1 99 =  cc_val2 2 =  and if     \  if the cc is a Korg knob identifier
  cc_val2 to cc_previous2     		\  remember it
  	                	 then
 

\ -------------------------------------
  cc_val1 cc_data_entry =                 
  cc_previous1 true = not  and 
  cc_previous2 true = not  and            \ if Korg 3 message stream is true   
  if   
   cc_previous1 /n* cc_knobs + @ to cc_val1   \ put our cc controller there
   true to cc_previous1 true to cc_previous2  \ clear and be ready for next
  then 
   
\  -------------------------------------
\  cc_val2                            
\  cc_val1
\  midi-thru-channel
\  mcc
; 

variable korg_inc 0 korg_inc !                  
: .korg  
     begin 
      cc_knobs korg_inc @ + @     \ get the current value   
      dup . 2 .tab                \ print it formated
      4 korg_inc +!               \ inc the offset
     true = until                 \ end of string is found
     0 korg_inc !                 \ reset the offset
       
; 

: allknobs-cc-thru
  
  to cc_val1       			\ get the current parameters    
  to cc_val2

  mcc-thru-korg 

  cc_val2                            
  cc_val1
  midi-thru-channel
  mcc
 
  \ 30 normal-cc-thru
;

: knobs-init
  cc_knobs_2 to cc_knobs  
  ['] allknobs-cc-thru 3 MIDI-action !
;
