\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ FUNC-KEY -- a version of SKEY that recognizes the 10 function keys
\ (and their shifted counterparts) and jumps through the ACTIVE-FK-table
\ to the appropriate FK-ACTION.

\ FK-table ( --- ; <name> )
 	\ defines a function key action table (all noops)
	\ the table becomes active invoking NAME
	\ or by explicitly ACTIVE-FK-table to its PFA

\ FK-action: ( n --- ; <name>)
	\ makes NAME the nth fk-action of the currently active table
	\ if NAME is not found it places a noop and issues a warning

\ FK-routine ( n --- ;  ) 
	\ a deferred word ---should take a function-key index off stack

\ fkey ( key-code ---- n ; )
	\ installed into OUR-SKEY to do function key stuff

loaded definitions create _func-key
only forth also definitions
system also

defer FK-routine 	\ process level word that handles function keys

quan active-FK-table		\ pointer to current table of FK actions

: FK-table 
 create 20 0 do ['] noop , loop
 does> to active-FK-table ;

FK-table default-FK-table		\ define the default table
default-FK-table 		\ make it active

: FK-action:	( n --- ; <string> set nth function-key-action )
 dup 0 19 between if
  blword
  find 
  if 
   swap 2 << active-FK-table + token!
  else 
   drop
   ." Unknown word defined as function key #" dup .
   ['] noop 
   swap 2 << active-FK-table + token!
  then 
 else
  cr . ." is out of range for a function key " cr
 then ; 

internals also definitions

: default-FK-routine
  2 << active-FK-table + @ execute ;

' default-FK-routine is FK-routine

: fkey	( --- key-code | 0; catches functions and arrows before skey)
 tty-in-struct wait-for-input
 tos-sema P				\ lock TOS
 2 bconin 				\ get a character
 tos-sema V				\ unlock TOS
 dup th 7f and 
 if					\ normal character?
  th 7f and
 else					\ no ---
  th 10 >> th 7f and			\ get upper word for decoding
  dup th 3b th 44 between	
  if					\ function key?
   th 3b - FK-routine
   0
  else
   dup th 54 th 5d between if		\ shifted function key?
    th 4a - FK-routine
    0
   else
    case				\ non-function key case
     th 48 of th 10 endof			\ up arrow
     th 4b of th  2 endof			\ left arrow
     th 4d of th  6 endof			\ right arrow 
     th 50 of th  e endof			\ down arrow
     th 61 of th 1d endof			\ 'undo'
     th 62 of th 1f endof			\ 'help'
     0 swap
    endcase
   then
  then
 then ;

: +tty
 0 0  tty-in-struct 2!
 1 iorec to kbd-buf-rec
 kbd-buf-rec 6 + w@ old-kbd-tail-ptr w!
 ['] fkey is our-skey
 tos-sema init-sema
 ['] shemit is (emit  
 ['] quick-key? is key?
 ['] ttyin-int-handler to key-handler ;
