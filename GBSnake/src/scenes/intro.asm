;; Aquí cargamos la intro (Serpiente comiéndose el logo) para después pasar al menú
INCLUDE "definitions.inc"

SECTION "Intro Code", ROM0

intro_init::
	;; Load Snake tiles 
	call wait_vblank_start
	ld hl, snake_assets
	ld de, VRAM_TILE_DATA_START + (20 * VRAM_TILE_SIZE)
	ld b, 14*VRAM_TILE_SIZE
	call memcpy_256

	;; Load letters and numbers tiles
	call wait_vblank_start
	ld hl, abecedario
	ld de, VRAM_FONT_DATA_START ;; $8800
	ld b, 37*VRAM_TILE_SIZE
	call memcpy_256

intro_run::
	