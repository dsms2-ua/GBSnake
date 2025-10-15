INCLUDE "constants.inc"

SECTION "OAM Code", ROM0
init_oam::
	ld hl, OAM_DIR
	ld b, 160
	xor OAM_SIZE
	call memset_256
	ret