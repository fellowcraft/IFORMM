sr = 48000
kr =  4800
; sr = 44100
; kr =  4410
ksmps = 10
nchnls = 2
garvbsig  init 0    


instr 1
idur     		= p3    ; total duration of event
iamp     		= p4*0.75    ; amplitude in dB: 0-96
ifreq    		= p5    ; frequency in Hz: 20-20000 (depending on sr (sample rate)) 
iat      		= p6    ; Attack portion of the AR amplitude envelope 
irel     		= p7    ; Release portion of the AR amplitude envelope                       
						; NOTE: probability is computed for the attack portion, then envelope computed:
						; idur - iat = irel 
						; at 100 (max) for iat, attack could be the whole envelope, with release = 0
ipanstart 		= p8    ; Start of Pan (0-1 = left to right)
ipanend   		= p9    ; End of Pan
ifilterwidth	= p10   ; Width of Notch Filter
irevsend  		= p11   ; Reverb Amount

; iwidth = 200

awhite unirand 2.0
awhite = awhite - 1.0


   
   kpan    linseg  ipanstart, idur, ipanend              ; panning 0.0-1.0 
                                                         ; right-left 
   k1      linen  ampdb(iamp), iat, idur, irel           ; envelope AR
;  asig    randi k1, sr                                  ; random signal
   asig    pinkish awhite, 1, 0, 0, 1
     a1      butterbp asig*k1, ifreq, ifilterwidth
;    a1      oscili k1, ifreq*0.5, 2    ; 1=sine 2=saw
   outs    a1 * kpan, a1 * (1 - kpan)
   garvbsig    =         garvbsig + a1 * irevsend/10   
endin

instr 99                 ; global reverb
     irvbtime    =         p4 
     asig        reverb    garvbsig,  irvbtime ; put global signal into reverb
     outs asig, asig 
     garvbsig    =    0              ; then clear it
endin 

         
