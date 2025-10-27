; ============================================
; SNAKE GAME - DEFINITIONS.INC
; Definiciones globales y constantes
; ============================================

; --- Hardware Registers ---
;;SECTION "Hardware", ROM0
DEF VRAM_TILE_DATA_START 	equ $8000
DEF VRAM_FONT_DATA_START 	equ $8800
DEF rLCDC   				equ $FF40
DEF rSTAT   				equ $FF41
DEF rSCY    				equ $FF42
DEF rSCX    				equ $FF43
DEF rLY     				equ $FF44
DEF rBGP    				equ $FF47
DEF rP1     				equ $FF00
DEF rIE                     equ $FFFF
DEF rDIV                    equ $FF04
DEF DPAD                    equ %00100000

;; --- Graphical Part ---
DEF DEFAULT_PAL 			equ %11100100
DEF OBP1					equ $FF48
DEF OAM_DIR					equ $FE00
DEF OAM_SIZE				equ 160

DEF rDMA 					equ $FF46

;; --- Map ---
DEF BGMAP0_START			equ $9800
DEF BGMAP1_START			equ $9C00
DEF MAP_HEIGHT				equ 16
DEF MAP_WIDTH				equ 20

;; --- Sprites ---
DEF SPRITE_SIZE				equ 4
DEF NUM_ENTITIES			equ 2
DEF CMP_SPRITES_TOTAL_BYTES equ SPRITE_SIZE*NUM_ENTITIES
DEF CMP_SPRITES_H			equ $0C

; --- Constantes del juego ---
DEF MENU_MAX_OPTIONS         equ 3
DEF MENU_DELAY_FRAMES       equ 10
DEF SNAKE_MAX_LENGTH    	equ 100     ; Longitud máxima de la serpiente
DEF VRAM_TILE_SIZE          equ $10     ; Tamaño de cada tile en bytes
DEF INITIAL_LENGTH      	equ 3       ; Longitud inicial de la serpiente
DEF FRAME_DELAY         	equ 8       ; Frames de delay entre movimientos

; --- Direcciones ---
DEF DIR_RIGHT   			equ 0
DEF DIR_LEFT    			equ 1
DEF DIR_UP      			equ 2
DEF DIR_DOWN    			equ 3

; --- Tiles ---
DEF TILE_EMPTY      		equ $00

; --- Tiles de la Cabeza ---
DEF TILE_HEAD_U     EQU $02
DEF TILE_HEAD_R     EQU $03
DEF TILE_HEAD_D     EQU $04
DEF TILE_HEAD_L     EQU $05

; --- Tiles del Cuerpo ---
DEF TILE_BODY_VERT  EQU $06 ; Vertical (arriba-abajo)
DEF TILE_BODY_HORIZ EQU $07 ; Horizontal (izq-der)

; --- Tiles de las Esquinas ---
DEF TILE_CORNER_UR  EQU $08 ; Arriba-Derecha
DEF TILE_CORNER_DR  EQU $09 ; Abajo-Derecha
DEF TILE_CORNER_DL  EQU $0A ; Abajo-Izquierda
DEF TILE_CORNER_LU  EQU $0B ; Izquierda-Arriba

DEF TILE_FRUIT      		equ $11
DEF TILE_WALL       		equ 4

; --- Teclas (P1 register bits) ---
DEF SELECT_PAD				equ $10
DEF SELECT_BUTTONS			equ $20
DEF SELECT_NONE				equ $30
DEF KEY_RIGHT   			equ 0
DEF KEY_LEFT    			equ 1
DEF KEY_DOWN    			equ 3
DEF KEY_UP      			equ 2
DEF KEY_A       			equ 4
DEF KEY_B       			equ 5
DEF KEY_SELECT				equ 6
DEF KEY_START				equ 7

; --- Variables en WRAM ---
;;SECTION "GameVars", WRAM0

; Serpiente - Array de posiciones (X, Y para cada segmento)
;;wSnakeX:        		DS SNAKE_MAX_LENGTH     ; Coordenadas X
;;wSnakeY:        		DS SNAKE_MAX_LENGTH     ; Coordenadas Y
;;wSnakeLength:   		DS 1                    ; Longitud actual
;;wSnakeDir:      		DS 1                    ; Dirección actual
;;wSnakeNewDir:   		DS 1                    ; Nueva dirección (buffer)

; Posición de la cabeza
;;wHeadX:         		DS 1
;;wHeadY:         		DS 1

; Fruta
;;;;wFruitX:        		DS 1
;;;;wFruitY:        		DS 1
;;;;wFruitActive:   		DS 1                    ; 0 = no activa, 1 = activa

; Juego
;;wScore:         		DS 2                    ; Puntuación (16-bit)
;;wGameOver:      		DS 1                    ; 0 = jugando, 1 = game over
;;wFrameCounter:  		DS 1                    ; Contador de frames
;;wMoveDelay:     		DS 1                    ; Delay entre movimientos

; RNG (generador aleatorio simple)
;;wRNGSeed:       		DS 2                    ; Semilla para números aleatorios