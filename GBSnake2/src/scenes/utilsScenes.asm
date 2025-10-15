INCLUDE "constants.inc"

;; --- Auxiliar functions ---
SECTION "Utils Scenes", ROM0

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


update_logo_intro::
	;; Comprobamos si alguna de las dos serpientes ha llegado a algún tile
	ld hl, IntroOAMBuffer
	ret

copy_OAM_buffer::
	ld hl, IntroOAMBuffer
	ld de, OAM_DIR
	ld b, 24
	call memcpy_256
	ret

show_message_intro::
	ret

wait_Start::
	ld a, [JoyPadState]
	bit 3, a
	jr z, wait_Start
	ret