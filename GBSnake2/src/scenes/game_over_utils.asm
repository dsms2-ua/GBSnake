INCLUDE "constants.inc"

SECTION "Game Over Utils", ROM0

draw_game_over::
    ld hl, TextGameOver1
    ld de, $9886
    ld bc, TextGameOver1End - TextGameOver1
    call copy_vram

	ld hl, TextGameOver2
    ld de, $98A6
    ld bc, TextGameOver2End - TextGameOver2
    call copy_vram

	ld hl, TextGameOver3
    ld de, $98E6
    ld bc, TextGameOver3End - TextGameOver3
    call copy_vram

	ld hl, TextGameOver4
    ld de, $9906
    ld bc, TextGameOver4End - TextGameOver4
    call copy_vram

    ret

draw_game_over_options::
	ld hl, TextScore
	ld de, $9945
	ld bc, TextScoreEnd - TextScore
	call copy_vram

    ld hl, TextRestart
    ld de, $99A5
    ld bc, TextRestartEnd - TextRestart
    call copy_vram

	ld hl, TextMenu
    ld de, $99E3
    ld bc, TextMenuEnd - TextMenu
    call copy_vram

    ret

game_over_wait_option::
	;; Comprobamos si se cumple el delay
	ld hl, GameOverDelay
	ld a, [hl]

	or a
	jr z, .check_input
	dec [hl]

	ret

.check_input
	ld a, [JoyPadState]
	ld hl, GameOverOption

	bit KEY_A, a
	jr z, .check_start

	set 0, [hl] ;; Ponemos el primer bit en activo si es Restart
	jp .exit

.check_start
	bit KEY_START, a
	jr z, .exit

	set 1, [hl] ;; Ponemos el segundo bit en activo si es menu
.exit
	ret

clean_game_over_pantalla::
	ld hl, $9866
	ld b, 8
	ld a, $00
	call memset_256

	ld hl, $9886
	ld b, 8
	ld a, $00
	call memset_256

	ld hl, $98C6
	ld b, 8
	ld a, $00
	call memset_256

	ld hl, $98E6
	ld b, 8
	ld a, $00
	call memset_256

	;; --------------

	ld hl, $99A5
	ld b, 11
	ld a, $00
	call memset_256

	ld hl, $99E3
	ld b, 15
	ld a, $00
	call memset_256

	ret