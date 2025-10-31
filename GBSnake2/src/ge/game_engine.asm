INCLUDE "constants.inc"

SECTION "Game Variables", WRAM0
JoyPadState:: 			DS 1
GameFinish::			DS 1
Score::					DS 1
HighScores::			DS 2

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

	;; Iniciamos variables
	ld hl, MenuOption
	ld a, 4
	ld [hl], a

	ret