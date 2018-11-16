; ************************************************************************
; synthesis: stochastic massiv parallel additive
; source:    Jeffrey Fredrickson & Fran Red (1997)
;


sr = 44100
kr  =  4410
ksmps= 10
nchnls = 2


instr 1
idur     = p3
iamp     = (p4-(p4/4))
ifreq    = p5
iat      = p6
irel     = p7
ipanstart = p8
ipanend = p9
 
   kpan    linseg  ipanstart, idur, ipanend              ; panning 0.0-1.0 
                                                         ; right-left 
   k1      linen  ampdb(iamp), iat, idur, irel           ; envelope
   a1      oscili (k1 > 32000 ? 32000 : k1), ifreq, 1    ; 1=sine 2=saw

   outs    a1 * kpan, a1 * (1 - kpan)
         
endin 


