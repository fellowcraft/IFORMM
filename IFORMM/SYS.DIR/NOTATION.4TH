\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ NOTATION -- various notational niceties.


loaded definitions create _notation
only forth also definitions
decimal

sg-defs definitions

:sg /1 1|1 & ;sg	:sg /2 1|2 & ;sg	:sg /4 1|4 & ;sg
:sg /8 1|8 & ;sg	:sg /16 1|16 & ;sg	:sg /32 1|32 & ;sg
:sg /64 1|64 & ;sg

\ ****************  especial ones added by MLADEN MILICEVIC

:sg /3 1|3 & ;sg    :sg /6 1|6 & ;sg    :sg /12 1|12 & ;sg  
:sg /24 1|24 & ;sg  :sg /48 1|48 & ;sg  :sg /96 1|96 & ;sg

:sg /1-3 /3 /3 /3 ;sg
:sg /2-3 /6 /6 /6 ;sg
:sg /4-3 /12 /12 /12 ;sg
:sg /8-3 /24 /24 /24 ;sg
:sg /16-3 /48 /48 /48 ;sg
:sg /32-3 /96 /96 /96 ;sg

:sg /5 1|5 & ;sg   :sg /10 1|10 & ;sg  :sg /15 1|15 & ;sg   :sg /30 1|30 & ;sg  

:sg /1-5 /5 /5 /5 /5 /5 ;sg
:sg /2-5 /10 /10 /10 /10 /10 ;sg
:sg /4-5 /15 /15 /15 /15 /15 ;sg    
:sg /8-5 /30 /30 /30 /30 /30 ;sg

:sg /7 1|7 & ;sg   :sg /14 1|14 & ;sg  :sg /28 1|28 & ;sg   :sg /56 1|56 & ;sg

:sg /1-7 /7 /7 /7 /7 /7 /7 /7 ;sg
:sg /2-7 /14 /14 /14 /14 /14 /14 /14 ;sg
:sg /4-7 /28 /28 /28 /28 /28 /28 /28 ;sg
:sg /8-7 /56 /56 /56 /56 /56 /56 /56 ;sg

\ ********************** MLADEN end ************************

:sg /2. 3|4 & ;sg	:sg /4. 3|8 & ;sg	:sg /8. 3|16 & ;sg
:sg /16. 3|32 & ;sg	:sg /32. 3|64 & ;sg

:sg /4.. 7|16 & ;sg

:sg /1,, 5|4 & ;sg	:sg /2,, 5|8 & ;sg	:sg /4,, 5|16 & ;sg

:sg /2,,, 9|16 & ;sg	:sg /4,,, 9|32 & ;sg

:sg /4.8 /4. /8 ;sg	:sg /2.4 /2. /4 ;sg	:sg /8.16 /8. /16 ;sg

:sg 2/2 /2 /2 ;sg	:sg 4/2 2/2 2/2 ;sg

:sg 2/4 /4 /4 ;sg	:sg 3/4 /4 /4 /4 ;sg

:sg 4/4 /4 /4 /4 /4 ;sg	:sg 8/4 /4 /4 /4 /4 /4 /4 /4 /4 ;sg

:sg 2/8 /8 /8 ;sg	:sg 3/8 /8 /8 /8 ;sg	:sg 4/8 /8 /8 /8 /8 ;sg
:sg 5/8 4/8 /8 ;sg	:sg 6/8 3/8 3/8 ;sg     :sg 7/8 3/8 4/8 ;sg
:sg 8/8 4/8 4/8 ;sg     :sg 16/8 8/8 8/8 ;sg

:sg 2/16 /16 /16 ;sg         :sg 3/16 /16 /16 /16 ;sg  :sg 4/16 2/16 2/16 ;sg
:sg 6/16 2/16 4/16 ;sg       :sg 7/16 3/16 4/16 ;sg    :sg 8/16 4/16 4/16 ;sg  
:sg 9/16 2/16 3/16 4/16 ;sg  :sg 10/16 9/16 /16 ;sg    :sg 11/16 10/16 /16 ;sg
:sg 12/16 6/16 6/16 ;sg	     :sg 16/16 8/16 8/16 ;sg   :sg 32/16 16/16 16/16 ;sg

:sg 2/32 /32 /32 ;sg	:sg 3/32 /32 /32 /32 ;sg  :sg 4/32 2/32 2/32 ;sg
:sg 8/32 4/32 4/32 ;sg  :sg 16/32 8/32 8/32 ;sg	  :sg 32/32 16/32 16/32 ;sg

:sg /2+ /2 2/4 ;sg	:sg /4+ /4 2/8 ;sg	:sg /8+ /8 2/16 ;sg

ap-defs definitions

:ap /1 ::tsg begin /1 again ;;sg ;ap
:ap /2 ::tsg begin /2 again ;;sg ;ap
:ap /4 ::tsg begin /4 again ;;sg ;ap
:ap /8 ::tsg begin /8 again ;;sg ;ap
:ap /16 ::tsg begin /16 again ;;sg ;ap
:ap /32 ::tsg begin /32 again ;;sg ;ap

\ ********************* The following definitions added by MLADEN

:ap /64 ::tsg begin /64 again ;;sg ;ap

:ap /2. ::tsg begin /2. again ;;sg ;ap
:ap /4. ::tsg begin /4. again ;;sg ;ap
:ap /8. ::tsg begin /8. again ;;sg ;ap
:ap /16. ::tsg begin /16. again ;;sg ;ap  
:ap /32. ::tsg begin /32. again ;;sg ;ap  

:ap /4.. ::tsg begin /4.. again ;;sg ;ap 

:ap /1,, ::tsg begin /1,, again ;;sg ;ap 
:ap /2,, ::tsg begin /2,, again ;;sg ;ap 
:ap /4,, ::tsg begin /4,, again ;;sg ;ap 
:ap /2,,, ::tsg begin /2,,, again ;;sg ;ap 
:ap /4,,, ::tsg begin /4,,, again ;;sg ;ap 

:ap /1-3 ::tsg begin /1-3 again ;;sg ;ap   
:ap /2-3 ::tsg begin /2-3 again ;;sg ;ap   
:ap /4-3 ::tsg begin /4-3 again ;;sg ;ap   
:ap /8-3 ::tsg begin /8-3 again ;;sg ;ap   
:ap /16-3 ::tsg begin /16-3 again ;;sg ;ap 
:ap /32-3 ::tsg begin /32-3 again ;;sg ;ap 

:ap /1-5 ::tsg begin /1-5 again ;;sg ;ap   
:ap /2-5 ::tsg begin /2-5 again ;;sg ;ap   
:ap /4-5 ::tsg begin /4-5 again ;;sg ;ap   
:ap /8-5 ::tsg begin /8-5 again ;;sg ;ap   

:ap /1-7 ::tsg begin /1-7 again ;;sg ;ap   
:ap /2-7 ::tsg begin /2-7 again ;;sg ;ap   
:ap /4-7 ::tsg begin /4-7 again ;;sg ;ap   
:ap /8-7 ::tsg begin /8-7 again ;;sg ;ap   

:ap /4.8 ::tsg begin /4.8 again ;;sg ;ap   
:ap /2.4 ::tsg begin /2.4 again ;;sg ;ap   
:ap /8.16 ::tsg begin /8.16 again ;;sg ;ap 

:ap 2/2 ::tsg begin 2/2 again ;;sg ;ap     
:ap 4/2 ::tsg begin 4/2 again ;;sg ;ap     
      
:ap 2/4 ::tsg begin again ;;sg ;ap   
:ap 3/4 ::tsg begin again ;;sg ;ap   
:ap 4/4 ::tsg begin again ;;sg ;ap   
:ap 8/4 ::tsg begin again ;;sg ;ap   

:ap 2/8 ::tsg begin 2/8 again ;;sg ;ap
:ap 3/8 ::tsg begin 3/8 again ;;sg ;ap
:ap 4/8 ::tsg begin 4/8 again ;;sg ;ap
:ap 5/8 ::tsg begin 5/8 again ;;sg ;ap
:ap 6/8 ::tsg begin 6/8 again ;;sg ;ap
:ap 7/8 ::tsg begin 7/8 again ;;sg ;ap
:ap 8/8 ::tsg begin 8/8 again ;;sg ;ap
:ap 16/8 ::tsg begin 16/8 again ;;sg ;ap

:ap 2/16 ::tsg begin 2/16 again ;;sg ;ap
:ap 3/16 ::tsg begin 3/16 again ;;sg ;ap
:ap 4/16 ::tsg begin 4/16 again ;;sg ;ap
:ap 6/16 ::tsg begin 6/16 again ;;sg ;ap
:ap 7/16 ::tsg begin 7/16 again ;;sg ;ap
:ap 8/16 ::tsg begin 8/16 again ;;sg ;ap
:ap 9/16 ::tsg begin 9/16 again ;;sg ;ap
:ap 10/16 ::tsg begin 10/16 again ;;sg ;ap
:ap 11/16 ::tsg begin 11/16 again ;;sg ;ap
:ap 12/16 ::tsg begin 12/16 again ;;sg ;ap
:ap 16/16 ::tsg begin 16/16 again ;;sg ;ap
:ap 32/16 ::tsg begin 32/16 again ;;sg ;ap

:ap 2/32 ::tsg begin 2/32 again ;;sg ;ap  
:ap 3/32 ::tsg begin 3/32 again ;;sg ;ap  
:ap 4/32 ::tsg begin 4/32 again ;;sg ;ap  
:ap 8/32 ::tsg begin 8/32 again ;;sg ;ap  
:ap 16/32 ::tsg begin 16/32 again ;;sg ;ap
:ap 32/32 ::tsg begin 32/32 again ;;sg ;ap

\ *** MLADEN - end

:ap /2+ ::tsg begin /2+ again ;;sg ;ap
:ap /4+ ::tsg begin /4+ again ;;sg ;ap
:ap /8+ ::tsg begin /8+ again ;;sg ;ap

\ ************************************************************************
 
:ap $2 2 $n ;ap		:ap $3 3 $n ;ap		:ap $4 4 $n ;ap
:ap $5 5 $n ;ap		:ap $6 6 $n ;ap		:ap $7 7 $n ;ap
:ap $8 8 $n ;ap

:ap 2$ 2 m$ ;ap		:ap 3$ 3 m$ ;ap		:ap 4$ 4 m$ ;ap
:ap 5$ 5 m$ ;ap		:ap 6$ 6 m$ ;ap		:ap 7$ 7 m$ ;ap
:ap 8$ 8 m$ ;ap		:ap 9$ 9 m$ ;ap		:ap 10$ 10 m$ ;ap
:ap 11$ 11 m$ ;ap	:ap 12$ 12 m$ ;ap	:ap 16$ 16 m$ ;ap

\ this is added from NOTATE2 by Mladen Milicevic

:ap $*6 6 $*k ;ap
:ap 2$*2 2 2 m$*k ;ap	:ap 2$*4 2 4 m$*k ;ap	:ap 2$*8 2 8 m$*k ;ap
:ap 2$*16 2 16 m$*k ;ap
:ap $2*2 2 2 $n*k ;ap	:ap $2*4 2 4 $n*k ;ap	:ap $2*5 2 5 $n*k ;ap
:ap $2*6 2 6 $n*k ;ap
:ap $2*10 2 10 $n*k ;ap
:ap $3*2 3 2 $n*k ;ap
:ap $3*3 3 3 $n*k ;ap	:ap $3*4 3 4 $n*k ;ap	:ap $3*6 3 6 $n*k ;ap
:ap $3*k 3 swap $n*k ;ap
:ap $4*3 4 3 $n*k ;ap
:ap 2$2 2 2 m$n ;ap	:ap 3$2 3 2 m$n ;ap	:ap 4$2 4 2 m$n ;ap
:ap 5$2 5 2 m$n ;ap	:ap 6$2 6 2 m$n ;ap
:ap 8$2 8 2 m$n ;ap	:ap 10$2 10 2 m$n ;ap
:ap 2$3 2 3 m$n ;ap	:ap 2$3*k 2 3 rot m$n*k ;ap
:ap 3$3 3 3 m$n ;ap	:ap 4$3 4 3 m$n ;ap	:ap 6$3 6 3 m$n ;ap
:ap 2$2*2 2 2 2 m$n*k ;ap	:ap 2$2*8 2 2 8 m$n*k ;ap
:ap 2$2*4 2 2 4 m$n*k ;ap	:ap 4$2*2 4 2 2 m$n*k ;ap

forth definitions

sh-defs definitions

\ customs for volume:
\ -96 to +95 for volume shapes (ppp through fff)
\ 0 to 32 for instruments
\ -32 to 0 for $cvolume

 -128 constant pppp
 -96 constant ppp
 -69 constant pp
 -42 constant p
 -14 constant mp
 14 constant mf
 42 constant f
 69 constant ff
 95 constant fff
 127 constant ffff
