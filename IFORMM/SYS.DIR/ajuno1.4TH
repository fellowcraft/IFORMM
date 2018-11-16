\ Copyright (c) 1987-2011 by Frank H. Rothkamm.  All rights reserved.

\ ------------------------------------------------------------------------------
\ ----------------------------Roland Alpha Juno 1-------------------------------
\ ------------------------------------------------------------------------------


only forth also ap-defs also internals also forth definitions

pquan para2#
pquan data2#



: AJUNO1  ( parameter data -- ) 

        to data2#
        to para2# 
   
tb 11110111
     data2# 
     para2# 
tb 00000001 			\ Group # 
tb 00100000 			\ Level #  
tb 00100011 			\ Format Type    
   para-channel                            
tb 00110110				\ Operations Code (IPR)
tb 01000001    			\ Roland ID 
tb 11110000 

   10 ['] MIDI-command-event event
;


: AJUNO1.RND

   
tb 11110111
36 0 do 127 irnd loop   \ Randomize
tb 00000001 			\ Group # 
tb 00100000 			\ Level #  
tb 00100011 			\ Format Type    
   para-channel                            
tb 00110101				\ Operations Code (APR)
tb 01000001    			\ Roland ID 
tb 11110000 

   44 ['] MIDI-command-event event
;

