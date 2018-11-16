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
 
scale = 1000;  

mindur =  0.001;
maxdur =  3;

duration = RandRange(mindur*scale,maxdur*scale,"SHA1PRNG");

attack = para.attack*duration/100;   // % of duration

release = 0;

// write.output(release);

// while(release LTE 0) {
attack = RandRange(1,attack,"SHA1PRNG");  
release  = duration - attack;
// write.output(release);
// }

attack = attack / scale;
release = release / scale;
duration = duration / scale;

writeoutput(duration & '<br>' & attack & '<br>' & release);


</cfscript>
