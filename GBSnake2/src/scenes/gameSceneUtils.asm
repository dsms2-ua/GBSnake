INCLUDE "constants.inc"

;; --- Auxiliar functions ---
SECTION "Utils Scenes Game", ROM0

show_message_game::
	ld hl, TextScore
	ld de, $9A04
	ld bc, 5
	call copy_vram

	ld hl, TextMax
	ld de, $9A26
	ld bc, 3
	call copy_vram

	ret