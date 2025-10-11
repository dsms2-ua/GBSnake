; ============================================
; SNAKE GAME - MAIN.ASM
; Archivo principal del juego
; ============================================

INCLUDE "definitions.inc"
INCLUDE "logic.asm"
INCLUDE "collision.asm"
INCLUDE "fruit.asm"
INCLUDE "input.asm"
INCLUDE "render.asm"

SECTION "Header", ROM0[$100]
    nop
    jp Start

SECTION "Game", ROM0[$150]

Start:
    di                      ; Deshabilitar interrupciones
    
    ; Inicializar stack pointer
    ld sp, $FFFE
    
    ; Esperar VBlank
    call WaitVBlank
    
    ; Apagar LCD
    xor a
    ld [rLCDC], a
    
    ; Inicializar paleta
    ld a, %11100100         ; Paleta: 3=negro, 2=gris oscuro, 1=gris claro, 0=blanco
    ld [rBGP], a
    
    ; Cargar tiles
    call LoadTiles
    
    ; Inicializar mapa
    call InitMap
    
    ; Inicializar juego
    call InitGame
    
    ; Encender LCD
    ld a, %10010001         ; LCD on, BG on, BG tile map $9800
    ld [rLCDC], a
    
    ei                      ; Habilitar interrupciones

; ============================================
; GAME LOOP PRINCIPAL
; ============================================
GameLoop:
    ; Esperar VBlank
    call WaitVBlank
    
    ; Incrementar frame counter
    ld hl, wFrameCounter
    inc [hl]
    
    ; Verificar si el juego ha terminado
    ld a, [wGameOver]
    cp 1
    jp z, GameOverLoop
    
    ; Leer input
    call ReadInput
    
    ; Verificar si es tiempo de mover
    ld a, [wFrameCounter]
    ld b, a
    ld a, [wMoveDelay]
    cp b
    jp nz, .skipMove
    
    ; Reset frame counter
    xor a
    ld [wFrameCounter], a
    
    ; Actualizar dirección
    call UpdateDirection
    
    ; Mover serpiente
    call MoveSnake
    
    ; Verificar colisiones
    call CheckCollisions
    
    ; Verificar si comió fruta
    call CheckFruitCollision
    
.skipMove:
    ; Renderizar
    call RenderGame
    
    jp GameLoop

; ============================================
; GAME OVER LOOP
; ============================================
GameOverLoop:
    call WaitVBlank
    call ReadInput
    
    ; Presionar A para reiniciar
    ld a, [wP1Input]
    and KEY_A
    jp z, .restart
    
    jp GameOverLoop
    
.restart:
    call InitGame
    jp GameLoop

; ============================================
; INICIALIZAR JUEGO
; ============================================
InitGame:
    ; Reiniciar variables
    xor a
    ld [wGameOver], a
    ld [wFrameCounter], a
    ld [wScore], a
    ld [wScore + 1], a
    
    ; Configurar delay de movimiento
    ld a, FRAME_DELAY
    ld [wMoveDelay], a
    
    ; Inicializar serpiente
    call InitSnake
    
    ; Generar primera fruta
    call SpawnFruit
    
    ret

; ============================================
; WAIT VBLANK
; ============================================
WaitVBlank:
    ld a, [rLY]
    cp 144
    jp nz, WaitVBlank
    ret

; ============================================
; LOAD TILES (simplificado)
; ============================================
LoadTiles:
    ; Aquí cargarías los tiles gráficos
    ; Por simplicidad, usamos tiles por defecto
    ret

; ============================================
; INIT MAP
; ============================================
InitMap:
    ; Limpiar mapa
    ld hl, $9800            ; Dirección del tile map
    ld bc, 32 * 32          ; Tamaño del mapa
    xor a                   ; Tile vacío
    
.clearLoop:
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jp nz, .clearLoop
    
    ; Dibujar paredes (bordes)
    call DrawWalls
    
    ret

; ============================================
; DRAW WALLS
; ============================================
DrawWalls:
    ; Pared superior
    ld hl, $9800
    ld b, MAP_WIDTH
    ld a, TILE_WALL
.topWall:
    ld [hl+], a
    dec b
    jp nz, .topWall
    
    ; Pared inferior
    ld hl, $9800 + (32 * (MAP_HEIGHT - 1))
    ld b, MAP_WIDTH
    ld a, TILE_WALL
.bottomWall:
    ld [hl+], a
    dec b
    jp nz, .bottomWall
    
    ; Paredes laterales
    ld c, MAP_HEIGHT - 2    ; Altura menos las esquinas
    ld hl, $9800 + 32       ; Segunda fila
    ld a, TILE_WALL
    
.sideWalls:
    ld [hl], a              ; Pared izquierda
    ld b, MAP_WIDTH - 1
    add hl, bc              ; Mover a la derecha
    ld [hl], a              ; Pared derecha
    
    ; Siguiente fila
    ld bc, 32 - (MAP_WIDTH - 1)
    add hl, bc
    
    dec c
    jp nz, .sideWalls
    
    ret