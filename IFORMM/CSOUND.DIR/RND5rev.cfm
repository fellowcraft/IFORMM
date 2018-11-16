<!--- \ Copyright (c) 1987-2008 by Frank H. Rothkamm.  Adopted from Forth in 2010. All rights reserved.

\  Stochastic Placement of Events
\  Produces Score for Csound
\  uniform distribution
\  1997/2010

\ ------------------------------------------------------------------------------

--->

<CFSETTING RequestTimeOut="#url.RequestTimeOut#">

<cfscript>

duration = 10;    
attack = 50;
release = 1;
start = 1;
db = 90;
alldb = 90;
scale = 1000;
start = 0;
filterWidth = 200;
revSend = 0.3;
revTime = 10;
</cfscript>

<!---

\ -----------------------positive Gauss-----------------------------------------
variable bigg 0 bigg !
variable xx   0 xx !
: grnd2   
   0 
   12 0 
   do    1200 irnd + 
   loop  
   7200 - 
   * 
   1200 / 
   abs
;  --->

<cfscript>

function grnd2(a,b) {

result = RandRange(a,b,"SHA1PRNG");
return result; 
}

</cfscript>



<!--- : display-grnd2 ( # -- )
 \  erase-screen
  0 bigg !
  0 xx !  
    640 0 ?do
     dup grnd2 
  loop
   drop
   20 0 at bigg @ .
;
\ ---------------------------------
\ ------------------------------------------------------------------------------



\ ----------------------envelope (attack&release)-------------------------------

: make2parts ( -- )  \  2 part envelope, what's not attack is release (decay)

mindur @ maxdur @ rndbetween dup 
100 * 10000 attack% @ irnd 1 max / / dup  
attack ! - release !
  
;   

: rnd-envelope ( -- )
  make2parts
  attack @ release @  + duration ! 
;

--->

<cfquery DATASOURCE="iformm" NAME="para">
select * 
from parameters
where ID = #ID#
</cfquery>


<cfif para.maxdur GE para.total>
<cfoutput>maxdur #para.maxdur# can not be larger than total #para.total#</cfoutput>
<cfabort>
</cfif>

<cfscript>
 
function RndEnvelope() { // 2 part envelope, what's not attack is release (decay)

duration = RandRange(para.mindur*scale,para.maxdur*scale,"SHA1PRNG");

attack = para.attack*duration/100;   // % of duration
attack = RandRange(1,attack,"SHA1PRNG");  
release  = duration - attack;

attack = attack / scale;
release = release / scale;
duration = duration / scale;
// 100 * 10000 attack% @ irnd 1 max / / dup  
// attack ! - release !
}  
 
function RndStart() {
start = RandRange(0,para.total*scale,"SHA1PRNG");  
start = start/scale;
} 


function GenerateEnvelope() { 

RndEnvelope();
RndStart();

while(start + duration GT para.total) { 
RndEnvelope();
RndStart();
}
  
} 
 

function RndFreq() {
freq  = RandRange(para.minfreq*scale,para.maxfreq*scale,"SHA1PRNG");
// range = para.maxfreq*scale - para.minfreq*scale;                   
freq  = freq - RandRange(0,freq-(para.minfreq*scale),"SHA1PRNG"); // scale down
freq  = freq / scale;
}


FreqLimit = 20000;
dbLimit   = 96;
FreqTodBRatio  =  FreqLimit / dbLimit;
 

function RndDb() {
db = RandRange(para.mindb*scale,para.maxdb*scale,"SHA1PRNG");

Ramp =  dbLimit*scale-db;

db = db + RandRange(0,freq*scale/FreqTodBRatio-Ramp,"SHA1PRNG"); // scale up


db = db / scale;
}

function RndPan() {
PanStart = RandRange(0,para.panStart,"SHA1PRNG")/100; 
PanEnd = RandRange(0,para.panEnd,"SHA1PRNG")/100;
}

function RndrevSend() {
revSend = RandRange(0,para.revSend,"SHA1PRNG")/100;
}

function RndfilterWidth() {
filterWidth = RandRange(0,para.filterwidth,"SHA1PRNG");
}

</cfscript>


<CFSAVECONTENT variable="score">; <pre>
<CFOUTPUT>
;  #para.events# events - total #para.total# seconds"
;  #NumberFormat(para.minfreq,".0")# - #NumberFormat(para.maxfreq,".0")# Hz     
;  #NumberFormat(para.mindb,".0")# - #NumberFormat(para.maxdb,".0")# dB

f1  0  4096  10  1
<!--- \ ." f1 0 8 2     0 0   1 1 1  -1 -0.5 -1" ---> 


; Reverb
; ins     strt dur                revTime                 
  i99     0    #Evaluate(para.total+para.revTime)# #para.revTime#

; Osc	start	dur	amp	freq	attack	rel	panS	panE 	filterwidth		revSend

<CFLOOP FROM="1" TO="#para.events#" INDEX="i">#GenerateEnvelope()##RndFreq()# 	#RndDb()##RndPan()#
i1 	#NumberFormat(start,".000")#	#NumberFormat(duration,".000")#	#NumberFormat(db,".0")#	#NumberFormat(freq,".0")#	#NumberFormat(attack,".000")#	#NumberFormat(release,".000")#	#PanStart#	#PanEnd#	#RndfilterWidth()# #filterWidth# #RndrevSend()# #NumberFormat(revSend,".0")#</CFLOOP>

e
; </pre>
</CFOUTPUT>
</CFSAVECONTENT>


<CFFILE action = "write" 
file = "#GetDirectoryFromPath(ExpandPath("*.*"))##para.name#[#trim(numberformat(para.id,'00'))#].sco" 
output = "#score#">

<CFOUTPUT>
<a href="#para.name#[#trim(numberformat(para.id,'00'))#].sco">#para.name#[#trim(numberformat(para.id,'00'))#].sco</a>
<br />
#score#
</CFOUTPUT> 