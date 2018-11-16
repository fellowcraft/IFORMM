\ Copyright (c) 1987-2007 by Frank H. Rothkamm.  All rights reserved.

\                         3.

                 \ ----------------- /
 		 \ polygon(unfilled) /
                 \ ----------------- /

 create fischpoints
		110  w, 200 w,   110 w,    110 w,  \ (x1/y1)point1.point2
		350 w,  200 w,   410 w,    155 w,  \        point3...
		350 w,  110 w,   200 w,    200 w,  \     ...point6


 create fischpoints(old)
		10  w, 100 w,      10 w,     10 w,  \ (x1/y1)point1.point2
		250 w, 100 w,     310 w, 110 2/ w,  \        point3...
		250 w,  10 w,      10 w,    100 w,  \     ...point6


 : Fisch
 \  addr        n(number of points )
 \ -----------|-------------------------|---------
   fischpoints  6                          polygon(unfilled)
 ;

 : up-or-down
   3 irnd  brnd if + else - then  400 min 1 max
 ;


: (FischWarp

   10 0 do
              fischpoints      i /w* +  w@
              dup
              fischpoints(old) i /w* +  w!
              up-or-down
              fischpoints      i /w* +  w!

        loop

              \ first point = last point
              fischpoints               w@
              fischpoints      10 /w* + w!
              fischpoints(old)          w@
              fischpoints(old) 10 /w* + w!

              fischpoints       1 /w* + w@
              fischpoints      11 /w* + w!
              fischpoints(old)  1 /w* + w@
              fischpoints(old) 11 /w* + w!


             white-line
             fischpoints(old) 6 polygon(unfilled)


             black-line
             fischpoints     6 polygon(unfilled)

;


: fish
 erase-screen
 begin
 (FischWarp
 key? if erase-screen exit then
 again
;
