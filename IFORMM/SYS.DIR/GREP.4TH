\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.
\ Modified by HEX 
\ Copyright (c) 1988 by Marcus Verwiebe.  All rights reserved.

\ Search for files containing a particular string
\ 
\
\ GREP \ search-string filename-pattern ( -- )
\	like a UNIX "grep" without regular expressions
\
\ FSEARCH \ file-name-pattern ( search-string -- )
\ 	like above, but get the string from the stack
\
\ (FSEARCH ( -- )
\ 	search search-string input-file-descriptor IFD

only forth also system also hidden also 

forth definitions

create search-string td 256 allot
variable search-line
: (fsearch (  -- )
	1 search-line !
	begin
		exit? if ifd @ close abort then
		pad ifd @ fgetline ( adr true | false )
		search-line @ 1+ search-line !
	while
		dup search-string count rot count sindex ( str index )
		0>= if 
			search-line @ . 
			4 to-column ". cr 
		else
			drop
		then
	repeat

;
: fsearch \ file-pattern ( string -- )
	1 ?enough
	search-string "copy
	blword file-pattern
	begin another-file?
	while filename 
		dup [""] . count compare 0<> if
		dup [""] .. count compare 0<> if 
			dup ." File: " ". cr
			dup read open dup ifd !
			if (fsearch ifd @ close
			else ." Cannot open" cr
			then
		 then then   
		drop 
	repeat
;
: grep \ search-string file-pattern ( -- )
	blword fsearch
;


