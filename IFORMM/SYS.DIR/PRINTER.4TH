\ Bug in pclr, monochrome/color, and restore-output fixed on 11-4-86
\ Printer control.
\ 29MAR88 print filepattern with header -HEX
\ 
\ Defines a vocabulary called  printer  which contains:
\
\ (print)  ( char -- )	 Output a character to the printer
\ print			 Subsequent output goes to both printer and screen
\			 until the next Forth prompt
\ print-file filepattern Print the named files
\
\ Setting the printer parameters:   Execute the appropriate commands from
\ this list, then execute  set-printer   (or use the desk accessory)
\
\ dot-matrix   or   daisy-wheel
\ monochrome   or   color
\ atari        or   epson
\ draft        or   final
\ parallel     or   serial
\ form-feed    or   single-sheet

decimal
only forth also definitions
vocabulary printer  printer definitions

only forth also printer also definitions

33 xbios: setprt  { w.config -- w.old-config }

wvariable printer-config  0 printer-config w!

: set-printer ( -- )  printer-config w@ setprt drop ;

: pset ( mask -- )      printer-config w@ or printer-config w! ;
: pclr ( mask -- ) not  printer-config w@ and printer-config w! ;

hex
: dot-matrix  1 pclr ;   : daisy-wheel   1 pset ;
: monochrome  2 pclr ;   : color         2 pset ;
: atari       4 pclr ;   : epson         4 pset ;
: draft       8 pclr ;   : final         8 pset ;
: parallel   10 pclr ;   : serial       10 pset ;
: form-feed  20 pclr ;   : single-sheet 20 pset ;
decimal

5 bdos: c_prnout  { w.char -- }
alias (print) c_prnout

: premit ( char -- )  dup (print) sys-emit  ;

only forth printer also forth hidden also forth definitions
: default-output  ( -- )
   ['] sys-emit is (emit   old-status token@ is status
; 
: print ( -- )		\ turn printer on
   ['] status >data token@  old-status token!
   ['] default-output  is status
   ['] premit          is (emit
;
: (print-file  ( -- )
   begin ifd @ fgetc  dup 0>=
         key? 0=  and
   while  (print)
   repeat
   drop  ifd @ close
;
: print-header ( filename -- ) 
    print cr ." :: " ". ."  ::" cr cr default-output ; 
: print-file  \ filepattern  ( -- )
   blword file-pattern
   begin
      another-file? while
      filename dup print-header read-open (print-file 
      control l (print) \ Form Feed
   repeat
\   reading   (print-file
;
: nlq-on  ( -- )
   td 27 (print) ascii G (print)
;
: nlq-off  ( -- )
   td 27 (print) ascii H (print)
;

only forth also definitions
