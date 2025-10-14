; ============================================
; COLLISION DETECTION - collision.asm
; Detección de colisiones con paredes y cuerpo
; ============================================
SECTION "COLLISION", ROM0
; ============================================
; CHECK COLLISIONS
; Verifica colisiones con paredes y con el propio cuerpo
; ============================================
CheckCollisions:
    ; Verificar colisión con paredes
    call CheckWallCollision
    
    ; Verificar colisión con el cuerpo
    call CheckSelfCollision
    
    ret

; ============================================
; CHECK WALL COLLISION
; Verifica si la cabeza chocó con una pared
; ============================================
CheckWallCollision:
    ld a, [wHeadX]
    
    ; Verificar borde izquierdo
    cp 1
    jp c, .collision
    
    ; Verificar borde derecho
    cp MAP_WIDTH - 1
    jp nc, .collision
    
    ; Verificar borde superior
    ld a, [wHeadY]
    cp 1
    jp c, .collision
    
    ; Verificar borde inferior
    cp MAP_HEIGHT - 1
    jp nc, .collision
    
    ret
    
.collision:
    ; Game Over
    ld a, 1
    ld [wGameOver], a
    ret

; ============================================
; CHECK SELF COLLISION
; Verifica si la cabeza chocó con el cuerpo
; ============================================
CheckSelfCollision:
    ld a, [wSnakeLength]
    cp 4                    ; No verificar si la longitud es < 4
    ret c
    
    ld a, [wHeadX]
    ld b, a
    ld a, [wHeadY]
    ld c, a
    
    ; Empezar desde el segmento 1 (después de la cabeza)
    ld hl, wSnakeX + 1
    ld de, wSnakeY + 1
    
    ld a, [wSnakeLength]
    dec a                   ; Longitud - 1 (no verificar la cabeza)
    ld l, a
    
.checkLoop:
    ; Comparar X
    ld a, [hl]
    cp b
    jp nz, .next
    
    ; Comparar Y
    ld a, [de]
    cp c
    jp z, .collision        ; Si X e Y coinciden = colisión
    
.next:
    inc hl
    inc de
    dec l
    jp nz, .checkLoop
    
    ret
    
.collision:
    ; Game Over
    ld a, 1
    ld [wGameOver], a
    ret

; ============================================
; CHECK FRUIT COLLISION
; Verifica si la cabeza comió la fruta
; ============================================
CheckFruitCollision:
    ; Verificar si hay fruta activa
    ld a, [wFruitActive]
    cp 1
    ret nz
    
    ; Comparar posición de cabeza con fruta
    ld a, [wHeadX]
    ld b, a
    ld a, [wFruitX]
    cp b
    ret nz
    
    ld a, [wHeadY]
    ld b, a
    ld a, [wFruitY]
    cp b
    ret nz
    
    ; Colisión con fruta
    call GrowSnake
    
    ; Desactivar fruta
    xor a
    ld [wFruitActive], a
    
    ; Generar nueva fruta
    call SpawnFruit
    
    ; Aumentar velocidad gradualmente
    call IncreaseSpeed
    
    ret

; ============================================
; INCREASE SPEED
; Reduce el delay entre movimientos (aumenta velocidad)
; ============================================
IncreaseSpeed:
    ld a, [wMoveDelay]
    cp 2                    ; Velocidad mínima
    ret z
    
    ; Reducir delay cada 5 puntos
    ld a, [wScore]
    and %00000111           ; Módulo 8
    ret nz
    
    ld a, [wMoveDelay]
    dec a
    ld [wMoveDelay], a
    
    ret