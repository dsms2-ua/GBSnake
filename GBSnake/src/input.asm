; ============================================
; INPUT HANDLING - input.asm
; Lectura y procesamiento de controles
; ============================================
SECTION "InputVars", R0M0
wP1Input: DS 1              ; Estado actual del input

; ============================================
; READ INPUT
; Lee el estado de los botones y actualiza dirección
; ============================================
ReadInput:
    ; Leer botones direccionales
    ld a, $20               ; Seleccionar D-pad
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]             ; Leer varias veces para estabilizar
    cpl                     ; Invertir bits (0 = presionado)
    and $0F                 ; Máscara para los 4 bits inferiores
    ld b, a
    
    ; Leer botones A/B/Select/Start
    ld a, $10               ; Seleccionar botones
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    cpl
    and $0F
    swap a                  ; Mover a nibble superior
    or b                    ; Combinar con D-pad
    
    ld [wP1Input], a
    
    ; Resetear P1
    ld a, $30
    ld [rP1], a
    
    ; Procesar input
    call ProcessInput
    
    ret

; ============================================
; PROCESS INPUT
; Procesa el input y actualiza la dirección
; ============================================
ProcessInput:
    ld a, [wP1Input]
    
    ; Verificar RIGHT
    bit 0, a
    jp nz, .checkLeft
    ld a, DIR_RIGHT
    ld [wSnakeNewDir], a
    ret
    
.checkLeft:
    ld a, [wP1Input]
    bit 1, a
    jp nz, .checkUp
    ld a, DIR_LEFT
    ld [wSnakeNewDir], a
    ret
    
.checkUp:
    ld a, [wP1Input]
    bit 2, a
    jp nz, .checkDown
    ld a, DIR_UP
    ld [wSnakeNewDir], a
    ret
    
.checkDown:
    ld a, [wP1Input]
    bit 3, a
    ret z
    ld a, DIR_DOWN
    ld [wSnakeNewDir], a
    ret