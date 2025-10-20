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


InitializeSnakeData:

   ld a, 8  ;8 frames entre movimiento
   ld [MovementDelay], a

    ; Copia los valores de un solo byte
    ld a, [SnakeLength_INIT]
    ld [SnakeLength], a
    
    ld a, [SnakeDirection_INIT]
    ld [SnakeDirection], a

    ; Copia los 3 bytes iniciales de las coordenadas
    ld hl, SnakeCoordsX_INIT
    ld de, SnakeCoordsX
    ld b, 3
    call memcpy_256

    ld hl, SnakeCoordsY_INIT
    ld de, SnakeCoordsY
    ld b, 3
    call memcpy_256
    ret

ReadJoypad:
    ; 1. Seleccionamos los botones de dirección para leer
    ld a, DPAD
    ld [rP1], a

    ; 2. Leemos el estado del joypad (varias veces para estabilizar)
    ld a, [rP1]
    ld a, [rP1]

    ; 3. Guardamos los estados para no tener que leer de nuevo
    ld c, a             ; C = estado de los botones (un '0' es pulsado)
    ld a, [SnakeDirection]
    ld b, a             ; B = dirección actual

    ; --- INICIO DE LA LÓGICA DE COMPROBACIÓN CORRECTA ---

    ; Comprobamos si DERECHA está pulsado (bit 0 = 0)
    ld a, c
    bit 0, a
    jr nz, .check_left  ; Si el bit no es 0, salta a la siguiente comprobación
    ; DERECHA está pulsado. Comprobamos que no estemos yendo a la IZQUIERDA
    ld a, b
    cp 2                ; 2 es IZQUIERDA
    ret z               ; Si íbamos a la izquierda, no hacemos nada y salimos
    ld a, 3             ; Nueva dirección: 3 (DERECHA)
    jr .update_dir

.check_left:
    ; Comprobamos si IZQUIERDA está pulsado (bit 1 = 0)
    ld a, c
    bit 1, a
    jr nz, .check_up
    ; IZQUIERDA está pulsado. Comprobamos que no estemos yendo a la DERECHA
    ld a, b
    cp 3                ; 3 es DERECHA
    ret z
    ld a, 2             ; Nueva dirección: 2 (IZQUIERDA)
    jr .update_dir

.check_up:
    ; Comprobamos si ARRIBA está pulsado (bit 2 = 0)
    ld a, c
    bit 2, a
    jr nz, .check_down
    ; ARRIBA está pulsado. Comprobamos que no estemos yendo a ABAJO
    ld a, b
    cp 1                ; 1 es ABAJO
    ret z
    ld a, 0             ; Nueva dirección: 0 (ARRIBA)
    jr .update_dir

.check_down:
    ; Comprobamos si ABAJO está pulsado (bit 3 = 0)
    ld a, c
    bit 3, a
    ret nz              ; Si no está pulsado, no se ha pulsado nada, salimos
    ; ABAJO está pulsado. Comprobamos que no estemos yendo a ARRIBA
    ld a, b
    cp 0                ; 0 es ARRIBA
    ret z
    ld a, 1             ; Nueva dirección: 1 (ABAJO)
    ; Cae directamente en .update_dir

.update_dir:
    ld [SnakeDirection], a
    ret

MoveSnake:
    ; --- PASO 1: Borrar la cola de la pantalla (Sin cambios) ---
    ld a, [SnakeLength]
    dec a
    ld b, 0
    ld c, a
    ld hl, SnakeCoordsX
    add hl, bc
    ld e, [hl]
    ld hl, SnakeCoordsY
    add hl, bc
    ld d, [hl]
    ld a, TILE_EMPTY
    ld b, d
    ld c, e
    call DrawTileAt

    ; --- PASO 2: Redibujar el "cuello" (la antigua cabeza) ---
    ; Antes de mover los datos, calculamos qué tile de cuerpo o esquina
    ; debe ir en la posición que la cabeza está a punto de dejar.
    call UpdateNeckTile

    ; --- PASO 3: Mover los datos del cuerpo en la memoria (Sin cambios) ---
    ; (Tu código de bucles .move_x_loop y .move_y_loop va aquí)
    ld a, [SnakeLength]
    dec a
    ld b, 0
    ld c, a
    ld hl, SnakeCoordsX
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
    ; ... y lo mismo para las coordenadas Y ...
    ld a, [SnakeLength]
    dec a
    ld b, 0
    ld c, a
    ld hl, SnakeCoordsY
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

    ; --- PASO 4: Actualizar la posición y dibujar la nueva cabeza ---
    ld hl, SnakeCoordsX
    ld de, SnakeCoordsY
    ld a, [SnakeDirection]
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
    ; Comprobamos si la nueva posición de la cabeza choca
    ; con algo antes de dibujarla.
    call CheckAllCollisions
    jr c, .collision_happened ; Si Carry = 1 (colisión), saltamos a GameOver

    ; Si no hay colisión (Carry = 0), continuamos dibujando la cabeza...

    ld a, [SnakeDirection]
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
    ld a, [SnakeCoordsX]
    ld c, a
    ld a, [SnakeCoordsY]
    ld b, a
    pop af
    call DrawTileAt

    ret

.collision_happened:
    ; Si hemos llegado aquí, hubo una colisión.
    jp GameOver ; Saltamos a la rutina de fin de juego

UpdateNeckTile:
    ; Esta rutina determina qué tile de cuerpo/esquina poner en la posición
    ; de la cabeza actual (el futuro "cuello").

    ld a, [SnakeDirection]
    ld b, a ; B = Nueva dirección (0:U, 1:D, 2:L, 3:R)

	; Esto nos da la dirección del movimiento ANTERIOR.
    ld a, [SnakeCoordsX]    ; Coordenada X de la CABEZA (H)
    ld hl, SnakeCoordsX+1   ; Puntero a la coordenada X del primer segmento (S1)
    ld e, [hl]              ; Valor de la coordenada X de S1
    sub e                   ; Restas A = X(H) - X(S1)
    ld c, a ; C = Delta X entre la cabeza y el cuello

    ld a, [SnakeCoordsY]    ; Lo mismo para Y...
    ld hl, SnakeCoordsY+1
    ld e, [hl]
    sub e
    ld d, a ; D = Delta Y entre la cabeza y el cuello
    
    ; El resto de la lógica de la función no cambia.
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
    ld a, [SnakeCoordsX]
    ld c, a
    ld a, [SnakeCoordsY]
    ld b, a
    pop af
    call DrawTileAt

    ret

DrawTileAt:
    ; Guardamos los registros que vamos a modificar
    push af
    push bc

    ; Calculamos la dirección en VRAM usando aritmética de 16 bits para evitar desbordamientos.
    ; La fórmula es: HL = $9800 + (Y * 32) + X

    ; 1. Calcular Y * 32 en HL (16 bits)
    ;    (La coordenada Y viene en el registro 'b')
    ld l, b         ; Ponemos Y en la parte baja de HL
    ld h, 0         ; Ponemos a 0 la parte alta. Ahora HL = Y
    
    add hl, hl      ; HL = Y * 2
    add hl, hl      ; HL = Y * 4
    add hl, hl      ; HL = Y * 8
    add hl, hl      ; HL = Y * 16
    add hl, hl      ; HL = Y * 32

    ; 2. Sumar X (16 bits)
    ;    (La coordenada X viene en el registro 'c')
    ld b, 0         ; Ponemos a 0 la parte alta de BC. Ahora BC = X
    add hl, bc      ; HL = (Y * 32) + X

    ; 3. Sumar la dirección base del mapa de fondo
    ld bc, $9800
    add hl, bc      ; HL tiene ahora la dirección final y correcta en VRAM

    ; Recuperamos el valor del tile y lo escribimos en la dirección calculada
    pop bc
    pop af
    ld [hl], a
    ret

; ==============================================================================
; GetTrueRandom:
; Lee el registro rDIV hasta obtener un valor diferente al anterior.
; Esto evita bucles infinitos si la CPU es más rápida que el contador rDIV.
; Salida:
;   A = Nuevo valor aleatorio de 8 bits.
; Registros modificados:
;   A, B
; ==============================================================================
GetTrueRandom:
    ld a, [rDIV]
    ld b, a         ; Guarda el valor actual en B
.wait_for_change:
    ld a, [rDIV]    ; Lee el nuevo valor
    cp b            ; ¿Es igual al que guardamos?
    jr z, .wait_for_change ; Si es igual, sigue esperando
    ret             ; Si es diferente, salimos con el nuevo valor en A

SpawnFood:
.generate_coords:
    ; --- Generar coordenada X (rango 1-18) ---
    
.generate_x_loop:
	call GetTrueRandom
    ; 1. Generamos un número aleatorio en el rango 0-17.
    ;    Para ello, tomamos un número aleatorio (0-31) y lo descartamos si es >= 18.
    and %00011111           ; Máscara para obtener un número entre 0 y 31
    cp 18                   ; Comparamos con 18
    jr nc, .generate_x_loop ; Si A >= 18, es inválido, vuelve a intentarlo
    
    ; 2. Ahora A está entre 0 y 17. Le sumamos 1 para obtener el rango 1-18.
    inc a
    ld [FoodX], a

    
.generate_y_loop:
	; --- Generar coordenada Y (rango 1-14) ---
    call GetTrueRandom
    ; 1. Generamos un número aleatorio en el rango 0-13.
    ;    Usamos una máscara más pequeña (0-15) y descartamos si es >= 14.
    and %00001111           ; Máscara para obtener un número entre 0 y 15
    cp 14                   ; Comparamos con 14
    jr nc, .generate_y_loop ; Si A >= 14, es inválido, vuelve a intentarlo

    ; 2. Ahora A está entre 0 y 13. Le sumamos 1 para obtener el rango 1-14.
    inc a
    ld [FoodY], a

    ; --- Comprobamos que no hemos generado la comida encima de la serpiente ---
    ; (Esta parte de tu código ya funcionaba bien y la mantenemos)
    ld a, [SnakeLength]
    ld b, a
    ld hl, SnakeCoordsX
    ld de, SnakeCoordsY
.check_snake_collision:
    push de
    push hl
    
    ld a, [hl]
    ld c, a
    ld a, [FoodX]
    cp c
    jr nz, .coords_ok

    ld a, [de]
    ld c, a
    ld a, [FoodY]
    cp c
    jr nz, .coords_ok

    ; Colisión detectada, tenemos que generar nuevas coordenadas desde el principio
    pop hl
    pop de
    jp .generate_coords

.coords_ok:
    pop hl
    pop de
    inc hl
    inc de
    dec b
    jr nz, .check_snake_collision

    ; Si hemos pasado el bucle, la posición es válida. La dibujamos.
    ld a, [FoodX]
    ld c, a
    ld a, [FoodY]
    ld b, a
    ld a, TILE_FRUIT
    call DrawTileAt
    ret
CheckForFood:
    ; Comparamos la posición de la cabeza con la de la comida
    ld a, [SnakeCoordsX]
    ld b, a
    ld a, [FoodX]
    cp b
    ret nz  ; Si las X no coinciden, salimos

    ld a, [SnakeCoordsY]
    ld b, a
    ld a, [FoodY]
    cp b
    ret nz  ; Si las Y no coinciden, salimos

    ; --- ¡Hemos comido! ---
    ; 1. Hacemos crecer a la serpiente
    ld a, [SnakeLength]
    inc a
    ld [SnakeLength], a

    ; 2. Generamos una nueva pieza de comida
    call SpawnFood
    ret

; ==============================================================================
; CheckAllCollisions
; Comprueba si la cabeza de la serpiente choca con las paredes o
; con su propio cuerpo.
; Salida:
;   Flag Carry (CF) = 1 si hay colisión, 0 si no.
; ==============================================================================
CheckAllCollisions:
    ; --- 1. Cargar coordenadas de la cabeza ---
    ld a, [SnakeCoordsX]
    ld e, a ; E = HeadX
    ld a, [SnakeCoordsY]
    ld d, a ; D = HeadY

    ; --- 2. Comprobar colisión con paredes ---
    ; Los límites válidos son X (1-18) e Y (1-14)
    ld a, e ; Comprobar HeadX
    cp 1
    jr c, .collision_detected   ; Si A < 1, colisión
    cp 19
    jr nc, .collision_detected  ; Si A >= 19 (fuera por la derecha), colisión

    ld a, d ; Comprobar HeadY
    cp 1
    jr c, .collision_detected   ; Si A < 1, colisión
    cp 15
    jr nc, .collision_detected  ; Si A >= 15 (fuera por abajo), colisión

    ; --- 3. Comprobar colisión con el cuerpo ---
    ; Comparamos la cabeza (índice 0) con el resto del cuerpo (1 a Length-1)
    ld a, [SnakeLength]
    dec a
    ret z               ; Si la serpiente solo mide 1, no puede chocar
    ld b, a             ; B = contador (Length - 1)
    ld hl, SnakeCoordsX + 1 ; Puntero al X del primer segmento (cuello)
    ld de, SnakeCoordsY + 1 ; Puntero al Y del primer segmento (cuello)

.self_collision_loop:
    ld a, [hl]          ; A = SegmentX
    cp e                ; Compara con HeadX
    jr nz, .segment_ok  ; Si X no coincide, saltar

    ld a, [de]          ; A = SegmentY
    cp d                ; Compara con HeadY
    jr z, .collision_detected ; Si Y TAMBIÉN coincide, ¡colisión!

.segment_ok:
    inc hl              ; Siguiente SegmentX
    inc de              ; Siguiente SegmentY
    dec b
    jr nz, .self_collision_loop ; Repetir bucle

    ; --- 4. Sin colisión ---
    or a                ; Resetea el flag de carry (CF = 0)
    ret

.collision_detected:
    scf                 ; Pone el flag de carry a 1 (CF = 1)
    ret

; ==============================================================================
; GameOver
; Se llama al colisionar. Borra el cuerpo de la serpiente y congela el juego.
; NO borra la cabeza, para evitar borrar el tile de la pared.
; ==============================================================================
GameOver:
    ; 1. Deshabilitamos interrupciones para congelar el juego.
    di
    
    ; 2. Preparamos el bucle para borrar la serpiente
    ld a, [SnakeLength]
    dec a               ; Restamos 1, porque no vamos a borrar la cabeza
    ret z               ; Si la longitud era 1, no hay nada que borrar
    
    ld b, a             ; B = contador (Length - 1)
    ld hl, SnakeCoordsX + 1 ; Empezamos en el CUELLO (índice 1)
    ld de, SnakeCoordsY + 1 ; Empezamos en el CUELLO (índice 1)

.clear_loop:
    push hl             ; Guardamos puntero X
    push de             ; Guardamos puntero Y
    push bc             ; Guardamos contador
    
    ld c, [hl]          ; C = SegmentX
    ld a, [de]
    ld b, a             ; B = SegmentY
    ld a, TILE_EMPTY    ; Tile vacío
    call DrawTileAt     ; Borra el tile
    
    pop bc              ; Recuperamos contador B
    pop de              ; Recuperamos puntero DE
    pop hl              ; Recuperamos puntero HL
    
    inc hl              ; Siguiente X
    inc de              ; Siguiente Y
    
    dec b               ; Decrementamos contador
    jr nz, .clear_loop  ; Repetimos si B no es 0
    
    ; 3. Bucle infinito para detener el juego
.freeze:
    jp .freeze