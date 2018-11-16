\ Copyright (c) 1986 by David Anderson and Ron Kuivila.  All rights reserved.

\ DOLLAR -- note-playing primitives

loaded definitions create _dollar
only forth also definitions
internals also ap-defs also
decimal

quan $gtranspose	\ global transposition
pquan $transpose	\ local transposition
pquan $volume		\ local volume offset
pquan $channel		\ DMO: MIDI channel#; SM: virtual channel#

defer $do-note  ( pitch vol dur --- ; )
	\ pitch: low byte is semitones (60 == middle C)
	\        next lowest byte is 1/256's of semitone
	\ vol: scale is -128 to 127
defer $do-pedal  ( flag --- ; true for down, false for up )
defer $change-patch  ( patch --- ; change patch )

\ : no-SM
\ ." Not using Synthesizer Manager.  Default MIDI channel is 0." cr
\ ;

defer init-SM	  \ set up SM if needed; called at startup

\ : init-$
\ 0 to $gtranspose
\ 0 to $transpose
\ 0 to $volume
\ 0 to $channel
\ ;

: init-$
 0 to $gtranspose
 0 to $transpose
 0 to $volume
 0 to $channel
\ 0 to $patch
\ 0 to $location
\ 0 to $priority
\ 0 to $pedal 
 1000 usec-per-SVT 			\ MLADEN added usec-per-SVT 
 120 beats-per-minute 			\ MLADEN added usec-per-SVT 
;

: inst		( patch vol-off integer-transpose )
 8<< to $transpose
 to $volume
 $change-patch ;

internals definitions

pquan needparams	\ whether note parameters have been computed for now
pquan vol pquan dur pquan rel	\ some temps

ap-defs definitions

pquan $cvolume		\ volume offset for chord notes

internals definitions

: getparams		( --- ; obtain note parameters )
 needparams if
  false to needparams

\ compute volume
  $volume
  local-ptr paddr sh1cb sh-value if + then
  local-ptr paddr sh2cb sh-value if + then
  local-ptr global-ptr <> if
   global-ptr paddr sh1cb sh-value if + then
   global-ptr paddr sh2cb sh-value if + then
  then
  to vol
  
\ timing
  addr tsgcb sg-value 0= if 1 4 r>i then
  to dur
  
\ release time
  local-ptr paddr ashcb sh-value if
   local-ptr pget ashcb pget value2 
   case
    0 of dur ul* 8>> endof		\ ratio
    1 of dur swap + 1 max endof		\ relative
(   2 of endof )			\ absolute
   endcase
  else dur
  then
  to rel
 then ;

forth definitions

: $		( pitch --- ; play a note )
 getparams
 ?dup if
  vol rel $do-note
 then
 dur time-advance
 true to needparams ;

ap-defs definitions

: rest		( --- ; schedule a rest )
 addr tsgcb sg-value
 0= if 1 4 r>i then
 time-advance
 true to needparams ;

: z$		( pitch --- ; play a zero-duration note )
 ?dup if
  getparams vol rel
  $do-note
 then ;

: c$		( pitch --- ; play a softer zero-duration note )
 ?dup if
  getparams vol $cvolume + rel
  $do-note
 then ;

: r$		( pitch rel ; play note with specific release time )
 over if
  getparams vol
  $do-note
 else 2drop
 then ;

: fa$		( pitch delay --- ; future note, use future parameters )
 >r 1 ['] z$ r> future-routine ;

: fe$		( pitch delay --- ; future note, use present parameters )
 over if		\ ignore rests
  >r 			\ rs: delay
  getparams
  vol rel 3		\ sp: pitch vol dur nargs
  ['] $do-note r> future-routine
 else
  2drop
 then ;

: fer$	( pitch delay --- ; future note, use present parameters )
\ in addition, make the release time be the same as if the note were played now.
\ If less than delay, don't play note at all.  Used for $nroll
 over if		\ ignore rests
  >r getparams
  vol rel r@ -		\ compute actual release time (current - delay)
  dup 0>= if		\ if < 0, ignore
   3 ['] $do-note r> future-routine
  else
   2drop r> 2drop	\ drop rel, vol, delay, pitch
  then
 else
  2drop
 then ;

: ferc$		( pitch delay --- ; future chord note, use present parameters )
\ like $fer, make the release time line up with notes played now.
 over if
  >r getparams
  vol $cvolume + rel r@ -
  dup 0>= if
   3 ['] $do-note r> future-routine
  else
   2drop r> 2drop
  then
 else
  2drop
 then ;

: $*k		( pitch k --- ; play note k times )
 0 do
  dup $
 loop
 drop ;

: $n		( group n --- ; play an n-note chord )
 swap >r
 1- 0 do
  c$
 loop
 r> $ ;

: ($n		( same, but upside down )
 1- 0 do c$ loop $ ;

: $nroll	( group n dt --- ; play chord rolled over time dt )
 >r
 reverse
 r> swap		\ dt n on stack now
 dup 1- 0 do
  i -rot		\ i dt n
  dup >r over >r	\ n dt on return stack
  rot swap		\ dt i n
  1- */ ferc$
  r> r>
 loop
 drop fer$
 dur time-advance
 true to needparams ;

: m$		( list m --- ; play m single notes )
 reverse
 0 do
  $
 loop ;

: m$n		( group ... group m n --- ; play chord sequence )
 2dup >r >r
 * reverse drop
 r> r> swap 0 do
  >r r@ ($n r>
 loop
 drop ;

: $n*k		( group n k --- ; play a chord k times )
 1- 0 do
  ndup $n
 loop $n ;

: m$*k		( list m k --- ; play a sequence k times )
 1- 0 do
  ndup m$
 loop m$ ;

: m$n*k		( not worth explaining )
 >r 2dup * 2+ r>
 1- 0 do
  ndup drop m$n
 loop
 drop m$n ;

: $$	( pitch --- ; play a note plus 1 octave down )
 dup if
  dup 12 - c$
 then
 $ ;

: m$$	( list m --- ; play sequence in octaves )
 reverse
 0 do
  $$
 loop ;

: m$$*k ( list m k --- ; play sequence in octaves , k times )
 1- 0
 do ndup m$$
 loop m$$ ;

: pedon$
 true $do-pedal
 addr tsgcb sg-value
 0= if 1 4 r>i then
 time-advance ;

: pedoff$
 false $do-pedal
 addr tsgcb sg-value
 0= if 1 4 r>i then
 time-advance ;

: ped$
 false $do-pedal pedon$ ;

: pedon
 true $do-pedal ;

: ped
 false $do-pedal
 true $do-pedal ;

forth definitions

: pedoff
 false $do-pedal ;
