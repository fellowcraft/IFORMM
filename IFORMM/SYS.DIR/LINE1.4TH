\ Copyright (c) 1986 by Jesse Taylor. All rights reserved.
\ modified:
\ Copyright (c) 1987-2006 by Frank H. Rothkamm.  All rights reserved.

\ ( LINE1: The Primitives... ) Graphics Interface

decimal

variable a-vars
\ Create a name which will return the address stored in a-vars plus an offset
: afield:  ( offset -- )
   create ,
\ does> @ a-vars @ +
   ;code
   sp )+       a0 lmove
   a0 )        a0 lmove    
   a-vars l#)  a0 adda
   a0       sp -) lmove
c;

\ These fields reflect the offsets into the table pointed to by A0 when the
\ line A graphics are first initialized.

-22 afield: _def_font 
  0 afield: v_planes
  2 afield: v_lin_wr
  4 afield: contrl
  8 afield: intin
 12 afield: ptsin
 16 afield: intout 
 20 afield: ptsout
 24 afield: _fg_bp_1	
 26 afield: _fg_bp_2
 28 afield: _fg_bp_3
 30 afield: _fg_bp_4
 32 afield: _lstlin
 34 afield: _ln_mask
 36 afield: _wrt_mod
 38 afield: _x1
 40 afield: _y1
 42 afield: _x2
 44 afield: _y2
 46 afield: _patptr
 50 afield: _patmsk
 52 afield: _multifill
 54 afield: _clip
 56 afield: _xmn_clip
 58 afield: _ymn_clip
 60 afield: _xmx_clip
 62 afield: _ymx_clip 
 64 afield: _xacc_dda
 66 afield: _dda_inc
 68 afield: _t_sclsts  		
 70 afield: _mono_status
 72 afield: _sourcex
 74 afield: _sourcey
 76 afield: _destx
 78 afield: _desty
 80 afield: _delx
 82 afield: _dely 
 84 afield: _fbase
 86 afield: _fwidth
 90 afield: _style
 92 afield: _litemask
 94 afield: _skewmask
 96 afield: _weight
 98 afield: _r_off
100 afield: _l_off
102 afield: _scale
104 afield: _chup
106 afield: _text_fg
108 afield: _scrtchp
112 afield: _scrpt2
114 afield: _text_bg
116 afield: _copytran





\ these are the regular program variables

decimal
\ this is a table containing the three resolution modes on the st
 create rez-table   320 w, 200 w,  640 w, 200 w,  640 w, 400 w,

hex
: get-rez  ( -- x y )  \ return current screen resolution
   getrez  4 *  rez-table + dup w@ swap 2+ w@ 
;
code init-a  ( -- addr )  \ line A graphics init routine
   a000 w,
   a0   a-vars l#)  lmove
c;
code textblt    ( --  )   a008 w,  c;                   \ text
code put-pix    ( -- )    a001 w,  c;			\ set pixel
code get-pix    ( -- n )  a002 w, d0 sp -) lmove  c;	\ get pixel
code do-line    ( -- )    a003 w,  c;			\ line
code h-line     ( -- )    a004 w,  c;			\ horizontal line
code fill-rec   ( -- )    a005 w,  c;			\ filled rectangle
code fill-poly  ( -- )    a006 w,  c;			\ filled polygon
\ code show-mouse ( -- )    a009 w,  c;			\ show mouse
\ code hide-mouse ( -- )    a00a w,  c;			\ hide mouse
\ code transform-mouse  ( -- )  a00b w,  c;       	\ transform mouse cursor
code copy-raster ( -- ) a00e w,  c;			\ raster copy
decimal  
\ Draw sprite (a00d) and undraw sprite (a00c) are missing


