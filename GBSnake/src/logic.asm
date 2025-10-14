; ============================================
; SNAKE LOGIC - snake_logic.asm
; Lógica de la serpiente: inicialización, movimiento
; ============================================
SECTION "LOGIC", ROM0
; ============================================
; INIT SNAKE
; Inicializa la serpiente en el centro del mapa
; ============================================
InitSnake:
    ; Longitud inicial
    ld a, INITIAL_LENGTH
    ld [wSnakeLength], a
    
    ; Dirección inicial (derecha)
    ld a, DIR_RIGHT
    ld [wSnakeDir], a
    ld [wSnakeNewDir], a
    
    ; Posición inicial (centro del mapa)
    ld a, MAP_WIDTH / 2
    ld [wHeadX], a
    ld a, MAP_HEIGHT / 2
    ld [wHeadY], a
    
    ; Inicializar array de posiciones
    ld hl, wSnakeX
    ld de, wSnakeY
    ld b, INITIAL_LENGTH
    ld c, 0                 ; Offset X
    
.initLoop:
    ld a, [wHeadX]
    sub c                   ; X - offset
    ld [hl+], a
    
    ld a, [wHeadY]
    ld [de], a
    inc de
    
    inc c                   ; Incrementar offset
    dec b
    jp nz, .initLoop
    
    ret

; ============================================
; UPDATE DIRECTION
; Actualiza la dirección basándose en el input
; Previene movimiento en dirección opuesta
; ============================================
UpdateDirection:
    ld a, [wSnakeNewDir]
    ld b, a
    ld a, [wSnakeDir]
    ld c, a
    
    ; Verificar si la nueva dirección es opuesta a la actual
    ; Derecha (0) vs Izquierda (1)
    ld a, b
    cp DIR_RIGHT
    jp nz, .checkLeft
    ld a, c
    cp DIR_LEFT
    ret z                   ; Si actual es izquierda, ignorar
    jp .applyDir
    
.checkLeft:
    ld a, b
    cp DIR_LEFT
    jp nz, .checkUp
    ld a, c
    cp DIR_RIGHT
    ret z                   ; Si actual es derecha, ignorar
    jp .applyDir
    
.checkUp:
    ld a, b
    cp DIR_UP
    jp nz, .checkDown
    ld a, c
    cp DIR_DOWN
    ret z                   ; Si actual es abajo, ignorar
    jp .applyDir
    
.checkDown:
    ld a, b
    cp DIR_DOWN
    ret nz
    ld a, c
    cp DIR_UP
    ret z                   ; Si actual es arriba, ignorar
    
.applyDir:
    ld a, b
    ld [wSnakeDir], a
    ret

; ============================================
; MOVE SNAKE
; Mueve la serpiente en la dirección actual
; ============================================
MoveSnake:
    ; Calcular nueva posición de la cabeza
    ld a, [wHeadX]
    ld b, a
    ld a, [wHeadY]
    ld c, a
    
    ; Aplicar movimiento según dirección
    ld a, [wSnakeDir]
    cp DIR_RIGHT
    jp z, .moveRight
    cp DIR_LEFT
    jp z, .moveLeft
    cp DIR_UP
    jp z, .moveUp
    cp DIR_DOWN
    jp z, .moveDown
    ret
    
.moveRight:
    inc b
    jp .updateSnake
    
.moveLeft:
    dec b
    jp .updateSnake
    
.moveUp:
    dec c
    jp .updateSnake
    
.moveDown:
    inc c
    
.updateSnake:
    ; Guardar nueva posición de cabeza temporalmente
    ld a, b
    ld [wHeadX], a
    ld a, c
    ld [wHeadY], a
    
    ; Mover cuerpo (desde la cola hacia la cabeza)
    call ShiftSnakeBody
    
    ; Actualizar cabeza en el array
    ld a, [wHeadX]
    ld [wSnakeX], a
    ld a, [wHeadY]
    ld [wSnakeY], a
    
    ret

; ============================================
; SHIFT SNAKE BODY
; Desplaza todos los segmentos del cuerpo
; (excepto la cabeza) una posición hacia atrás
; ============================================
ShiftSnakeBody:
    ld a, [wSnakeLength]
    dec a                   ; Longitud - 1 (no mover la cabeza)
    ret z                   ; Si longitud es 1, no hay cuerpo
    
    ld b, a                 ; B = contador
    
    ; Empezar desde el final
    ld h, HIGH(wSnakeX)
    ld l, LOW(wSnakeX)
    ld d, HIGH(wSnakeY)
    ld e, LOW(wSnakeY)
    
    ; Avanzar al último segmento
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a
    
    ld a, [wSnakeLength]
    dec a
    add e
    ld e, a
    ld a, 0
    adc d
    ld d, a
    
.shiftLoop:
    ; Copiar posición del segmento anterior
    push hl
    push de
    
    dec hl
    dec de
    
    ld a, [hl]
    inc hl
    ld [hl], a
    
    ld a, [de]
    inc de
    ld [de], a
    
    pop de
    pop hl
    
    dec hl
    dec de
    
    dec b
    jp nz, .shiftLoop
    
    ret

; ============================================
; GROW SNAKE
; Incrementa la longitud de la serpiente
; ============================================
GrowSnake:
    ld a, [wSnakeLength]
    cp SNAKE_MAX_LENGTH
    ret z                   ; No crecer si ya está en el máximo
    
    inc a
    ld [wSnakeLength], a
    
    ; Incrementar puntuación
    ld hl, wScore
    inc [hl]
    ret nz
    inc hl
    inc [hl]                ; Incrementar byte alto si hay carry
    
    ret