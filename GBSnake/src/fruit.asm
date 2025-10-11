; ============================================
; FRUIT MANAGEMENT - fruit.asm
; Generación y gestión de frutas
; ============================================
SECTION "FRUIT", ROM0
; ============================================
; SPAWN FRUIT
; Genera una nueva fruta en posición aleatoria
; que no colisione con la serpiente
; ============================================
SpawnFruit:
    ld b, 50                ; Máximo de intentos
    
.trySpawn:
    ; Generar posición X aleatoria
    call GetRandomNumber
    ld a, c
    and %00011111           ; Limitar a 0-31
    cp MAP_WIDTH - 2
    jp nc, .trySpawn        ; Si está fuera del rango, reintentar
    cp 1
    jp c, .trySpawn
    ld [wFruitX], a
    
    ; Generar posición Y aleatoria
    call GetRandomNumber
    ld a, c
    and %00011111           ; Limitar a 0-31
    cp MAP_HEIGHT - 2
    jp nc, .trySpawn        ; Si está fuera del rango, reintentar
    cp 1
    jp c, .trySpawn
    ld [wFruitY], a
    
    ; Verificar que no esté sobre la serpiente
    call CheckFruitOnSnake
    cp 1
    jp z, .collision
    
    ; Activar fruta
    ld a, 1
    ld [wFruitActive], a
    ret
    
.collision:
    dec b
    jp nz, .trySpawn
    
    ; Si no se pudo generar después de 50 intentos, forzar una posición
    ld a, 10
    ld [wFruitX], a
    ld [wFruitY], a
    ld a, 1
    ld [wFruitActive], a
    ret

; ============================================
; CHECK FRUIT ON SNAKE
; Verifica si la fruta está sobre algún segmento
; Retorna: A = 1 si colisiona, 0 si no
; ============================================
CheckFruitOnSnake:
    ld a, [wFruitX]
    ld b, a
    ld a, [wFruitY]
    ld c, a
    
    ld hl, wSnakeX
    ld de, wSnakeY
    
    ld a, [wSnakeLength]
    ld l, a
    
.checkLoop:
    ; Comparar X
    push hl
    ld a, [hl]
    cp b
    jp nz, .next
    
    ; Comparar Y
    ld a, [de]
    cp c
    jp z, .collision
    
.next:
    pop hl
    inc hl
    inc de
    dec l
    jp nz, .checkLoop
    
    xor a                   ; No colisión
    ret
    
.collision:
    pop hl
    ld a, 1                 ; Colisión
    ret

; ============================================
; GET RANDOM NUMBER
; Genera un número pseudo-aleatorio simple
; Retorna: C = número aleatorio (0-255)
; ============================================
GetRandomNumber:
    push hl
    push de
    
    ; Leer el estado actual de LY (línea de escaneo)
    ld a, [rLY]
    ld d, a
    
    ; Cargar seed
    ld hl, wRNGSeed
    ld a, [hl+]
    ld b, a
    ld a, [hl]
    ld c, a
    
    ; Algoritmo LCG simple: seed = (seed * 5 + d) & 0xFFFF
    ; Multiplicar por 5
    ld h, b
    ld l, c
    add hl, hl              ; * 2
    add hl, hl              ; * 4
    ld a, l
    add c
    ld c, a
    ld a, h
    adc b
    ld b, a                 ; + seed original = * 5
    
    ; Sumar LY
    ld a, c
    add d
    ld c, a
    ld a, b
    adc 0
    ld b, a
    
    ; Guardar nuevo seed
    ld hl, wRNGSeed
    ld [hl], b
    inc hl
    ld [hl], c
    
    pop de
    pop hl
    ret