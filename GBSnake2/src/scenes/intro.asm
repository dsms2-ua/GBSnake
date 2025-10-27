;; Aquí cargamos la intro (Serpiente comiéndose el logo) para después pasar al menú
INCLUDE "constants.inc"

SECTION "Intro Sprites", WRAM0[$C000]
IntroOAMBuffer:: DS 24

SECTION "Intro Variables", WRAM0
IntroSnakeCounter:: DS 1
IntroSnakeSpeed:: DS 1
CounterIterations:: DS 1

SECTION "Intro Code", ROM0

TextPress::
	DB $8F, $91, $84, $92, $92
TextPressEnd::

TextStart::
	DB $92, $93, $80, $91, $93
TextStartEnd::

TextBy::
	DB $81, $98
TextByEnd::

TextBitBandits::
	DB $81, $88, $93, $81, $80, $8D, $83, $88, $93, $92, $9A
TextBitBanditsEnd::

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
	ld bc, 37*VRAM_TILE_SIZE
	call copy_vram

	;; Load logo tiles
	ld hl, logo_assets
	ld de, $8400
	ld bc, 28*VRAM_TILE_SIZE
	call copy_vram

	call init_sprites_intro

	;; Power on LCDC screen
	call enciende_pantalla

	;; Initialise variables
	ld a, 3
	ld [IntroSnakeSpeed], a
	xor a
	ld [IntroSnakeCounter], a
	ld a, 34
	ld [CounterIterations], a


	;; Iniciamos el sonido y la música de la intro
	call init_sound 	;; Encendemos el hardware
	ld hl, IntroMusic 	;; Apuntamos a la canción de la intro
	call play_music		;; La reproducimos

	ret

intro_run::
.drawSnake::
	;; Actualizamos la OAM
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
	ld a, [CounterIterations]
	cp 0
	jr nz, .movement

	;; We load the logo
	call show_logo

	;; Now a message is displayed to press Start
	call show_message_intro

	;; Waits until Start is pressed
	call wait_start

	ret

intro_clean::
	call apaga_pantalla

	;; Limpiamos la window
	call clean_window_intro

	;; Limpiamos los sprites
	call init_oam
	
	ret