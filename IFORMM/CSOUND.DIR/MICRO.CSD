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
kr = 44100
ksmps =  1
nchnls = 1


; Instrument #1.
instr 1

awhite unirand 2.0
awhite = awhite - 1.0  

;  apink  pinkish  awhite, 1, 0, 0, 1
;  apink  pinkish  30000, 0, 4, 0, 1
;  out apink

; kfreq linseg  istart, idur, iend

; asig  rand 30000

asig randi 15000, sr/2    ; 100,

; afilter butterbp asig, kfreq, iwidth

out asig
endin

</CsInstruments>
<CsScore>

;   st 
; i 1 0.0000018
i 1 0 0.0018
e
</CsScore>
</CsoundSynthesizer>
