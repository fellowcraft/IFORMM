; <pre>

;  30000 events - total 3600 seconds"
;  20.0 - 2000.0 Hz     
;  30.0 - 96.0 dB

   f1 0 65536 10 1 .1
   f2 0 65536 10 1 .5 .3 .25 .2 .167 .14 .125 .111      ; Sawtooth
   f3 0 65536 10 1 0  .5  0  .2  0.1  0  .05          ; Square
   f4 0 65536 10 1 1 1 1 .7 .5 .3 .1                    ; Pulse
 


; Reverb
; ins     strt dur                revTime                 
  i99     0    10   5

; Osc	start	dur	    amp	freq	attack	rel	    panS panE 	filterwidth		revSend

 	

i1       1	0.002	90  40	  0.01	  0.01	  0.39 0.74	  0             0.0 	
i1       2	3.002	90  2000	0.001	  0.001	  0.39 0.74	  2             0.0



e
; </pre>


