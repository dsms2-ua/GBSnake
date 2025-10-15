INCLUDE "constants.inc"
SECTION "Game Scene Code", ROM0
game_init::
	;; Load game map
	ld hl, mapGame
	ld de, BGMAP1_START
	ld c, MAP_HEIGHT
	call copy_map