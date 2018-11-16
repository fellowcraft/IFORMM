\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.
               
only forth also ap-defs also internals also forth definitions


hex

 \ ------------------   systemexclusive  ----------------------------------
 \ ------------- parameter change by midi-channel ( p. 133 ---------------
pquan gruppen
pquan paran
pquan datis
: setpara  ( p v -- )  \ setzt tx81z para voice data change -----------
     to datis  to paran to gruppen
   f7 datis paran gruppen 10 para-channel or  43 f0 
            7 ['] MIDI-command-event event ;
\ end       addr       data     offs pa            status      n+1# 
\ ------------------------------------------------------------------------

decimal

: tar  ( o w -- )
  18 rot 13 * rot setpara
;
: td1r  ( o w -- )
  18 rot 13 * 1 + rot setpara
;
: td2r   
  18 rot 13 * 2 + rot setpara
;
: trr 
  18 rot 13 * 3 + rot setpara
; 
: td1l 
  18 rot 13 * 4 + rot setpara
;
: tlesc 
  18 rot 13 * 5 + rot setpara
;

: trs 
  18 rot 13 * 6 + rot setpara
; 
: tebs
  18 rot 13 * 7 + rot setpara
; 
: tame 
  18 rot 13 * 8 + rot setpara
;
: tkvs 
  18 rot 13 * 9 + rot setpara
;
: tout 
  18 rot 13 * 10 + rot setpara
;
: tcrs 
  18 rot 13 * 11 + rot setpara
;
: tdet 
  18 rot 13 * 12 + rot setpara
; 
: talg  ( w -- )
  18 52 rot setpara
;  
: tfb 
  18 53 rot setpara
; 
: tlfos
  18 54 rot setpara
;
: tlfod
  18 55 rot setpara
;
: tpmd 
  18 56 rot setpara
; 
: tamd
  18 57 rot setpara
;
: tsync
  18 58 rot setpara
;
: twave
  18 59 rot setpara
;
: tpms 
  18 60 rot setpara
;
: tams 
  18 61 rot setpara
;
: tsus
  18 68 rot setpara
;
: tcho
  18 70 rot setpara
;
: tfix 
  19 rot 5 *  rot setpara
;
: tfixr
  19 rot 5 * 1 + rot setpara
;
: tfin 
  19 rot 5 * 2 + rot setpara
; 
: tosw
  19 rot 5 * 3 + rot setpara
;
: tshft
  19 rot 5 * 3 + rot setpara
;
: trev
  19 20 rot setpara
;
:  thi 
."                              TX81Z " cr 
."                      OPERATOREN  0 - 3  : " cr
." tar(0-31) td1r(0-31) td2r(0-31) trr(1-15) td1l(0-15) tlesc(0-99) " cr
." trs(0-3)  tebs(0-7)  tame(0-1)  tkvs(0-7) tout(0-99) tcrs(0-63)  "
cr
." tfix(0-1) trfixr(0-7)tfin(0-15) tosw(0-7) tshft(0-3) tdet(0-7) "
cr
." ------------------------------------------------------------------------- "
cr
." talg(0-7) tfb(0-7) tlfos(0-99) tlfod(0-99) tpmd(0-99) tamd(0-99) tsync(0-1) "
cr
." twave(0-3)tpms(0-7)tams(0-3)   tsus(0-1)   tcho(0-1)  trev(0-7)  " ;

