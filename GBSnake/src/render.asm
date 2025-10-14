; ============================================
; RENDERING - render.asm
; Dibujado de la serpiente, fruta y puntuación
; ============================================
SECTION "RENDER", ROM0
; ============================================
; RENDER GAME
; Renderiza todos los elementos del juego
; ============================================
RenderGame:
    call WaitVBlank
    
    ; Limpiar serpiente anterior (solo necesario si no usamos buffer)
    call ClearSnake
    
    ; Dibujar serpiente
    call DrawSnake
    
    ; Dibujar fruta
    call DrawFruit
    
    ; Dibujar puntuación
    call DrawScore
    
    ret

; ============================================
; CLEAR SNAKE
; Limpia la serpiente del frame anterior
; ============================================
ClearSnake:
    ld hl, wSnakeX
    ld de, wSnakeY
    ld a, [wSnakeLength]
    ld b, a
    
.clearLoop:
    push bc
    push hl
    push de
    
    ; Obtener posición
    ld a, [hl]
    ld c, a                 ; X en C
    ld a, [de]
    ld b, a                 ; Y en B
    
    ; Calcular dirección en el mapa: $9800 + (Y * 32) + X
    push bc
    ld hl, $9800
    ld a, b
    ld b, 0
    ld c, a
    
    ; Multiplicar Y por 32 (shift left 5 veces)
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    
    add hl, bc
    pop bc
    
    ; Añadir X
    ld b, 0
    add hl, bc
    
    ; Escribir tile vacío
    ld a, TILE_EMPTY
    ld [hl], a
    
    pop de
    pop hl
    pop bc
    
    inc hl
    inc de
    dec b
    jp nz, .clearLoop
    
    ret

; ============================================
; DRAW SNAKE
; Dibuja la serpiente en el mapa
; ============================================
DrawSnake:
    ld hl, wSnakeX
    ld de, wSnakeY
    ld a, [wSnakeLength]
    ld b, a
    
.drawLoop:
    push bc
    push hl
    push de
    
    ; Obtener posición
    ld a, [hl]
    ld c, a                 ; X en C
    ld a, [de]
    ld b, a                 ; Y en B
    
    ; Calcular dirección en el mapa
    push bc
    ld hl, $9800
    ld a, b
    ld b, 0
    ld c, a
    
    ; Multiplicar Y por 32
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    
    add hl, bc
    pop bc
    
    ; Añadir X
    ld b, 0
    add hl, bc
    
    ; Determinar qué tile dibujar (cabeza o cuerpo)
    pop de
    pop hl
    
    ; Si es el primer segmento, es la cabeza
    push hl
    ld hl, wSnakeX
    push de
    or a                    ; Clear carry
    sbc hl, de              ; Comparar direcciones
    pop de
    pop hl
    
    ld a, TILE_SNAKE_BODY
    jp nz, .notHead
    ld a, TILE_SNAKE_HEAD
    
.notHead:
    push hl
    ld hl, sp+6            ; Recuperar dirección del tile map
    ld [hl], a             ; Escribir tile
    pop hl
    
    pop bc
    
    inc hl
    inc de
    dec b
    jp nz, .drawLoop
    
    ret

; ============================================
; DRAW FRUIT
; Dibuja la fruta si está activa
; ============================================
DrawFruit:
    ; Verificar si la fruta está activa
    ld a, [wFruitActive]
    cp 1
    ret nz
    
    ; Obtener posición
    ld a, [wFruitX]
    ld c, a
    ld a, [wFruitY]
    ld b, a
    
    ; Calcular dirección en el mapa
    push bc
    ld hl, $9800
    ld a, b
    ld b, 0
    ld c, a
    
    ; Multiplicar Y por 32
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    
    add hl, bc
    pop bc
    
    ; Añadir X
    ld b, 0
    add hl, bc
    
    ; Dibujar tile de fruta
    ld a, TILE_FRUIT
    ld [hl], a
    
    ret

; ============================================
; DRAW SCORE
; Dibuja la puntuación en pantalla
; Simplificado: muestra solo dígitos
; ============================================
DrawScore:
    ; Convertir puntuación a dígitos
    ld a, [wScore]
    ld b, a
    
    ; Posición en pantalla (esquina superior derecha)
    ld hl, $9800 + 2
    
    ; Extraer centenas
    ld c, 0
.hundreds:
    ld a, b
    cp 100
    jp c, .tens
    sub 100
    ld b, a
    inc c
    jp .hundreds
    
.tens:
    ; Dibujar centenas
    ld a, c
    add $30                 ; Convertir a ASCII (tile)
    ld [hl+], a
    
    ; Extraer decenas
    ld c, 0
.tensLoop:
    ld a, b
    cp 10
    jp c, .units
    sub 10
    ld b, a
    inc c
    jp .tensLoop
    
.units:
    ; Dibujar decenas
    ld a, c
    add $30
    ld [hl+], a
    
    ; Dibujar unidades
    ld a, b
    add $30
    ld [hl], a
    
    ret