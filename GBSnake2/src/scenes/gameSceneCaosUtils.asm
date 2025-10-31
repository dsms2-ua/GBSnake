INCLUDE "constants.inc"

;; --- Funciones modificadas para el modo CAOS ---
SECTION "Utils Scenes Game Caos", ROM0

InitializeSnakeDataCaos:
    ;; Ponemos la serpiente como viva
    ld hl, AliveCaos
    set 0, [hl]

    ld a, FRAME_DELAY  ;8 frames entre movimiento (inicial)
    ld [MovementDelayCaos], a

    ; Copia los valores de un solo byte
    ld a, [SnakeLength_INIT_CAOS]
    ld [SnakeLengthCaos], a
    
    ld a, [SnakeDirection_INIT_CAOS]
    ld [SnakeDirectionCaos], a

    ; Copia los 3 bytes iniciales de las coordenadas
    ld hl, SnakeCoordsX_INIT_CAOS
    ld de, SnakeCoordsXCaos
    ld b, 3
    call memcpy_256

    ld hl, SnakeCoordsY_INIT_CAOS
    ld de, SnakeCoordsYCaos
    ld b, 3
    call memcpy_256
    ret

ReadJoypadCaos:
    ; 1. Seleccionamos los botones de dirección para leer
    ld a, DPAD
    ld [rP1], a

    ; 2. Leemos el estado del joypad (varias veces para estabilizar)
    ld a, [rP1]
    ld a, [rP1]

    ; 3. Guardamos los estados
    ld c, a             ; C = estado de los botones (un '0' es pulsado)
    ld a, [SnakeDirectionCaos]
    ld b, a             ; B = dirección actual

    ; --- VERIFICAR SI LOS CONTROLES ESTÁN INVERTIDOS ---
    ld a, [ControlsInvertedCaos]
    cp 1
    jr z, .inverted_controls
    
    ; --- CONTROLES NORMALES ---
    ; Comprobamos si DERECHA está pulsado (bit 0 = 0)
    ld a, c
    bit 0, a
    jr nz, .check_left
    ld a, b
    cp 2                ; 2 es IZQUIERDA
    ret z
    ld a, 3             ; Nueva dirección: 3 (DERECHA)
    jr .update_dir

.check_left:
    ld a, c
    bit 1, a
    jr nz, .check_up
    ld a, b
    cp 3                ; 3 es DERECHA
    ret z
    ld a, 2             ; Nueva dirección: 2 (IZQUIERDA)
    jr .update_dir

.check_up:
    ld a, c
    bit 2, a
    jr nz, .check_down
    ld a, b
    cp 1                ; 1 es ABAJO
    ret z
    ld a, 0             ; Nueva dirección: 0 (ARRIBA)
    jr .update_dir

.check_down:
    ld a, c
    bit 3, a
    ret nz
    ld a, b
    cp 0                ; 0 es ARRIBA
    ret z
    ld a, 1             ; Nueva dirección: 1 (ABAJO)
    jr .update_dir

    ; --- CONTROLES INVERTIDOS ---
.inverted_controls:
    ; DERECHA hace IZQUIERDA
    ld a, c
    bit 0, a
    jr nz, .inv_check_left
    ld a, b
    cp 3                ; No ir a DERECHA cuando vamos a DERECHA
    ret z
    ld a, 2             ; IZQUIERDA
    jr .update_dir

.inv_check_left:
    ; IZQUIERDA hace DERECHA
    ld a, c
    bit 1, a
    jr nz, .inv_check_up
    ld a, b
    cp 2                ; No ir a IZQUIERDA cuando vamos a IZQUIERDA
    ret z
    ld a, 3             ; DERECHA
    jr .update_dir

.inv_check_up:
    ; ARRIBA hace ABAJO
    ld a, c
    bit 2, a
    jr nz, .inv_check_down
    ld a, b
    cp 0                ; No ir a ARRIBA cuando vamos a ARRIBA
    ret z
    ld a, 1             ; ABAJO
    jr .update_dir

.inv_check_down:
    ; ABAJO hace ARRIBA
    ld a, c
    bit 3, a
    ret nz
    ld a, b
    cp 1                ; No ir a ABAJO cuando vamos a ABAJO
    ret z
    ld a, 0             ; ARRIBA

.update_dir:
    ld [SnakeDirectionCaos], a
    ret

MoveSnakeCaos:
    ; --- PASO 1: Borrar la cola de la pantalla ---
    ld a, [SnakeLengthCaos]
    dec a
    ld b, 0
    ld c, a
    ld hl, SnakeCoordsXCaos
    add hl, bc
    ld e, [hl]
    ld hl, SnakeCoordsYCaos
    add hl, bc
    ld d, [hl]
    ld a, TILE_EMPTY
    ld b, d
    ld c, e
    call DrawTileAt

    ; --- PASO 2: Redibujar el "cuello" ---
    call UpdateNeckTileCaos

    ; --- PASO 3: Mover los datos del cuerpo en la memoria ---
    ld a, [SnakeLengthCaos]
    dec a
    ld b, 0
    ld c, a
    ld hl, SnakeCoordsXCaos
    add hl, bc
    push hl
    pop de
    dec hl
.move_x_loop:
    ld a, [hl]
    dec hl
    ld [de], a
    dec de
    dec bc
    ld a, b
    or c
    jr nz, .move_x_loop

    ld a, [SnakeLengthCaos]
    dec a
    ld b, 0
    ld c, a
    ld hl, SnakeCoordsYCaos
    add hl, bc
    push hl
    pop de
    dec hl
.move_y_loop:
    ld a, [hl]
    dec hl
    ld [de], a
    dec de
    dec bc
    ld a, b
    or c
    jr nz, .move_y_loop

    ; --- PASO 3.5: Dibujar la NUEVA cola con el tile correcto ---
    ld a, [SnakeLengthCaos]
    cp 1
    jr z, .skip_tail    ; Si solo hay cabeza, no dibujar cola
    
    dec a
    ld b, 0
    ld c, a
    
    ; Leer coordenadas de la cola
    ld hl, SnakeCoordsXCaos
    add hl, bc
    ld a, [hl]
    ld [TempX], a       ; Guardar X cola en variable temporal
    
    ld hl, SnakeCoordsYCaos
    add hl, bc
    ld a, [hl]
    ld [TempY], a       ; Guardar Y cola en variable temporal
    
    ; Leer coordenadas del penúltimo
    dec c
    ld hl, SnakeCoordsXCaos
    add hl, bc
    ld a, [hl]
    ld [TempX2], a      ; Guardar X penúltimo
    
    ld hl, SnakeCoordsYCaos
    add hl, bc
    ld a, [hl]
    ld [TempY2], a      ; Guardar Y penúltimo
    
    ; Calcular delta X
    ld a, [TempX2]      ; X penúltimo
    ld b, a
    ld a, [TempX]       ; X cola
    sub b               ; A = X cola - X penúltimo
    
    cp $FF              ; -1 (penúltimo a la izquierda)
    jr z, .tail_right
    
    cp 1                ; +1 (penúltimo a la derecha)
    jr z, .tail_left
    
    ; Es vertical, calcular delta Y
    ld a, [TempY2]      ; Y penúltimo
    ld b, a
    ld a, [TempY]       ; Y cola
    sub b               ; A = Y cola - Y penúltimo
    
    cp $FF              ; -1 (penúltimo arriba)
    jr z, .tail_down
    
    ; +1 (penúltimo abajo)
    ld a, TILE_TAIL_U
    jr .draw_tail

.tail_down:
    ld a, TILE_TAIL_D
    jr .draw_tail

.tail_left:
    ld a, TILE_TAIL_L
    jr .draw_tail

.tail_right:
    ld a, TILE_TAIL_R

.draw_tail:
    push af
    ld a, [TempX]
    ld c, a
    ld a, [TempY]
    ld b, a
    pop af
    call DrawTileAt

.skip_tail:

    ; --- PASO 4: Actualizar la posición y dibujar la nueva cabeza ---
    ld hl, SnakeCoordsXCaos
    ld de, SnakeCoordsYCaos
    ld a, [SnakeDirectionCaos]
    cp 0 ; ARRIBA
    jr nz, .check_down_move
    ld a, [de]
    dec a
    ld [de], a
    jr .head_updated_move
.check_down_move:
    cp 1 ; ABAJO
    jr nz, .check_left_move
    ld a, [de]
    inc a
    ld [de], a
    jr .head_updated_move
.check_left_move:
    cp 2 ; IZQUIERDA
    jr nz, .check_right_move
    dec [hl]
    jr .head_updated_move
.check_right_move:
    inc [hl] ; DERECHA

.head_updated_move:
    ; Comprobamos colisiones
    call CheckAllCollisionsCaos
    jr c, .collision_happened

    ; Dibujar cabeza
    ld a, [SnakeDirectionCaos]
    cp 0
    jr nz, .draw_head_r
    ld a, TILE_HEAD_U
    jr .draw_it
.draw_head_r:
    cp 3
    jr nz, .draw_head_d
    ld a, TILE_HEAD_R
    jr .draw_it
.draw_head_d:
    cp 1
    jr nz, .draw_head_l
    ld a, TILE_HEAD_D
    jr .draw_it
.draw_head_l:
    ld a, TILE_HEAD_L

.draw_it:
    push af
    ld a, [SnakeCoordsXCaos]
    ld c, a
    ld a, [SnakeCoordsYCaos]
    ld b, a
    pop af
    call DrawTileAt
    ret

.collision_happened:
    jp GameOverCaos

UpdateNeckTileCaos:
    ld a, [SnakeDirectionCaos]
    ld b, a

    ld a, [SnakeCoordsXCaos]
    ld hl, SnakeCoordsXCaos+1
    ld e, [hl]
    sub e
    ld c, a

    ld a, [SnakeCoordsYCaos]
    ld hl, SnakeCoordsYCaos+1
    ld e, [hl]
    sub e
    ld d, a
    
    ld a, b
    cp 0
    jr z, .new_move_is_vertical
    cp 1
    jr nz, .new_move_is_horizontal

.new_move_is_vertical:
    ld a, c
    cp 0
    jr z, .es_recto_vertical
    cp 1
    jr z, .es_esquina_DL
.es_esquina_DR:
    ld a, b
    cp 0
    jr z, .es_esquina_UR_real
    ld a, TILE_CORNER_DR
    jr .draw_neck_tile
.es_esquina_UR_real:
    ld a, TILE_CORNER_UR
    jr .draw_neck_tile
.es_esquina_DL:
    ld a, b
    cp 0
    jr z, .es_esquina_UL_real
    ld a, TILE_CORNER_DL
    jr .draw_neck_tile
.es_esquina_UL_real:
    ld a, TILE_CORNER_LU
    jr .draw_neck_tile
.es_recto_vertical:
    ld a, TILE_BODY_VERT
    jr .draw_neck_tile

.new_move_is_horizontal:
    ld a, d
    cp 0
    jr z, .es_recto_horizontal
    cp 1
    jr z, .es_esquina_UL
.es_esquina_DL2:
    ld a, b
    cp 2
    jr z, .es_esquina_DL_real2
    ld a, TILE_CORNER_DR
    jr .draw_neck_tile
.es_esquina_DL_real2:
    ld a, TILE_CORNER_DL
    jr .draw_neck_tile
.es_esquina_UL:
    ld a, b
    cp 2
    jr z, .es_esquina_UL_real2
    ld a, TILE_CORNER_UR
    jr .draw_neck_tile
.es_esquina_UL_real2:
    ld a, TILE_CORNER_LU
    jr .draw_neck_tile
.es_recto_horizontal:
    ld a, TILE_BODY_HORIZ

.draw_neck_tile:
    push af
    ld a, [SnakeCoordsXCaos]
    ld c, a
    ld a, [SnakeCoordsYCaos]
    ld b, a
    pop af
    call DrawTileAt
    ret

CheckAllCollisionsCaos:
    ld a, [SnakeCoordsXCaos]
    ld c, a
    ld a, [SnakeCoordsYCaos]
    ld b, a
    
    ld l, b
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    
    ld b, 0
    add hl, bc
    
    ld bc, $9800
    add hl, bc
    
    push hl
    call WaitVRAMSafe
    pop hl

    ld a, [hl]
    
    cp TILE_EMPTY
    jr z, .no_collision
    
    cp TILE_FRUIT
    jr z, .no_collision
    
    cp TILE_POISON
    jr z, .no_collision
    
    scf
    ret

.no_collision:
    or a
    ret

GameOverCaos:    
    ld a, [SnakeLengthCaos]
    dec a
    ret z
    
    ld b, a
    ld hl, SnakeCoordsXCaos + 1
    ld de, SnakeCoordsYCaos + 1

.clear_loop:
    push hl
    push de
    push bc
    
    ld c, [hl]
    ld a, [de]
    ld b, a
    ld a, TILE_EMPTY
    call DrawTileAt
    
    pop bc
    pop de
    pop hl
    
    inc hl
    inc de
    
    dec b
    jr nz, .clear_loop
    
    ld hl, AliveCaos
    res 0, [hl]
    ret

SeedRandomCaos:
    call GetTrueRandom
    or 1
    ld [RNGSeedCaos], a
    ret

GetRandomByteCaos:
    ld hl, RNGSeedCaos
    ld a, [hl]
    
    ; Mezclar bits de manera más efectiva
    sla a
    jr nc, .no_xor1
    xor %10101101
.no_xor1:
    
    ; Segunda operación para mejor aleatoriedad
    rrca
    rrca
    xor [hl]
    
    ; Tercera operación
    add a, 37           ; Número primo para mejor distribución
    
    ld [hl], a
    ret

SpawnFoodCaos:
    ld b, 30
    
.random_loop:
    call GetRandomByteCaos
    and %00011111
    cp 18
    jr nc, .random_loop
    inc a
    ld c, a
    
.random_loop_2:
    call GetRandomByteCaos
    and %00001111
    cp 14
    jr nc, .random_loop_2
    inc a
    ld b, a
    
    push bc
    call CheckTileAt
    pop bc
    cp TILE_EMPTY
    jr z, .found_free
    
    dec b
    jr nz, .random_loop
    
    jr .exhaustive_search

.found_free:
    ld a, c
    ld [FoodXCaos], a
    ld a, b  
    ld [FoodYCaos], a
    
    ld a, TILE_FRUIT
    call DrawTileAt
    
    ; --- INTENTAR SPAWNAR VENENO (25% de probabilidad) ---
    call GetRandomByteCaos
    and %00000011       ; 0-3
    cp 2                
    jr nz, .no_poison_spawn
    
    ; Verificar si ya hay veneno activo
    ld a, [PoisonActiveCaos]
    cp 1
    jr z, .no_poison_spawn
    
    ; Intentar spawnar veneno
    call TrySpawnPoison
    
.no_poison_spawn:
    ret

.exhaustive_search:
    ld d, 1
    
.loop_y:
    ld a, d
    cp 15
    jr nc, .no_space
    
    ld e, 1
    
.loop_x:
    ld a, e
    cp 19
    jr nc, .next_row
    
    push de
    ld b, d
    ld c, e
    call CheckTileAt
    pop de
    cp TILE_EMPTY
    jr z, .found_exhaustive
    
    inc e
    jr .loop_x
    
.next_row:
    inc d
    jr .loop_y

.found_exhaustive:
    ld a, e
    ld [FoodXCaos], a
    ld a, d  
    ld [FoodYCaos], a
    
    ld a, TILE_FRUIT
    ld b, d
    ld c, e  
    call DrawTileAt
    ret

.no_space:
    ret

TrySpawnPoison:
    ld b, 20        ; 20 intentos para encontrar espacio
    
.poison_loop:
    ; Generar coordenada X (rango 1-18)
    call GetRandomByteCaos
    and %00011111       ; 0-31
    cp 18
    jr nc, .poison_loop  ; Si >= 18, reintentar
    inc a               ; Ahora está en rango 1-18
    ld c, a             ; C = X candidato
    
.poison_loop_2:
    ; Generar coordenada Y (rango 1-14)
    call GetRandomByteCaos
    and %00001111       ; 0-15
    cp 14
    jr nc, .poison_loop_2  ; Si >= 14, reintentar solo la Y
    inc a               ; Ahora está en rango 1-14
    ld e, a             ; E = Y candidato (temporal)
    
    ; Verificar que no sea la posición de la comida
    ld a, [FoodXCaos]
    cp c
    jr nz, .not_food_pos
    ld a, [FoodYCaos]
    cp e
    jr z, .poison_retry
    
.not_food_pos:
    ; Verificar que esté vacío
    push bc
    push de
    ld b, e             ; B = Y para CheckTileAt
    ; C ya tiene X
    call CheckTileAt
    pop de
    pop bc
    cp TILE_EMPTY
    jr z, .poison_found
    
.poison_retry:
    dec b
    jr nz, .poison_loop
    ret     ; No se pudo spawnar veneno
    
.poison_found:
    ; C = X, E = Y
    ld a, c
    ld [PoisonXCaos], a
    ld a, e
    ld [PoisonYCaos], a
    
    ld a, 1
    ld [PoisonActiveCaos], a

    ; Inicializar temporizador (~5 segundos a 60fps = 300 frames)
    ld a, 1000
    ld [PoisonTimerCaos], a
    
    ; Dibujar el veneno
    ld a, TILE_POISON
    ld b, e             ; B = Y
    ld c, c             ; C = X (ya está en C)
    call DrawTileAt
    ret
CheckForFoodCaos:
    ld a, [SnakeCoordsXCaos]
    ld b, a
    ld a, [FoodXCaos]
    cp b
    ret nz

    ld a, [SnakeCoordsYCaos]
    ld b, a
    ld a, [FoodYCaos]
    cp b
    ret nz

    ; --- ¡COMIDA COMIDA! ---
    
    ; Incrementar longitud
    ld a, [SnakeLengthCaos]
    inc a
    ld [SnakeLengthCaos], a

    ; Incrementar puntuación
    call IncScoreCaos

    ; --- ALEATORIZAR VELOCIDAD ---
    call RandomizeSpeed

    ; Generar nueva comida (que puede spawnar veneno)
    call SpawnFoodCaos
    
    ret

CheckForPoisonCaos:
    ; Verificar si hay veneno activo
    ld a, [PoisonActiveCaos]
    cp 1
    ret nz      ; No hay veneno, salir
    
    ; Comparar posición con veneno
    ld a, [SnakeCoordsXCaos]
    ld b, a
    ld a, [PoisonXCaos]
    cp b
    ret nz

    ld a, [SnakeCoordsYCaos]
    ld b, a
    ld a, [PoisonYCaos]
    cp b
    ret nz

    ; --- ¡VENENO COMIDO! ---
    
    ; Desactivar veneno
    xor a
    ld [PoisonActiveCaos], a
    
    ; INVERTIR CONTROLES
    ld a, [ControlsInvertedCaos]
    xor 1                       ; Toggle: 0->1, 1->0
    ld [ControlsInvertedCaos], a
    
    ret

RandomizeSpeed:
    ; Generar velocidad aleatoria entre 3 y 8
    call GetRandomByteCaos
    and %00000111       ; 0-7
    cp 6
    jr c, .valid_speed
    sub 6               ; Si >= 6, restamos para estar en rango
.valid_speed:
    add a, 3            ; Ahora está en rango 3-8
    ld [MovementDelayCaos], a
    ret

ScoreInitCaos:
    ld hl, Score
    xor a
    ld [hl], a
    ret

IncScoreCaos:
    ld hl, Score
    ld a, [hl]
    inc a
    ld [hl], a

.loadScore:
    ld l, a
    ld h, 0

.calcCent:
    ld b, 0
.centLoop:
    ld a, l
    cp 100
    jr c, .calcDec
    
    sub 100
    ld l, a
    inc b
    jr .centLoop

.calcDec:
    ld c, 0
.decLoop:
    ld a, l
    cp 10
    jr c, .prepareDrawScore
    sub 10
    ld l, a
    inc c
    jr .decLoop

.prepareDrawScore:
    ld d, l
    ; Caer en DrawScore (usar la función original)
    jp DrawScore

UpdatePoisonTimer::
    ; Verificar si hay veneno activo
    ld a, [PoisonActiveCaos]
    cp 1
    ret nz      ; No hay veneno, salir
    
    ; Decrementar temporizador
    ld a, [PoisonTimerCaos]
    dec a
    ld [PoisonTimerCaos], a
    
    ; Si llegó a 0, borrar el veneno
    ret nz      ; Si no es 0, aún tiene tiempo
    
    ; Temporizador llegó a 0, borrar veneno
    ld a, [PoisonXCaos]
    ld c, a
    ld a, [PoisonYCaos]
    ld b, a
    ld a, TILE_EMPTY
    call DrawTileAt
    
    ; Desactivar veneno
    xor a
    ld [PoisonActiveCaos], a
    
    ret