# IFORMM
Intelligent FORMula Music + + = if

<pre>
Atari STE EMulator (STEEM) 
|
Forthmacs
|
Forth Musical Language (ForMUaLA)
|
Intelligent FORMula Music (IFORMM)
</pre>
then

Setup
-----
Linux (ARCH):
<br>
install: wine lib32-alsa-plugins lib32-libpulse lib32-openal lib32-mpg123
<br>
run: wine Steem.exe
<br>
Under Options: select Port > MIDI-port > <your interface> or MIDI-Through-0
<br>
Under Disk Manager: select <path to IFORMM dir>IFORMM/IFORMM

RUN
---
Start STEEM
<br>
Double Click IFORMM
<br>
type: IFORMM

---
frank at rothkamm dot com

<pre>
-------------------------------------------------------------------------------
MAKE.4TH
-------------------------------------------------------------------------------
\ ===============
\ rothkamm IFORMM 
\ ===============
\ ===== (c) =====
\ Bob Moore 
\ Mitch Bradley 
\ David Anderson
\ Ron Kuivila
\ Frank Rothkamm
\ Marcus Verwiebe
\ Daniel Scheidt
\ Jesse Taylor

\ ------------------------------------------------------------------------------
\ ------ setup iformm ---------------------------------------------------------
\ ------------------------------------------------------------------------------

decimal

only forth also definitions


ifndef loaded
vocabulary loaded
: lneeds	( load-flag file-name ; --- ; )
 bl word				\ Get load flag from input
 ['] loaded >body >user vfind	\ See if flag word is in loaded voc
 nip bl word dup ". bl emit ?cr	\ Get file name and echo it
 swap 0<> if
  drop			\ Flag defined, don't need to load file
 else
  "load			\ Flag isn't defined, load file
 then
 key?				\ Check for key to cancel
 abort" Action aborted"		\ If pressed then abort
;
ifend

create ATARI
create _GROUP_			\ process groups?
create _AUX_			\ auxiliary processes (slots)?
create _FAQ_			\ future action queue?
create _RATIONAL_		\ support rational time specification?
create _PTCHNAME_		\ symbolic pitch names?
create _DOLLAR_		    \ dollar words?
create _MIDI_			\ MIDI input and output?

\ ------------------------- LOAD SYS -------------------------------------------
cd SYS.DIR
\ ==============================================================================

\ xload memory
xload patches.4TH
xload features.4TH
xload lbranch.4TH
xload while.4TH
xload pquan.4TH
xload decls.4TH
xload machine.4TH
xload panic.4TH
xload malloc.4TH
xload proc-cb.4TH
xload stack.4TH
xload process.4TH
xload queue.4TH
xload tempo.4TH
xload execute.4TH
xload wakeup.4TH
xload schedint.4TH
xload rt-sched.4TH
xload event.4TH
xload gp-sched.4TH
xload gp-creat.4TH
xload procuser.4TH
xload jobcntrl.4TH
xload define.4TH
xload faq.4TH
xload fevent.4TH
xload handler.4TH
xload midi-in.4TH
xload midiout1.4TH
xload midiout2.4TH
xload 6850-int.4TH
xload midi-hnd.4TH
xload semaphor.4TH
xload tty-out.4TH
xload tty-in.4TH
xload func-key.4TH
xload mouse.4TH
xload rational.4TH
xload fraction.4TH +fraction
xload aux2.4TH
xload sg.4TH
xload shape.4TH
xload td.4TH
xload ptchname.4TH
xload dollar.4TH
xload dlr-midi.4TH
xload notation.4TH
xload decomp.4TH
xload random.4TH
xload formula.4TH
xload initdef.4TH

only forth also definitions
decimal

\ ==============================================================================
\  F L U X  extension for F O R M U L A  4 . 0
\ (c) rothkamm 88/18
\ ==============================================================================


xload adds2.4TH               \  shorties
xload grep.4TH                \  grep <word> <file>  i.e: grep dada *.*
xload newpromp.4TH            \  show path
xload printer.4TH             \  if you have one
xload random2.4TH             \  rnd, rnd-shuffle
xload table.4TH               \  arrays
xload primes.4TH              \  table of first 80 prime numbers
xload modem2.4TH              \  Modem Interface (for the Drumulator)
xload fb01.4TH                \  Yamaha fb01 sys-x
xload tx81z.4TH               \  Yamaha tx81z
xload tx7.4TH                 \  Yamaha DX7 & TX7
xload tg33.4TH                \  Yamaha TG33
xload k5.4TH                  \  Kawai K5 & K5M
xload ajuno1.4TH			  \  Roland Alpho Juno 1
xload u$.4TH                  \  fb01 micro$ (1/64 of a semitone)
xload split.4TH               \  split-screen
\ --------------------- graphics -----------------------------------------------
xload seepic.4TH              \  screen file i/o
xload line1.4TH               \ highlevel graphic
xload line2.4TH
xload line3.4TH
xload vmouse.4TH              \  visible mouse routines
xload gui.4TH                 \  graphic user interface
\ --------------------- midi thru ----------------------------------------------
xload MS20.4TH                \  MS20 input controller
xload midithru.4TH            \  input-handlers - midi transform
\ ---------------------- LOAD PRG ----------------------------------------------
cd ..
cd PRG.DIR
\ ==============================================================================
xload ym.4TH                  \  YM2149 sound chip synthesizer
\ ------------------ interactive programms -------------------------------------
xload stock.4TH               \  stock market & butterfly
xload paint.4TH
xload fish.4TH
xload mirrors.4TH
xload lines.4TH
xload buterfly.4TH
xload grid.4TH                \  grid
xload paintmus.4TH            \  paintmusic
xload iboard.4TH              \  sliders iboard IFORMM
xload acid2.4TH               \  pattern generator
xload digits.4TH              \  1 Million Random Digits (RAND corporation book)
xload logo.4TH                \  midi picture line-graphics-animation
\ ------------------------------------------------------------------------------
xload fb01.4TH                \  input-handlers - midi transform
xload k5.4TH
xload electrib.4TH            \  input-transform of RPN messages from Korg ER-1
\ xload irnd.4TH                \  Csound score generator
xload sinewave.4TH            \  direct synthesis
xload tx7.4TH
xload tg33.4TH
xload ajuno1.4th

only forth also internals also modem also forth definitions

: copyright-notice
." IFORMM --------------------" cr
." rothkamm [1988-2018] iformm" cr
." IFORMM --------------------" cr
;



\ ' fb01 is midithru


: iformm
    formula
    LINE
    midithru
  \ reverse-screen
    cursor-blink-off

    pure-random-setup   \ for iboard

\ ----------------------
    mouse-off
    logo                 \ do test animation + rnd MIDI until key
    erase-screen
    copyright-notice
    320 to mouse-x       \ put mouse in the middle of the screen
    200 to mouse-y
    mouse-on             \ let the default mouse show
;

.( loading of source files completed. ) cr
.( ---------------------------------- ) cr
.( building and saving IFORMM.TOS... ) cr

cd ..


\ ---- compile SYStem ----------------------------------------------------------

"" forth.tos splice-relocation


\ ---- save SYStem -------------------------------------------------------------

"" iformm.tos save-rel
</pre>
