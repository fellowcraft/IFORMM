\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ NEWPROMPT - prompting with the original ok and path output

decimal  

: (newprompt 
   #out @ if cr then status 
  
       td 111 emit  td 107 emit   \ old style 
   \  .drive                      \ new style with drive output

   .dir 
   state @ 
   if   ascii ] emit 
   then 
   bl emit 
;

' (newprompt is prompt 
: restore-prompt ['] (prompt is prompt ;

