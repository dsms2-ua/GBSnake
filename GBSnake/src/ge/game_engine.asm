INCLUDE "definitions.inc"

SECTION "Game Engine Code", ROM0

ge_init::
	;; Set Palette
	ld hl, rBGP
	ld [hl], DEFAULT_PAL

	ld hl, OBP1
	ld [hl], DEFAULT_PAL

	;; Init OAM
	call wait_vblank_start
	ld hl, OAM_DIR
	ld b, 160
	xor a
	call memset_256

	;; Enable Objects in rLCDC
	ld hl, rLCDC
	set 1, [hl]

	ret