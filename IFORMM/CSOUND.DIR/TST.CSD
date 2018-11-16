<CsoundSynthesizer>





<CsOptions>



</CsOptions>





<CsInstruments>



sr = 44100

kr =  4410

ksmps = 10

nchnls = 1





 	instr  	1

inote 	cpsmidi 	 

iveloc 	ampmidi 	10000

aout 	oscil 	iveloc, inote, 1

  	out 	aout

  	endin 	 

</CsInstruments>





<CsScore>

f1  0  2048  10  1

f0 360

</CsScore>





</CsoundSynthesizer>



<bsbPanel>

 <label>Widgets</label>

 <objectName/>

 <x>1272</x>

 <y>49</y>

 <width>0</width>

 <height>0</height>

 <visible>true</visible>

 <uuid/>

 <bgcolor mode="nobackground">

  <r>0</r>

  <g>0</g>

  <b>0</b>

 </bgcolor>

</bsbPanel>

<bsbPresets>

</bsbPresets>

<MacGUI>

ioView nobackground {0, 0, 0}

</MacGUI>

