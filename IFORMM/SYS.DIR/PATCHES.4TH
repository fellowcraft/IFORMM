\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ PATCHES - introduce some deferred words in tty I/O and decompilation,
\ for later redefinition by FORMULA.


loaded definitions create _patches
only forth also definitions hidden also


ifdef ATARI     \ ATARI-SPECIFIC PATCHES START HERE

: rel(patch	( token lit-val acf -- ; this sets the relocation bit )
 word-bounds search
 if token!
 else
  ." Couldn't find it. " drop
 then
;

\ *******Defer some I/O words for new features and preemptive scheduling*******

defer our-skey		\ makes function key handling possible
defer our-at 		\ required for preemptive scheduling
defer our-(esc 		\ required for preemptive scheduling

' skey is our-skey	\ it's skey for now

hidden  definitions

: (at  		( x y --- ; move cursor )
   2dup #out ! #line ! ascii Y ( 89 ) (esc swap bl + (emit bl + (emit ; 
' (at is our-at

: ((esc 	( char --- ; emit a short escape sequence )
 escape (emit (emit ;
' ((esc is our-(esc

\ The four following words will be patched in, they don't need to be deferred
: ((cursor-on	( --- ; corrected version uses encapsulated escape sequence )
 101 (esc ;

: ((cursor-off	( --- ; corrected version uses encapsulated escape sequence )
 102 (esc  ;

: ((lf		( --- ; corrected version updates #line after cursor moves )
 linefeed (emit 1 #line +! ;

: ((cr		( --- ; corrected version updates #out after cursor moves )
 carret (emit #out off ;

patch our-skey skey (newexpect
patch our-at 2dup at
patch unnest #out at
patch our-(esc escape (esc
patch unnest (emit (esc

patch ((cursor-on (lit) cursor-on		
' unnest 27 ' cursor-on rel(patch

patch ((cursor-off (lit) cursor-off
' unnest 27 ' cursor-off rel(patch

patch ((lf 1  (lf
patch unnest #line (lf

patch ((cr #out (cr
patch unnest off (cr

\ To do: BACKSPACES should be patched (however it isn't called by the system)
\ (MORE and ?END-OF-SCREEN also need work, this could be done by
\ simply redefining MORE and TAIL
\ ****************************************************************************
\ Defer words in disassembler to allow extensions to FORMULA features.

\ ATARI-SPECIFIC PATCHES END HERE
ifend

only forth also hidden also definitions

defer (]		\ allow non-standard literals
defer ([

defer (exec-class 	' execution-class is (exec-class
defer (.exec-class 	' .execution-class is (.exec-class
defer (do-scan  	' do-scan is (do-scan
defer (def-class 	' definition-class is (def-class
defer (.def-class 	' .definition-class is (.def-class

: (([   
   ['] (literal? ['] literal? (is ['] interpret-do-defined ['] do-defined 
   (is ['] interpret-do-literal ['] do-literal (is ['] interpret-do-undefined 
   ['] do-undefined (is state off ; immediate
' (([ is ([

: ((]   
   ['] (literal? ['] literal? (is ['] compile-do-defined ['] do-defined 
   (is ['] compile-do-literal ['] do-literal (is ['] compile-do-undefined 
   ['] do-undefined (is state on ;
' ((] is (]

patch ([ (') [	
patch unnest (literal? [

patch (] (') ]	
patch unnest (literal? ]

patch (exec-class execution-class scan-pfa
patch (exec-class execution-class .pfa
patch (.exec-class .execution-class .pfa
patch (do-scan do-scan scan-pfa
patch (def-class definition-class ((see
patch (.def-class .definition-class ((see

assembler also definitions decimal

: l#)
 dup origin dup max-image + within
 [ forth ]
 if
   amark
 then
 [ assembler ]
 lwsplit push push 57
;
