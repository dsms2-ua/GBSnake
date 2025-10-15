INCLUDE "constants.inc"

;; --- Auxiliar functions ---
SECTION "Utils Scenes Intro", ROM0

init_sprites_intro::
	ld hl, IntroOAMBuffer

	;; Primera serpiente
	ld [hl], 80
	inc hl
	ld [hl], 24
	inc hl
	ld [hl], $1B
	inc hl
	ld [hl], 0
	inc hl

	ld [hl], 80
	inc hl
	ld [hl], 16
	inc hl
	ld [hl], $1F
	inc hl
	ld [hl], 0
	inc hl

	ld [hl], 80
	inc hl
	ld [hl], 8
	inc hl
	ld [hl], $25
	inc hl
	ld [hl], 0
	inc hl


	;; Segunda serpiente
	ld [hl], 88
	inc hl
	ld [hl], 160
	inc hl
	ld [hl], $27
	inc hl
	ld [hl], 0
	inc hl

	ld [hl], 88
	inc hl
	ld [hl], 152
	inc hl
	ld [hl], $1F
	inc hl
	ld [hl], 0
	inc hl

	ld [hl], 88
	inc hl
	ld [hl], 144
	inc hl
	ld [hl], $1D
	inc hl
	ld [hl], 0
	
	ret

move_snake_intro::
	;; Primero comprobamos si tenemos que movernos
	ld a, [IntroSnakeCounter]
	inc a
	ld [IntroSnakeCounter], a

	ld a, [IntroSnakeSpeed]
	ld b, a
	ld a, [IntroSnakeCounter]
	cp b
	jr nz, .skip_move

	;; Reseteamos el contador
	xor a
	ld [IntroSnakeCounter], a

	;; Actualizamos el contador de iteraciones
	ld a, [CounterIterations]
	dec a
	ld [CounterIterations], a

	;; Primera serpiente
	ld hl, IntroOAMBuffer + 1
	ld a, [hl] ;; Accedemos a la X porque primero se guarda la Y
	add 4
	ld [hl], a

	ld hl, IntroOAMBuffer + 5
	ld a, [hl]
	add 4
	ld [hl], a

	ld hl, IntroOAMBuffer + 9
	ld a, [hl]
	add 4
	ld [hl], a

	;; Segunda serpiente
	ld hl, IntroOAMBuffer + 13
	ld a, [hl]
	sub 4
	ld [hl], a

	ld hl, IntroOAMBuffer + 17
	ld a, [hl]
	sub 4
	ld [hl], a

	ld hl, IntroOAMBuffer + 21
	ld a, [hl]
	sub 4
	ld [hl], a

.skip_move
	ret

update_logo_intro::
.getTileHead
	;; Comprobamos si alguna de las dos serpientes ha llegado a algún tile
	ld hl, IntroOAMBuffer + 1 ;; Cargamos la posición de la primera cabeza
	ld a, [hl]
	;; Dividimos entre 8 porque la dirección del tile es X/8
	srl a
	srl a
	srl a
	ld b, a

	ld hl, IntroOAMBuffer + 13 ;; Ahora la segunda
	ld a, [hl]
	sub 16
	srl a
	srl a
	srl a
	;;sub 8 ;; Con la segunda serpiente tenemos que comprobar por detrás
	ld c, a

	push bc ;; Guardamos bc porque lo vamos a usar mas tarde

.comproveFirst
	ld hl, $9900
	ld a, b
	ld d, 0
	ld e, a
	add hl, de ;; HL => $9900 + a
	ld a, [hl]
	cp $00
	jr z, .comproveSecond
	call set_tile_to_0

.comproveSecond
	;; Recuperamos el valor de bc
	pop bc

	ld hl, $9920
	ld a, c
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hl]
	cp $00
	jr z, .done
	call set_tile_to_0

.done
	ret

copy_OAM_buffer::
	ld hl, IntroOAMBuffer
	ld de, OAM_DIR
	ld b, 24
	call memcpy_256
	ret

show_message_intro::
	ld hl, TextPress
	ld de, $9988
	ld bc, TextPressEnd - TextPress
	call copy_vram

	ld hl, TextStart
	ld de, $99C8
	ld bc, TextStartEnd - TextStart
	call copy_vram
	ret

wait_start::
	call read_joypad
	ld a, [JoyPadState]
	bit KEY_START, a
	jr z, wait_start
	ret

;; ---------------
;; Set tile value to $00 (blank)
;; 		INPUT
;;		    HL => Address of the tile
set_tile_to_0:
	ld a, $00
	ld [hl], a
	ret

;; ---------------
;; Clean window values of the message
clean_window_intro::
	ld hl, $9988
	ld b, 5
	ld a, $00
	call memset_256

	ld hl, $99C8
	ld b, 5
	ld a, $00
	call memset_256

	ret