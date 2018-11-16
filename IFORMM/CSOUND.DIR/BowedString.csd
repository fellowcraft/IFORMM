Bowed String Additive Synth
Jacob Joaquin
March 15, 2010
jacobjoaquin@gmail.com
csound.noisepages.com

<CsoundSynthesizer>
<CsInstruments>
sr = 44100
kr = 4410
ksmps = 10
nchnls = 2
0dbfs = 1.0

; Instruments
# define Synth # 1 #

; F-Tables
# define T_Sine # 1 #  ; Sine wave
# define T_Tri  # 2 #  ; Triangle wave

; F-tables
gitemp ftgen $T_Sine, 0, 2 ^ 16, 10, 1
gitemp ftgen $T_Tri, 0, 2 ^ 16, -7, -1, 2 ^ 15, 1, 2 ^ 15, -1

opcode Additive_Body, a, kkiiii
    kfreq,        \  ; Frequency
    kmod,         \  ; Frequency modulation
    in_harmonics, \  ; Number of harmonics
    ibody,        \  ; Additive body amplitude table
    ipch_table,   \  ; Additive body tuning table
    i_index       \  ; Index of current harmonic
    xin
    
    ; Frequency for this voice
    kthis_freq = kfreq * (i_index + 1)
    
    ; Apply tuning transfer function
    kcurve expcurve kthis_freq / 22050, 0.5
    kpch tablei kcurve, ipch_table, 1, 0, 0
    kthis_freq = kthis_freq * kpch
    
    ; Frequency modulation
    kthis_freq = kthis_freq + kthis_freq * kmod
    
    ; Amplitude transfer function
    kamp tablei kthis_freq / 22050, ibody, 1, 0, 0

    ; Generate this voice
    a1 oscil 1 / (i_index + 1) * kamp, kthis_freq, $T_Sine, 0

    ; Recursive oscillator
    a2 init 0

    if (i_index < in_harmonics - 1 && i(kthis_freq) < 16000) then
        a2 Additive_Body kfreq, kmod, in_harmonics, ibody, ipch_table, \
                         i_index + 1
    endif

    xout a1 + a2
endop

instr $Synth
    idur = p3          ; Duration
    iamp = p4          ; Amplitude
    ipch = cpspch(p5)  ; Pitch in octave point pitch-class
    ibody = p6         ; Additive body amplitude table
    ipch_table = p7    ; Additive body tuning table
    ipan = p8          ; Pan position
        
    ; Pitch vibrato
    k2 linsegr 0, 0.4, 0, 0.7, 1, 1, 1, 1, 0.3, 0.01, 1
    klfo oscil k2, 4.8 + rnd(0.4), $T_Tri
    krand randh rnd(0.9) + 0.1, 0.125 + rnd(0.25)
    kvibrato = (klfo + krand) * (0.003 +rnd(0.007))
    
    ; Pitch
    kpch linseg 2 ^ (-2 / 12), 0.1, 2 ^ (0 / 12), 0.001, 2 ^ (0 / 12)
    
    ; Generate audio
    a1 Additive_Body ipch, kvibrato + kpch, 32, ibody, ipch_table, 0
    
    ; Amp
    aenv linsegr 0, 0.205, 0.2, 0.1, 0.5, 2, 0.333, 0.2, 0
    asig = a1 * aenv * iamp
    outs asig * sqrt(1 - ipan), asig * sqrt(ipan)
endin

</CsInstruments>
<CsScore>

; Instruments
# define Synth # 1 #

t 0 30

; Transfer functions
f 100 0 16 -2 1 1 0 0 1 0 1 0 1 1 1 0 0 0 1 1
f 101 0 [2 ^ 11] 21 3 1
f 102 0 [2 ^ 11] 21 3 1
f 103 0 2 -2 1 1
f 200 0 16 -2 1 0.5 1 1 1 1 1 1 1 1 1.5 1 1 1 2 1
f 201 0 256 -7 1.059 256 1
f 202 0 16 -2 1 1 1.059 1 0.998 1 1 1 1.2 1 1 1 1 1 1 1
f 203 0 16 -2 1 0.999 1.059 1 0.998 1.059 1 0.98 1.2 1 1 1.1 0.98 1 1 1
f 204 0 16 -2 1 0.999 1.001 1 0.998 1.001 1 0.98 1.001 1 1 1 1 1 1 1

i $Synth 0 0.125 1    5.00 102 204 0.25
i $Synth + .     .    5.03 .   .   .
i $Synth + .     .    5.07 .   .   .
i $Synth + .     .    5.09 .   .   .
i $Synth + .     .    6.00 .   .   .
i $Synth + .     .    6.03 .   .   .
i $Synth + 1     0.86 6.07 .   .   .
i $Synth + .     .    6.09 .   .   .
i $Synth + .     .    7.00 .   .   .
i $Synth + .     .    7.03 .   .   .
i $Synth + .     .    7.07 .   .   .
i $Synth + .     .    7.09 .   .   .
i $Synth + .     .    8.00 .   .   .
i $Synth + .     .    8.03 .   .   .
i $Synth + .     .    8.07 .   .   .
i $Synth + .     .    8.09 .   .   .
i $Synth + .     .    9.00 .   .   .
i $Synth + 1.25  .    9.03 .   .   .
i $Synth + 2     .    9.07 .   .   .

i $Synth 0 3 0.75 7.00 101 202 0.75
i $Synth + 1 1    6.09 .   .   .
i $Synth + 3 .    7.00 .   .   .
i $Synth + 1 .    6.10 .   .   .
i $Synth + 3 .    6.09 .   .   .
i $Synth + 4 .    6.00 .   .   .

</CsScore>
</CsoundSynthesizer>

