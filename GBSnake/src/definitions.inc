; ============================================
; SNAKE GAME - DEFINITIONS.INC
; Definiciones globales y constantes
; ============================================

; --- Hardware Registers ---
SECTION "Hardware", ROM0
def rLCDC   EQU $FF40
def rSTAT   EQU $FF41
def rSCY    EQU $FF42
def rSCX    EQU $FF43
def rLY     EQU $FF44
def rBGP    EQU $FF47
def rP1     EQU $FF00

; --- Constantes del juego ---
def SNAKE_MAX_LENGTH    EQU 100     ; Longitud máxima de la serpiente
def TILE_SIZE           EQU 8       ; Tamaño de cada tile en píxeles
def MAP_WIDTH           EQU 20      ; Ancho del mapa en tiles
def MAP_HEIGHT          EQU 18      ; Alto del mapa en tiles
def INITIAL_LENGTH      EQU 3       ; Longitud inicial de la serpiente
def FRAME_DELAY         EQU 8       ; Frames de delay entre movimientos

; --- Direcciones ---
def DIR_RIGHT   EQU 0
def DIR_LEFT    EQU 1
def DIR_UP      EQU 2
def DIR_DOWN    EQU 3

; --- Tiles ---
def TILE_EMPTY      EQU 0
def TILE_SNAKE_HEAD EQU 1
def TILE_SNAKE_BODY EQU 2
def TILE_FRUIT      EQU 3
def TILE_WALL       EQU 4

; --- Teclas (P1 register bits) ---
def KEY_RIGHT   EQU %00000001
def KEY_LEFT    EQU %00000010
def KEY_UP      EQU %00000100
def KEY_DOWN    EQU %00001000
def KEY_A       EQU %00010000
def KEY_B       EQU %00100000

; --- Variables en WRAM ---
SECTION "GameVars", WRAM0

; Serpiente - Array de posiciones (X, Y para cada segmento)
wSnakeX:        DS SNAKE_MAX_LENGTH     ; Coordenadas X
wSnakeY:        DS SNAKE_MAX_LENGTH     ; Coordenadas Y
wSnakeLength:   DS 1                    ; Longitud actual
wSnakeDir:      DS 1                    ; Dirección actual
wSnakeNewDir:   DS 1                    ; Nueva dirección (buffer)

; Posición de la cabeza
wHeadX:         DS 1
wHeadY:         DS 1

; Fruta
wFruitX:        DS 1
wFruitY:        DS 1
wFruitActive:   DS 1                    ; 0 = no activa, 1 = activa

; Juego
wScore:         DS 2                    ; Puntuación (16-bit)
wGameOver:      DS 1                    ; 0 = jugando, 1 = game over
wFrameCounter:  DS 1                    ; Contador de frames
wMoveDelay:     DS 1                    ; Delay entre movimientos

; RNG (generador aleatorio simple)
wRNGSeed:       DS 2                    ; Semilla para números aleatorios