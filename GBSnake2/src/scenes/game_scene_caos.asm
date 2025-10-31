INCLUDE "constants.inc"

; =============================================
; DATOS INICIALES DE LA SERPIENTE (EN ROM)
; =============================================
SECTION "SnakeInitialDataCaos", ROM0
SnakeLength_INIT_CAOS:    db 3
SnakeDirection_INIT_CAOS: db 3
SnakeCoordsX_INIT_CAOS:   db 10, 9, 8
SnakeCoordsY_INIT_CAOS:   db 5, 5, 5

; =============================================
; VARIABLES DEL JUEGO CAOS (EN WRAM)
; =============================================
SECTION "SnakeDataCaos", WRAM0
FrameCounterCaos:   ds 1
MovementDelayCaos:  ds 1
FoodXCaos:          ds 1
FoodYCaos:          ds 1
PoisonXCaos:        ds 1
PoisonYCaos:        ds 1
PoisonActiveCaos:   ds 1  ; 0 = no hay veneno, 1 = hay veneno en pantalla
SnakeLengthCaos:    ds 1
SnakeDirectionCaos: ds 1
SnakeCoordsXCaos:   ds SNAKE_MAX_LENGTH
SnakeCoordsYCaos:   ds SNAKE_MAX_LENGTH
RNGSeedCaos:        ds 1
AliveCaos::         ds 1
ControlsInvertedCaos:: ds 1  ; 0 = normales, 1 = invertidos
PoisonTimerCaos:    ds 1  ; Contador para que desaparezca el veneno (~5 segundos)

; =============================================
; CÓDIGO DEL MODO CAOS
; =============================================
SECTION "Game Scene Caos Code", ROM0

game_init_caos::
    ;; Copiamos los tiles del mapa
    ld hl, mapGame
    ld de, BGMAP0_START
    ld c, MAP_HEIGHT
    call copy_map

    ; 1. Preparamos nuestras variables
    call InitializeSnakeDataCaos
    call SeedRandomCaos
    xor a
	ld [GameFinish], a
    
    ; Inicializar controles normales
    xor a
    ld [ControlsInvertedCaos], a
    
    ; Inicializar sin veneno en pantalla
    ld [PoisonActiveCaos], a

    ; 2. Dibujamos la serpiente inicial sobre el mapa ya cargado
    ld a, [SnakeCoordsXCaos]
    ld c, a
    ld a, [SnakeCoordsYCaos]
    ld b, a
    ld a, TILE_HEAD_R
    call DrawTileAt

    ld a, [SnakeCoordsXCaos+1]
    ld c, a
    ld a, [SnakeCoordsYCaos+1]
    ld b, a
    ld a, TILE_BODY_HORIZ
    call DrawTileAt

    ld a, [SnakeCoordsXCaos+2]
    ld c, a
    ld a, [SnakeCoordsYCaos+2]
    ld b, a
    ld a, TILE_BODY_HORIZ
    call DrawTileAt

    ; Spawnar comida inicial
    call SpawnFoodCaos
    
    ; Inicializar score en pantalla
    ld a, 0
    ld b, 0
    ld c, 0
    ld d, 0
    call DrawScore

    ; Inicializar score en memoria
    call ScoreInitCaos

    ;; Cargamos la puntuacion maxima y la dibujamos
    call load_high_score
    call draw_high_score

    ;; Configuramos el LCDC para mostrar el mapa 1
    ld a, %10010011
    ld [rLCDC], a

    call wait_vblank_start
    call show_message_game
    call enciende_pantalla

    ret

game_run_caos::
.game_loop:
    call wait_vblank_start

    ;; Comprobamos si estamos vivos
    ld a, [AliveCaos]
    bit 0, a
    jr z, .exit_loop

    ;; Comprobamos si hemos llegado al límite de tamaño
    ld a, [SnakeLengthCaos]
    cp SNAKE_MAX_LENGTH
    jr z, .game_win

    call ReadJoypadCaos
    call UpdatePoisonTimer

    ; Lógica del contador de frames para ralentizar
    ld a, [FrameCounterCaos]
    dec a
    ld [FrameCounterCaos], a
    jr nz, .game_loop ; Si no es cero, vuelve a esperar


    ; Si el contador llegó a cero, lo reiniciamos
    ld a, [MovementDelayCaos]
    ld [FrameCounterCaos], a

    ; Lógica del juego
    call MoveSnakeCaos
    call CheckForFoodCaos
    call CheckForPoisonCaos

    ;; Comprobamos la velocidad y el veneno
    ld a, [ControlsInvertedCaos]
    cp 0
    jr z, .no_poison

    call mostrar_veneno
    jp .fin

.no_poison
    call ocultar_veneno

.fin
    jp .game_loop

.game_win
    ld a, 1
    ld [GameFinish], a

.exit_loop
    ret

game_clean_caos::
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