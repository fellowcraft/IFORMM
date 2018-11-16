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
iPhase = p8

; kfreq linseg  istart, idur, iend

klfo oscil  iLFOd, iLFOs, 1

asine oscili ampdb(iAmp), ifqc*(1+klfo), 1, iPhase


klfo2 oscil  .5, klfo*100, 1

outs   asine*(klfo2+.5), asine*(.5-klfo2)


  
endin

</CsInstruments>
<CsScore>
f1  0  8192  10  1

#define PHASE(A) #[$A*0.016]#

;        dur  freq   de  sp dB  phase

i  1   0  30 16000   0   0  96  0
i  1   +  .      .   .   .  .   $PHASE(1)


i  1   +  .      .   .   .  .   $PHASE(2)


i  1   +  .      .   .   .  .   $PHASE(3)


i  1   +  .      .   .   .  .   $PHASE(4)


i  1   +  .      .   .   .  .   $PHASE(5)


i  1   +  .      .   .   .  .   $PHASE(6)


i  1   +  .      .   .   .  .   $PHASE(7)


i  1   +  .      .   .   .  .   $PHASE(8)


i  1   +  .      .   .   .  .   $PHASE(9)


i  1   +  .      .   .   .  .   $PHASE(10)


i  1   +  .      .   .   .  .   $PHASE(11)


i  1   +  .      .   .   .  .   $PHASE(12)


i  1   +  .      .   .   .  .   $PHASE(13)


i  1   +  .      .   .   .  .   $PHASE(14)


i  1   +  .      .   .   .  .   $PHASE(15)


i  1   +  .      .   .   .  .   $PHASE(16)


i  1   +  .      .   .   .  .   $PHASE(17)


i  1   +  .      .   .   .  .   $PHASE(18)


i  1   +  .      .   .   .  .   $PHASE(19)


i  1   +  .      .   .   .  .   $PHASE(20)


i  1   +  .      .   .   .  .   $PHASE(21)


i  1   +  .      .   .   .  .   $PHASE(22)


i  1   +  .      .   .   .  .   $PHASE(23)


i  1   +  .      .   .   .  .   $PHASE(24)


i  1   +  .      .   .   .  .   $PHASE(25)


i  1   +  .      .   .   .  .   $PHASE(26)


i  1   +  .      .   .   .  .   $PHASE(27)


i  1   +  .      .   .   .  .   $PHASE(28)


i  1   +  .      .   .   .  .   $PHASE(29)


i  1   +  .      .   .   .  .   $PHASE(30)


i  1   +  .      .   .   .  .   $PHASE(31)


i  1   +  .      .   .   .  .   $PHASE(32)


i  1   +  .      .   .   .  .   $PHASE(33)


i  1   +  .      .   .   .  .   $PHASE(34)


i  1   +  .      .   .   .  .   $PHASE(35)


i  1   +  .      .   .   .  .   $PHASE(36)


i  1   +  .      .   .   .  .   $PHASE(37)


i  1   +  .      .   .   .  .   $PHASE(38)


i  1   +  .      .   .   .  .   $PHASE(39)


i  1   +  .      .   .   .  .   $PHASE(40)


i  1   +  .      .   .   .  .   $PHASE(41)


i  1   +  .      .   .   .  .   $PHASE(42)


i  1   +  .      .   .   .  .   $PHASE(43)


i  1   +  .      .   .   .  .   $PHASE(44)


i  1   +  .      .   .   .  .   $PHASE(45)


i  1   +  .      .   .   .  .   $PHASE(46)


i  1   +  .      .   .   .  .   $PHASE(47)


i  1   +  .      .   .   .  .   $PHASE(48)


i  1   +  .      .   .   .  .   $PHASE(49)


i  1   +  .      .   .   .  .   $PHASE(50)


i  1   +  .      .   .   .  .   $PHASE(51)


i  1   +  .      .   .   .  .   $PHASE(52)


i  1   +  .      .   .   .  .   $PHASE(53)


i  1   +  .      .   .   .  .   $PHASE(54)


i  1   +  .      .   .   .  .   $PHASE(55)


i  1   +  .      .   .   .  .   $PHASE(56)


i  1   +  .      .   .   .  .   $PHASE(57)


i  1   +  .      .   .   .  .   $PHASE(58)


i  1   +  .      .   .   .  .   $PHASE(59)


i  1   +  .      .   .   .  .   $PHASE(60)



e
</CsScore>
</CsoundSynthesizer>

