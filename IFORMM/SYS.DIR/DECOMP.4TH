\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ DECOMP - decompilation

loaded definitions create _decomp
only forth also
internals also hidden also definitions
decimal

: new-.inline
 ta1+ dup @ . na1+ ;

: .;;ap
 -indent .." ;;ap" cr indent ta1+ ;

: scan-::ap
 ta1+ na1+	\ skip (::ap, nargs
 dup @ 4 - ['] .;;ap add-break
 dup @ +extent
 na1+ 6 + ;	\ skip branch addr, pseudo-CFA

: .::ap
 +indent .." ::ap "
 ta1+		\ skip the (::ap
 dup @ ?dup if .." [ " . .." params ] " then
 cr indent
 ta1+		\ skip nargs
 na1+		\ skip branch address
 6 + ;		\ skip the jsr ::ap-docol

: .;;gp
 -indent .." ;;gp" cr indent ta1+ ;

: scan-::gp
 ta1+ na1+	\ skip (::gp, nargs
 dup @ 4 - ['] .;;gp add-break
 dup @ +extent
 na1+ 6 + ;	\ skip branch addr, pseudo-CFA

: .::gp
 +indent .." ::gp "
 ta1+		\ skip the (::gp
 dup @ ?dup if .." [ " . .." params ] " then
 cr indent
 ta1+		\ skip nargs
 na1+		\ skip branch address
 6 + ;		\ skip the jsr ::ap-docol

: .;;ev
 -indent .." ;;ev" cr indent ta1+ ;

: scan-::ev
 ta1+ na1+	\ skip (::ev, nargs
 dup @ 4 - ['] .;;ev add-break
 dup @ +extent
 na1+ ev-hdr-len +	\ skip branch address, event routine header
;

: .::ev
 +indent .." ::ev "
 ta1+		\ skip the (::ev
 dup @ ?dup if .." [ " . .." params ] " then
 cr indent
 ta1+		\ skip nargs
 na1+		\ skip branch address
 ev-hdr-len + ;		\ skip the event routine header

\ ifdef _AUX_

: .;;tsg
 -indent .." ;;sg" cr indent ta1+ ;

: scan-::tsg
 ta1+ na1+	\ skip (::tsg, nargs
 dup @ 4 - ['] .;;tsg add-break
 dup @ +extent
 na1+ 6 + ;	\ skip branch addr, pseudo-CFA

: .::tsg
 +indent .." ::tsg "
 ta1+		\ skip the (::tsg
 dup @ ?dup if .." [ " . .." params ] " then
 cr indent
 ta1+		\ skip nargs
 na1+		\ skip branch address
 6 + ;		\ skip the jsr (::-docol

: .;;td
 -indent .." ;;td" cr indent ta1+ ;

: .;;sh
 -indent .." ;;sh" cr indent ta1+ ;

: scan-::td
 ta1+ na1+		\ skip ((::td, nargs
 dup @ 4 - ['] .;;td add-break
 dup @ +extent
 na1+ 10 + ta1+ ;	\ skip branch addr, code, pseudo-CFA, and td-init

: scan-::sh
 ta1+ na1+		\ skip ((::td, nargs
 dup @ 4 - ['] .;;sh add-break
 dup @ +extent
 na1+ 10 + ;		\ skip branch addr, code, and pseudo-CFA

: .::td
 +indent
 dup 12 + @ case
  ['] td1-setup of .." ::td1 " endof
  ['] td2-setup of .." ::td2 " endof
  ['] gtd1-setup of .." ::gtd1 " endof
  ['] gtd2-setup of .." ::gtd2 " endof
 endcase
 ta1+		\ skip the ((::td
 dup @ ?dup if .." [ " . .." params ] " then
 cr indent
 ta1+		\ skip nargs
 na1+		\ skip branch address
 10 +		\ skip the code and the jsr (::-docol
 ta1+ ;		\ skip td-init

: .::sh
 +indent
 dup 12 + @ case
  ['] sh1-setup of .." ::sh1 " endof
  ['] sh2-setup of .." ::sh2 " endof
  ['] gsh1-setup of .." ::gsh1 " endof
  ['] gsh2-setup of .." ::gsh2 " endof
  ['] ash-setup of .." ::ash " endof
 endcase
 ta1+		\ skip the ((::sh
 dup @ ?dup if .." [ " . .." params ] " then
 cr indent
 ta1+		\ skip nargs
 na1+		\ skip branch address
 10 + ;		\ skip the code and the jsr (::-docol

\ otherwise

\ create ((::td
\ create ((::sh
\ create (::tsg
\ create .::td
\ create .::sh
\ create .::tsg
\ create scan-::td
\ create scan-::sh
\ create scan-::tsg

\ ifend

: find-pq	( offset --- cfa ; find pquan based on offset. )
 >r
 pquanlist
 begin
  dup /n - @ r@ <>	\ look for same offset
 while
  @			\ error checking?  not here, bozon.
 repeat
 r> drop
 /n - body> ;		\ skip back over link, then code field.

: .ito
 .." to " ta1+ dup @ find-pq .name na1+ ;

: .pto
 .." pto " ta1+ dup @ find-pq .name na1+ ;

: .to
 .." to " ta1+ dup @ body> .name na1+ ;

: .pget
 .." pget " ta1+ dup @ find-pq .name na1+ ;

: .adr
 .." addr " ta1+ dup @ body> .name na1+ ;

: .iadr
 .." addr " ta1+ dup @ find-pq .name na1+ ;

: .padr
 .." paddr " ta1+ dup @ find-pq .name na1+ ;

: .poffset
 .." poffset " ta1+ dup @ find-pq .name na1+ ;

\ Classify each word in a definition
36 tassociative: ((exec-class
( 0 ) [compile] (lit)		( 1 ) [compile] ?branch
( 2 ) [compile] branch		( 3 ) [compile] (loop)
( 4 ) [compile] (+loop)		( 5 ) [compile] (do)
( 6 ) [compile] compile		( 7 ) [compile] (.")
( 8 ) [compile] (abort")	( 9 ) [compile] (;code)
( 10 ) [compile] unnest		( 11 ) [compile] (")
( 12 ) [compile] (?do)		( 13 ) [compile] (;uses)
( 14 ) [compile] exit		( 15 ) [compile] (llit)
( 16 ) [compile] (')		( 17 ) [compile] (of)
( 18 ) [compile] (endof)	( 19 ) [compile] (endcase)
( 20 ) [compile] ("s)		( 21 ) [compile] (to
( 22 ) [compile] (ito		( 23 ) [compile] (pto
( 24 ) [compile] (pget		( 25 ) [compile] (::ev
( 26 ) [compile] (::ap		( 27 ) [compile] ((::td
( 28 ) [compile] ((::sh		( 29 ) [compile] (iadr
( 30 ) [compile] (adr		( 31 ) [compile] (paddr
( 32 ) [compile] (poffset	( 33 ) [compile] (::tsg
( 34 ) [compile] (pn")		( 35 ) [compile] (::gp

\ Actions for special words to use during the decompiler output phase
37 case: ((.exec-class
( 0 )	new-.inline	( 1 )	.?branch
( 2 )	.branch		( 3 )	.loop
( 4 )	.+loop		( 6 )	.do
( 6 )	.quote		( 7 )	.string
( 8 )	.string		( 9 )	.(;code) 
( 10 )	.unnest		( 11 )	.string
( 12 )	.?do		( 13 )	.finish
( 14 )	.unnest		( 15 )	.llit
( 16 )	.[']		( 17 )	.of
( 18 )	.endof		( 19 )	.endcase
( 20 )	.string		( 21 )	.to
( 22 )	.ito		( 23 )	.pto
( 24 )	.pget		( 25 )	.::ev
( 26 )	.::ap		( 27 )	.::td
( 28 )	.::sh		( 29 )	.iadr
( 30 )	.adr		( 31 )	.padr
( 32 )	.poffset	( 33 )	.::tsg
( 34 )	.string		( 35 )	.::gp
( default ) .word
;

\ Actions for special words to use while scanning for control structures
37 case: ((do-scan
( 0 )	skip-inline	( 1 )	scan-branch
( 2 )	scan-branch	( 3 )	+branch
( 4 )	+branch		( 5 )	+branch
( 6 )	skip-quote	( 7 )	skip-string
( 8 )	skip-string	( 9 )	scan-(;code)
( 10 )	scan-unnest	( 11 )	skip-string
( 12 )	+branch		( 13 )	scan-unnest
( 14 )	scan-unnest	( 15 )	skip-llit
( 16 )	skip-[']	( 17 )	+branch
( 18 )	+branch		( 19 )	skip-word
( 20 )	skip-string	( 21 )	skip-inline
( 22 )	skip-inline	( 23 )	skip-inline
( 24 )	skip-inline	( 25 )	scan-::ev
( 26 )	scan-::ap	( 27 )	scan-::td
( 28 )	scan-::sh	( 29 )	skip-inline
( 30 )	skip-inline	( 31 )	skip-inline
( 32 )	skip-inline	( 33 )	scan-::tsg
( 34 )	skip-string	( 35 )	scan-::gp
( default ) skip-word
;

: .quan
 dup >body . .." quan " dup .name
 .." value = " >body ? ;

: .pquan
 dup  .." pquan " dup .name
 .." offset = " >body ? ;


\ Classify a word according to who defined it
8 tassociative: ((def-class
( 0 )	[compile] :		( 1 )	[compile] constant
( 2 )	[compile] variable	( 3 )	[compile] user
( 4 )	[compile] defer		( 5 )	[compile] alias
( 6 )	[compile] quan		( 7 )	[compile] pquan

\ Actions for decompiling words created by various different defining words
9 case: ((.def-class
( 0 )	.:		( 1 )	.constant
( 2 )	.variable	( 3 )	.user-variable
( 4 )	.defer		( 5 )	.alias
( 6 )	.quan		( 7 )	.pquan
( default )   .other
;

' ((exec-class is (exec-class
' ((.exec-class is (.exec-class
' ((do-scan is (do-scan
' ((def-class is (def-class
' ((.def-class is (.def-class
