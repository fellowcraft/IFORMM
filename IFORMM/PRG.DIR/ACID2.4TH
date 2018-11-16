\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\  ****************************************************************************
    
\ 	-> !!!!!!  Phrase Generator  !!!!! <- 
\   	creates a self-similar two bar phrase   	

\                             DOES: 

\ 				I
\ Takes two octave range and generates notes at ramdom ( uniform )
\ in a 16th note resolution.  
\				II
\ Decides whether to generate a rest or that note 
\				III
\ Repeats the first 12 notes or rests of the first bar and     
\ generates 4 new notes for the completion of the two bar phrase  

\			 SOUNDS LIKE:

\ The result are syncopted phrase of atonal character.( = Acid House riffs ) 
\ Tonal melodies are possible, but less likely to occur.   
\ Good for Drums  


\        make-seq        :   makes a new phrase   
\        make-seq2       :   ok make-seq       

\        self-motiv      :   plays the phrase 
\                            Takes two parameters:
\                            1. how many times to repeat the phrase       
\ 	                     2. MIDI-channel (-1)			
\        self-motiv2     :   ok  100 0 self-motiv 

\        print-seq       :   print Midi-note numbers to screen       
\        print-seq2      :   ok print-seq 

\        make-score      :   generates a FORMULA word motivX (X=0,1,2,...)  
\                            that takes two parameters ( see self-motiv )   
\        make-score2     :   ok  append-to-file xxx make-score          

\        prob            :   set the probabilty ( 0 - 100 ) of playing notes 
\                            from the other self-motiv. The greater prob
\                            gets, the more probable it is that it plays notes
\                            from the other self-motiv. If 0 ( default ) these  
\                            chances are none. Good for morphing.  
\        prob2           :   ok 10 prob !  

\        "save-seq	 :   save the sequence to disk, you string it  
\        "save-seq2      :   "" your.seq "save-seq 

\        "load-seq       :   save the sequence from disk, string please 
\        "load-seq2      :   "" your.seq "load-seq


decimal

create seq    32 /n* allot  
create seq2   32 /n* allot 

seq 32 erase seq2 32 erase 

: generate-note  
     brnd if 24 irnd 2* 40 + else 0 then         
; 

: generate-note2  
     brnd if 24 irnd 2* 40 + else 0 then         
; 

: make-seq  
    16 0 do generate-note i /n* seq + ! loop
    28 16 do  i 16 - /n* seq + @  i /n* seq + ! loop
    32 28 do  generate-note i /n* seq + ! loop 
; 

: make-seq2
    16 0 do generate-note2 i /n* seq2 + ! loop
    28 16 do  i 16 - /n* seq2 + @  i /n* seq2 + ! loop
    32 28 do  generate-note2 i /n* seq2 + ! loop
; 

: print-seq  32 0 do  i 16 = if cr then 
                      i /n* seq + @ . loop  ;

: print-seq2  32 0 do  i 16 = if cr then 
                      i /n* seq2 + @ . loop  ;


: "load-seq  ( string  -- ) 
  read-open 
  32 0 do ifd @ fgetc i /n* seq + ! loop
  close-files
;

: "load-seq2   ( string  -- ) 
  read-open 
  32 0 do ifd @ fgetc i /n* seq2 + ! loop
  close-files
;

: "save-seq  ( string -- )
  dup file-exists? if
  ." file exists -- overwrite? (y/n) "
  key ascii y <> if quit then
  then
  new-file
  32 0 do i /n* seq + @ ofd @ fputc  loop 
  close-files
;

: "save-seq2  (  string -- )
  dup file-exists? if
  ." file exists -- overwrite? (y/n) "
  key ascii y <> if quit then
  then
  new-file
  32 0 do i /n* seq2 + @ ofd @ fputc loop 
  close-files
;

variable score#  0 score# !

variable score2#  0 score2# !
  
: make-score 
      ." :ap  motiv" score# @ .  1 score# +!  ." [ 2 params ]" cr          
      ."         to note-channel" cr  
      ."     0 ?do  /16 "  cr             
             print-seq   ." 32 m$" cr   
      ."     loop " cr            
      ." ;ap " cr 
;   
  
: make-score2 
      ." :ap  motiv" score2# @ .  1 score2# +!  ." [ 2 params ]"  cr          
      ."         to note-channel" cr  
      ."     0 ?do  /16 "  cr             
             print-seq2   ." 32 m$" cr   
      ."     loop " cr            
      ." ;ap " cr 
;   

variable selbst  selbst on 

variable prob     prob  off     \  probabilty between the 2 self-motivs  
variable prob2    prob2 off     \   

:ap self-motiv 
        
    ::ap [ 2 params ]
          to $channel
         0 ?do 
     /16 
        32 0 do  i /n* 
                 100 irnd prob @ < if   seq2 +   
                                   else seq  + 
                                   then      @
 
                 selbst @ if else drop r then /16 $ 

            loop
      
      loop 
    ;;ap   
;ap

:ap self-motiv2 
       
     ::ap [ 2 params ]
         to $channel
       0 ?do 
      
        32 0 do  i /n* 
                 100 irnd prob2 @ < if   seq  +   
                                    else seq2 + 
                                    then      @
 
                 selbst @ if else drop r then /16 $ 

            loop
      
      loop 
     ;;ap  
;ap
