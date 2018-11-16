; sr = 48000
; kr =  4800
sr = 44100
kr =  4410
ksmps = 10
nchnls = 2
galeft init 0
garight init 0

instr 1
idur     		= p3    ; total duration of event
iamp     		= p4*0.82 ; amplitude in dB: 0-96
ifreq    		= p5    ; frequency in Hz: 20-20000 (depending on sr (sample rate)) 
iat      		= p6    ; Attack portion of the AR amplitude envelope 
irel     		= p7    ; Release portion of the AR amplitude envelope                       
						; NOTE: probability is computed for the attack portion, the envelope is:
						; idur - iat = irel 
						; at 100 (max) for iat, attack could be the whole envelope, with release = 0
ipanstart 		= p8    ; Start of Pan (0-1 = left to right)
ipanend   		= p9    ; End of Pan
ifilterwidth	= p10   ; Width of Notch Filter
irevsend  		= p11   ; Reverb Amount

; iwidth = 200

awhite unirand 2.0
awhite = awhite - 1.0


   
   kpan    linseg  ipanstart, idur, ipanend,             ; panning 0.0-1.0 
                                                         ; right-left 
 ; asoft   max irel 0.1
   k1      linseg  0, iat, ampdb(iamp), irel, 0  ; envelope AR (krel > 1.0 ? 1.0 : rel) 
;  k2      oscil     k3, p8, 1
;  asig    randi k1, sr                                  ; random signal
;  asig    pinkish awhite, 1, 0, 0, 1    
; butterbp
	
	
;   vibrato, very slight with the same envelope than the volume

	a2      oscili k1*0.0002, (ifilterwidth*0.05)+3, int(ipanstart*3.9)+1
	a3      oscili k1*0.06,  (ifreq+a2)*2.01*0.5 , int(ipanstart*3.9)+1
	a4      oscili k1,       (ifreq+a2)     *0.5 , int(ipanstart*3.9)+1
;	a33     oscili k1*0.04,  (ifreq+a2)*4.91*0.5 , 1;int(ipanstart*3.9)+1
;	a44     oscili k1*0.004,  (ifreq+a2)*8.01*0.5 , 1;int(ipanstart*3.9)+1
	a5  =   a3 + a4 ;+ a33 + a44                 	    
  ; a1 moogvcf2 a5, ifreq, .8
  	a1  =   a5 	 
  ; a1  clfilt a5, 20, 1, 10
	outs    a1 *  kpan, a1 * (1 - kpan)
    galeft    =         galeft  +  a1*kpan     * irevsend/6
    garight   =         garight +  a1*(1-kpan) * irevsend/6
endin

instr 99                 ; global reverb
     irvbtime    =         p4 
     aleft        reverb    galeft,  irvbtime
     aright       reverb    garight, irvbtime 
     outs  aright, aleft
     galeft    =    0              ; then clear it
     garight   =    0 
endin 

         
