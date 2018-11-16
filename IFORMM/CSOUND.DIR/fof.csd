<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
kr = 4410
ksmps = 10


			
instr 1 			

ifreq =  cpsoct(p4)

    ; a2 	oscil 	20,  5,  1
    ; a2   linseg 	0,  p3*.3,  20000,  p3*.4,  15000,  p3*.3,  0
	; a2 	expseg 	5,  p3*.8,  200,  p3*.2,  150
	; k1 	linseg 	0, p3*.1, 0, p3*.8, 6, p3*.1, 6
	; a1 	fof 	10000, 200, 650, k1, 0, .003, .02, .007, 5, 1, 2, p3

    ; a2 	line 	400,  p3,  800
    ; a1 	fof 	15000, 5, a2, 0, 1, .003, .5, .1, 3, 1, 2, p3, 0, 1

;acarr 	line 	400, p3, 800
;index 	= 	2.0
;imodfr 	= 	400
;idev 	= 	index * imodfr
;amodsig 	oscil 	idev, imodfr, 1
;a1 	fof 	15000, 5, acarr+amodsig, 0, 1, .003, .5, .1, 3, 1,  2,  p3,  0,  1

;k1 	line 	.003, p3, .1 	; kris
;a1 	fof 	15000, 2, 300, 0, 0, k1, .5, .1, 2, 1, 2, p3

;k1 	linseg 	0, p3, 10 	; kband
;a1 	fof 	15000, 4, 300, 0, k1, .003, .5, .1, 2, 1, 2, p3

;k1 	linseg 	3, p3, .003
;a1 	fof 	15000, 2, 300, 0, 0, .003, .4, k1, 2, 1, 2, p3

;k1 	expon 	.3, p3, .003
;a1 	    fof 	15000, 2, 300, 0, 0, .003, .01 + k1, k1, 2, 1, 2, p3

;k1 	linseg 	100, p3/4, 0, p3/4, 100, p3/2, 100 	; kband
;k2 	linseg 	.003, p3/2, .003, p3/4, .01, p3/4, .003 	; kris
;a1 	fof 	15000, 100, 440, 0, k1, k2, .02, .007, 3, 1, 2, p3

a2 	expseg 	1,  p3*.2,  16000,  p3*.8, 1
a1 	oscil 	 a2,  ifreq,  1

	out 	a1 	
endin 			

</CsInstruments>
<CsScore>

f1 	0 	4096  	10  	1 			
f2  	0 	1024  	19  	.5  	.5  	270  	.5
i1  	0 	1 8.08
i1  	+1  . 8.16   					
i1  	+2	. 8.24
e

</CsScore>
</CsoundSynthesizer>
