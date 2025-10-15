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

;; --- Graphical Part ---
DEF DEFAULT_PAL 			equ %11100100
DEF OBP1					equ $FF48
DEF OAM_DIR					equ $FE00
DEF OAM_SIZE				equ 160

DEF rDMA 					equ $FF46

;; --- Map ---
DEF BGMAP0					equ $9800
DEF BGMAP1_START			equ $9C00
DEF MAP_HEIGHT				equ 16
DEF MAP_WIDTH				equ 20

;; --- Sprites ---
DEF SPRITE_SIZE				equ 4
DEF NUM_ENTITIES			equ 2
DEF CMP_SPRITES_TOTAL_BYTES equ SPRITE_SIZE*NUM_ENTITIES
DEF CMP_SPRITES_H			equ $0C

; --- Constantes del juego ---
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
DEF TILE_EMPTY      		equ 0
DEF TILE_SNAKE_HEAD 		equ 1
DEF TILE_SNAKE_BODY 		equ 2
DEF TILE_FRUIT      		equ 3
DEF TILE_WALL       		equ 4

; --- Teclas (P1 register bits) ---
DEF SELECT_PAD				equ $10
DEF SELECT_BUTTONS			equ $20
DEF SELECT_NONE				equ $30
DEF KEY_RIGHT   			equ 4
DEF KEY_LEFT    			equ 5
DEF KEY_DOWN    			equ 6
DEF KEY_UP      			equ 7
DEF KEY_A       			equ 0
DEF KEY_B       			equ 1
DEF KEY_SELECT				equ 2
DEF KEY_START				equ 3

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