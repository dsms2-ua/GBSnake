INCLUDE "constants.inc"

SECTION "Game Scene Code", ROM0

TextScore::
	DB $92, $82, $8E, $91, $84

TextMax::
	DB $8C, $80, $97

game_init::
	;; Copiamos los tiles sobreescribiendo los que ya están
	ld hl, assets
	ld de, VRAM_TILE_DATA_START
	ld bc, 26*VRAM_TILE_SIZE
	call copy_vram

	;; Load game map
	ld hl, mapGame
	ld de, BGMAP0_START
	ld c, MAP_HEIGHT
	call copy_map

	;; Configuramos el LCDC para mostrar el mapa 1
	ld a, %10010011
	ld [rLCDC], a

	call enciende_pantalla

	call wait_vblank_start

	call show_message_game

	ret