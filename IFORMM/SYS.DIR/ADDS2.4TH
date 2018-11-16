\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ADDS  additional words + short forms of existing ones
\                                                                      FISCH8/88


\   ******************* SUMMERY ********************************************
\   1.     tb ; a word like th or td lets you enter a binary number  
\   2.     screen-setting e.g. to reverse-screen   
\   3.     short forms of formula pquans  
\   4.     tel   ( x y -- ) length of a $ note:  1 4 tel = quarter note
\   5.      inches-to-feet ( x --- i f ) conversion   

\ -------------------------- tb (one binary) -----------------------------------
\ the word is the same than  th  or  td   
\ It lets you enter a binary number  e.g.  tb 00001111   

: tb  base @ >r binary bl word "compile r> base !
;
immediate  

\                               2. 

\ ---------------- screen settings ---------------------------------------------
\ Allows you to do  
\ WORDS                         |               ACTIONS 
\ ..............................................................................
\ reverse-screen                 turns white character on black ground 
\ normal-screen                        back               white        (default)
\ cursor-blink-on                cursor will blink   
\ cursor-blink-off               cursor wont blink   
\ cursor-blink-speed  ( n -- )   if cursor blinks here you set the speed(1-~255)

                   
\ only forth also system also definitions

7  xbios: setcolor { w.colorNum w.color -- } 
21 xbios: cursconf { w.function w.operand -- } 

\ forth definitions

: reverse-screen   0 16 setcolor ;
: normal-screen    1 16 setcolor ; 
: cursor-blink-on  0  2 cursconf ; 
: cursor-blink-off 0  3 cursconf ;
: cursor-blink-speed  ( speed# -- )  4  cursconf ; 

alias l +load 
alias kl kill-all

:ap tel   
   ::tsg [ 2 params ] 
         r>i & 
   ;;sg
   
;ap 

: inches-to-feet
  dup 12 / swap 12 mod swap
;  