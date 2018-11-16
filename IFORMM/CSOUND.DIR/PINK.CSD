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
nchnls = 1


; Instrument #1.
instr 1
idur   = p3
istart = p4
iend   = p5
iwidth = p6

awhite unirand 2.0
awhite = awhite - 1.0  

;  apink  pinkish  awhite, 1, 0, 0, 1
;   apink  pinkish  30000, 0, 4, 0, 1
; out apink

kfreq linseg  istart, idur, iend

; asig  rand 30000

asig randi 15000, sr    ; 100,

afilter butterbp asig, kfreq, iwidth

out afilter

  
endin


</CsInstruments>
<CsScore>

; Play Instrument #1 for one second.
i 1 0 300 1500  20 30
i 1 0 300 20  4000 30
i 1 0 300 300 1500 30
i 1 0 300 20  2500 30
e
</CsScore>
</CsoundSynthesizer>
