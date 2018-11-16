\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

quan random_x    300 to random_x
quan random_y    200 to random_y
quan random_step   2 to random_step

: buterfly
    300 to random_x
    200 to random_y
    ['] noop is mouse-routine       \ no double program
    erase-screen


 begin

\ ------------------------------ butterfly ------------------------------

       right-button if random_step 1+ 100 min to random_step then
       left-button  if random_step 1-   1 max to random_step then

       random_x   brnd if     random_step +  629 min
                       else   random_step -  1 max
                       then to random_x


       random_y   brnd if    random_step +  389 min
                       else  random_step -  1 max
                       then to random_y

       brnd if grey-fill else black-fill then

           random_x x1 ! random_y y1 ! 9 y2 ! 9 x2 !
           box(filled)

       key?  if
                ['] graphic is mouse-routine
                1 char-color !
                erase-screen exit
              then
again
;
