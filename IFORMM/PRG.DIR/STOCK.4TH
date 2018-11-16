\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

quan start_value 100 to start_value
     
  640 array the_numbers

: start-screen
 
       0 x1 !   0 y1 !   
     638 x2 ! 199 y2 ! 
      box(unfilled)          
 
       0 x1 ! 200 y1 !     
     638 x2 ! 199 y2 ! 
       box(unfilled)

; 

 
: (stock
     
  
640 0 do
      
      i 
      start_value 7 irnd 3 - +          \ previous + or - 3
      0 max 200 min                     \ check boundaries 
 
      dup to start_value                \ keep it 
      dup i the_numbers !               \ and fill the brain
 
      200 +                      	\ screen-offset  
      1 !pix                            \ on the screen  
        
      loop


;


:ap (stock$
\ ::ap" stock$"  

       /64 
       64 to start_value                \ in the middle of MIDI       
  
640 0 do
      
      i 
      start_value 7 irnd 3 - +          \ previous + or - 3
      1 max 127 min                     \ check boundaries 
 
      dup to start_value                \ keep it 
      dup i the_numbers !               \ and fill the brain
     
      dup $                             \ play MIDI 
 
      200 +                      	\ screen-offset  
      1 !pix                            \ on the screen  
        

      loop

  
\ ;;ap
;ap


: restock

    640 0 do  i 
              i the_numbers @  
              0 max 200 min             \ check boundaries
              1 !pix                    \ on the screen  

          loop
 
; 



:ap restock$
 \ ::ap" restock$"
              /64 
    640 0 do  i 
              i the_numbers @  
              1 max 127 min             \ check boundaries
              dup $                     \ play MIDI 
              1 !pix                    \ on the screen  

          loop
 
\  ;;ap
;ap 


:ap stock
::ap" stock random walk"

begin
  erase-screen
  start-screen
  restock
  (stock
  3000 time-advance
again

;;ap
;ap


:ap stock$
::ap" stock random walk"


 ::ap 640 0 do /64 0 $ loop          \ delay one screen lenght
     begin restock$ 
     again 
 ;;ap
 
     begin erase-screen
           start-screen
           (stock$  
     again

;;ap
;ap


\ AMZN 
\ 14 @ 142 5/8 
\  -> 143 5/8 
\     144 5/8 14 
\     145 5/8 28  

\  1  50
\ 1/2 25
\ 1/4 12


\ Programm: share
\ Content: stock market black box   
\ written: 5/17/99
\ last modified: 7/14/99

quan cash        11400 to cash     
quan balance  	140000 to balance
quan commission    700 to commission   \ current per trade @ Scottrade
quan shareprice      0 to shareprice
quan #of_shares      0 to #of_shares
quan in_minutes  30240 to in_minutes     
quan out_upper      20 to out_upper
quan out_lower       8 to out_lower


\ ----------------------- CHANCE ------------------------------- 

: rnd_regions            \ randomize the black box
    20 irnd to out_upper
     8 irnd to out_lower
 30240 irnd to in_minutes 
;

: rnd_stock   ( -- ) 
     
  3 brnd + 0 do  
      65 90 rndbetween emit       
               loop
;


\ ------------------------ MAIN ---------------------------------------

: share   ( whole n m    -- ProfitShareprice ) 

     dup 0= if 2drop 100 *   
            else     
swap 100 * swap / swap 100 * +   \ conversion fraction to absolute
            then
       to shareprice    

  balance 			\ total of money avail.
  commission 2* - 	     	\ minus the commissions 
  shareprice /               	\ how many shares can I buy             
  dup ." #shares: " 1 .tab . cr \ print   
  dup to #of_shares          	\ remember that   


  shareprice 			\ confirm the input
  ." Price/S: " 1 .tab . cr     \ print   

  shareprice *               	\ actual bought stocks 
  commission 2* +            	\ plus market commission
  dup ." Total: "  1 .tab . cr   
  
  dup dup 
  dup out_upper * 100 / + dup
  ." Upper Out:)"   1 .tab .     \ upper limit region  
  swap -    1 .tab  ." +"  .     \ profit  
  
  shareprice dup  
  out_upper * 100 / +             \ 20% per share upper out 
  1 .tab . cr

  dup dup
  dup out_lower * 100 / - dup   
  ." Lower Out:(" 1 .tab .      \ lower limit region 
  -        1 .tab  ." -" .      \ loss 

  shareprice dup  
   out_lower * 100 / -                   \ 8% per share lower out 
   1 .tab . cr

 \  #of_shares /                   \ get the minimum of shareprice for profit  
 \ dup ." market/S: " 1 .tab . cr  \ print
  
\   shareprice - 
\   shareprice swap -
\   dup ." short/S: " 1 .tab . cr	\ print


   drop
 
 ." Minutes/Days:" 
1 .tab in_minutes dup .  
1 .tab 60 24 * / .


    
;

:ap stockchord
::ap
  begin
       640 irnd the_numbers @ 100 tel    

       8 0 do 640 irnd the_numbers @
                  2 >>  36 +                       \ scale down 
                   
            loop  
         8 $n
  again
;;ap
;ap
 

:ap ss
    ::ap
        begin  
        brnd if  1 1 tel else 3 1 tel then    
        42 irnd 40 + 
        127 irnd       
        10
        MIDI-do-note 
        0 $
        again 
    ;;ap   

;ap
