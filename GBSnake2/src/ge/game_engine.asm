INCLUDE "constants.inc"

SECTION "Game Variables", WRAM0
JoyPadState:: DS 1

SECTION "Game Engine Code", ROM0

ge_init::
	;; Set Palette
	ld hl, rBGP
	ld [hl], DEFAULT_PAL

	ld hl, OBP1
	ld [hl], DEFAULT_PAL

	;; Init OAM
	call wait_vblank_start
	call init_oam

	;; Enable Objects and Window in rLCDC
	ld hl, rLCDC
	set 1, [hl]
	set 5, [hl]

	ret