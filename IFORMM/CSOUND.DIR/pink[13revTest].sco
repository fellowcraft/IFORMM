; <pre>

;  60000 events - total 3600 seconds"
;  20.0 - 2000.0 Hz     
;  30.0 - 90.0 dB

f1  0  4096  10  1
 


; Reverb
; ins     strt dur                revTime                 
  i99     0    10                 10

; Osc	start	dur	amp	freq	attack	rel	panS	panE 	filterwidth		revSend

 	
i1 	0	0.3	66.5	1532.6	0.004	1.0     0.0	  0.0	 10  0.1 	
i1 	1	0.3	70.0	1364.9	0.215	1.0	    1	    1	   10  0.01	
i1 	2	0.3	80.7	1107.0	0.375	1.0	    0.5	  0.5	 10  0.01 	
e