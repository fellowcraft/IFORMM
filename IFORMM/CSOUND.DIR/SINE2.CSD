<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
; Audio out   Audio in    No messages
; -odac           -iadc     -d     ;;;RT audio I/O
; For Non-realtime ouput leave only the line below:
; -o pinkish.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>

; ares pinkish xin [, imethod] [, inumbands] [, iseed] [, iskip]
; Initialize the global variables.
sr = 44100
kr =  4410
ksmps = 10
nchnls = 2


; Instrument #1.
instr 1
ifqc  = p4
iLFOd = p5
iLFOs = p6
iAmp  = p7


; kfreq linseg  istart, idur, iend


klfo oscil  iLFOd, iLFOs, 1

asine oscili ampdb(iAmp), ifqc*(1+klfo), 1  


klfo2 oscil  .5, klfo*100, 1

outs   asine*(klfo2+.5), asine*(.5-klfo2)

;out asine
  
endin

</CsInstruments>
<CsScore>
f1  0  2048  10  1

;      dur freq  depth speed dB
; i  1 0 60   8500     0.0  0.022  30      
 i  1 0 60    16400    0.0  0.033  90
;i  1 0 600 224     0.0  0.044  72     
; i  1 0 600 225     0.0  s  0.055  72
e
</CsScore>
</CsoundSynthesizer>

