<CsoundSynthesizer>
<CsOptions>



</CsOptions>
<CsInstruments>



; ares pinkish xin [, imethod] [, inumbands] [, iseed] [, iskip]



; Initialize the global variables.

sr = 48000
kr =  4800
ksmps = 10
nchnls = 1





; Instrument #1.

instr 1
idur   = p3
istart = p4
iend   = p5
iwidth = p6
iamp =   ampdb(p7)

awhite unirand 2.0
awhite = awhite - 1.0  

apink  pinkish  awhite, 1, 0, 0, 1


; apink  pinkish  30000, 0, 4, 0, 1
; out apink


kfreq linseg  istart, idur, iend

; asig  rand 30000



; asig randi ampdb(p7), sr 

afilter butterbp apink*iamp, kfreq, iwidth

out afilter

endin

</CsInstruments>

<CsScore>



;     st dur 	freq 	freq 	width 	amp

  i 1 0  6000  	200  	200		6800  	50 

; i 1 0 6000  8400 8400 200   40

; i 1 0 300 1000 4000 60

; i 1 0 300 4000 1000 60


e

</CsScore>
</CsoundSynthesizer>

