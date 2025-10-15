INCLUDE "constants.inc"

; =============================================
; DATOS INICIALES DE LA SERPIENTE (EN ROM)
; =============================================
SECTION "SnakeInitialData", ROM0

SnakeLength_INIT:    db 3
SnakeDirection_INIT: db 3
SnakeCoordsX_INIT:   db 10, 9, 8
SnakeCoordsY_INIT:   db 5, 5, 5

; =============================================
; VARIABLES DEL JUEGO (EN WRAM)
; =============================================
SECTION "SnakeData", WRAM0

FrameCounter:   ds 1
MovementDelay:  ds 1
FoodX:          ds 1
FoodY:          ds 1
SnakeLength:    ds 1
SnakeDirection: ds 1
SnakeCoordsX:   ds SNAKE_MAX_LENGTH
SnakeCoordsY:   ds SNAKE_MAX_LENGTH

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

	;; Limpiamos los tiles del logo
	ld hl, $8400
	ld a, $00
	ld bc, 28*VRAM_TILE_SIZE
	call memset

	;; Load game map
	ld hl, mapGame
	ld de, BGMAP0_START
	ld c, MAP_HEIGHT
	call copy_map

	; 1. Preparamos nuestras variables
    call InitializeSnakeData

    ; 2. Dibujamos la serpiente inicial sobre el mapa ya cargado
	ld a, [SnakeCoordsX]
	ld c, a
	ld a, [SnakeCoordsY]
	ld b, a
	ld a, TILE_HEAD_R       ; <-- CORREGIDO: Cabeza mirando a la derecha
	call DrawTileAt

	ld a, [SnakeCoordsX+1]
	ld c, a
	ld a, [SnakeCoordsY+1]
	ld b, a
	ld a, TILE_BODY_HORIZ   ; <-- CORREGIDO: Cuerpo horizontal
	call DrawTileAt

	ld a, [SnakeCoordsX+2]
	ld c, a
	ld a, [SnakeCoordsY+2]
	ld b, a
	ld a, TILE_BODY_HORIZ   ; <-- CORREGIDO: Cuerpo horizontal
	call DrawTileAt

	call SpawnFood

	;; Configuramos el LCDC para mostrar el mapa 1
	ld a, %10010011
	ld [rLCDC], a

	call enciende_pantalla

	call wait_vblank_start

	call show_message_game

	; Habilitamos la interrupción de V-Blank usando LDH
    ld a, 1
    ldh [rIE - $FF00], a ;
	ei

	ret

game_run::
.game_loop:
    halt    ; Espera a V-Blank

    call ReadJoypad

    ; Lógica del contador de frames para ralentizar
    ld a, [FrameCounter]
    dec a
    ld [FrameCounter], a
    jr nz, .game_loop ; Si no es cero, vuelve a esperar

    ; Si el contador llegó a cero, lo reiniciamos
    ld a, [MovementDelay]
    ld [FrameCounter], a
    
    ; Lógica del juego
    call MoveSnake
    call CheckForFood

    jp .game_loop

