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
TempX:          ds 1  
TempY:          ds 1  
TempX2:         ds 1  
TempY2:         ds 1
SnakeCoordsX:   ds SNAKE_MAX_LENGTH
SnakeCoordsY:   ds SNAKE_MAX_LENGTH
RNGSeed:        ds 1
Alive::			DS 1

SECTION "Game Scene Code", ROM0

TextScore::
	DB $92, $82, $8E, $91, $84, $A6
TextScoreEnd::

TextMax::
	DB $8C, $80, $97, $A6
TextMaxEnd::

game_init::
	;; Copiamos los tiles del mapa
	ld hl, mapGame
	ld de, BGMAP0_START
	ld c, MAP_HEIGHT
	call copy_map

	; 1. Preparamos nuestras variables
    call InitializeSnakeData
	call SeedRandom
	xor a
	ld [GameFinish], a

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
	ld a, 0
	ld b, 0
	ld c, 0
	ld d, 0
	call DrawScore
	call ScoreInit

	;; Cargamos la puntuacion maxima y la dibujamos
	call load_high_score
	call draw_high_score

	;; Configuramos el LCDC para mostrar el mapa 1
	ld a, %10010011
	ld [rLCDC], a

	call wait_vblank_start
	call show_message_game

	call enciende_pantalla

	;;call wait_vblank_start

	; Habilitamos la interrupción de V-Blank usando LDH
    ;ld a, 1
    ;ldh [rIE - $FF00], a ;
	;ei

	ret

game_run::
.game_loop:
    ;halt    ; Espera a V-Blank
	call wait_vblank_start

	;; Comprobamos si estamos vivos
	ld a, [Alive]
	bit 0, a
	jr z, .exit_loop

	;; Comprobamos si hemos llegado al límite de tamaño
    ld a, [SnakeLength]
    cp SNAKE_MAX_LENGTH
    jr z, .game_win

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

.game_win
    ld a, 1
    ld [GameFinish], a

.exit_loop
	ret

game_clean::
	call apaga_pantalla

	;; Borrar el mapa
	ld hl, BGMAP0_START
	ld bc, 32*32
	xor a
	call memset

	;; Limpiar el score y max
	ld hl, $9A04
	ld b, 9
	ld a, $00
	call memset_256

	ld hl, $9A26
	ld b, 7
	ld a, $00
	call memset_256

	ret

