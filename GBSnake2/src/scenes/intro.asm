;; Aquí cargamos la intro (Serpiente comiéndose el logo) para después pasar al menú
INCLUDE "constants.inc"

SECTION "Intro Sprites", WRAM0[$C000]
IntroOAMBuffer:: DS 160

SECTION "Intro Code", ROM0

intro_init::
	;; Power off LCDC screen to load tiles and map
	call apaga_pantalla

	;; Load Snake tiles 
	ld hl, snake_assets
	ld de, VRAM_TILE_DATA_START + ($1A * VRAM_TILE_SIZE)
	ld b, 14*VRAM_TILE_SIZE
	call memcpy_256

	;; Load letters and numbers tiles
	ld hl, abecedario
	ld de, VRAM_FONT_DATA_START ;; $8800
	ld b, 27*VRAM_TILE_SIZE
	call memcpy_256

	call init_sprites_intro

	;; Power on LCDC screen
	call enciende_pantalla
	ret

intro_run::
.drawSnake::
	;; ACtualizamos la OAM
	call wait_vblank_start
	call copy_OAM_buffer

.movement::
	call wait_vblank_start
	;; Move the snake
	call move_snake_intro

	;;Update logo
	call update_logo_intro

	;; Copy OAM buffer
	call wait_vblank_start	
	call copy_OAM_buffer

	;; Comprove if animation is finished
	jp .movement

	;; Now a message is displayed to press Start
	call show_message_intro

	;; Waits until Start is pressed
	call wait_Start

	ret