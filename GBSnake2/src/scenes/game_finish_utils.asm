INCLUDE "constants.inc"

SECTION "Game Finish Utils", ROM0

draw_game_over::
    ld hl, TextGameOver1
    ld de, $9846
    ld bc, TextGameOver1End - TextGameOver1
    call copy_vram

	ld hl, TextGameOver2
    ld de, $9866
    ld bc, TextGameOver2End - TextGameOver2
    call copy_vram

	ld hl, TextGameOver3
    ld de, $98A6
    ld bc, TextGameOver3End - TextGameOver3
    call copy_vram

	ld hl, TextGameOver4
    ld de, $98C6
    ld bc, TextGameOver4End - TextGameOver4
    call copy_vram

    ret

draw_game_win::
    ld hl, TextGameWin1
    ld de, $9883
    ld bc, TextGameWin1End - TextGameWin1
    call copy_vram

	ld hl, TextGameWin2
    ld de, $98A3
    ld bc, TextGameWin2End - TextGameWin2
    call copy_vram

    ret

draw_game_finish_options::
	ld hl, TextScore
	ld de, $9905
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

draw_score_finish::
    ;; Leemos el modo de juego
    ld hl, Score
	ld a, [hl+]
    ld h, [hl]
    ld l, a

.calc_cent
    ld b, 0
.cent_loop
    ld a, l
    cp 100
    jr c, .calc_dec
    sub 100
    ld l, a
    inc b
    jr .cent_loop

.calc_dec
    ld c, 0
.dec_loop
    ld a, l
    cp 10
    jr c, .draw
    sub 10
    ld l, a
    inc c
    jr .dec_loop

.draw
    ld d, l
    ld a, b
    add a, $9B ;; $9B es la posición del 0 en tiles
    ld b, a
    ld a, c
    add a, $9B
    ld c, a
    ld a, d
    add a, $9B
    ld d, a

    ld hl, $990B

    di
    call WaitVRAMSafe
    ld [hl], b
    inc hl
    call WaitVRAMSafe
    ld [hl], c
    inc hl
    call WaitVRAMSafe
    ld [hl], d
    ei

	;; Comprobamos si es nuevo récord para pintar
	ld hl, Score
	ld a, [Score]
	ld e, a

	ld a, [MenuOption]
    ld c, a
    ld b, 0

    ld hl, HighScores
    add hl, bc
    ld a, [hl]

	cp e
	jr nc, .exit

.new_record
	;; Pintamos el new record
	ld hl, TextNewRecord
    ld de, $9944
    ld bc, TextNewRecordEnd - TextNewRecord
    call copy_vram

.exit	
	ret

game_finish_wait_option::
	;; Comprobamos si se cumple el delay
	ld hl, GameFinishDelay
	ld a, [hl]

	or a
	jr z, .check_input
	dec [hl]

	ret

.check_input
	ld a, [JoyPadState]
	ld hl, GameFinishOption

	bit KEY_A, a
	jr z, .check_start

	set 0, [hl] ;; Ponemos el primer bit en activo si es Restart
	jp .exit

.check_start
	bit KEY_START, a
	jr z, .exit

	set 1, [hl] ;; Ponemos el segundo bit en activo si es menu
    ld hl, MenuOption
    ld a, 4
    ld [hl], a
.exit
	ret

clean_game_finish_common::
	ld hl, $9905
	ld b, 9
	ld a, $00
	call memset_256

	ld hl, $9944
	ld b, 11
	ld a, $00
	call memset_256

	ld hl, $99A5
	ld b, 11
	ld a, $00
	call memset_256

	ld hl, $99E3
	ld b, 15
	ld a, $00
	call memset_256

	ret

clean_game_finish_win::
	ld hl, $9883
	ld b, 14
	ld a, $00
	call memset_256

	ld hl, $98A3
	ld b, 14
	ld a, $00
	call memset_256

    ret

clean_game_finish_lose::
	ld hl, $9846
	ld b, 8
	ld a, $00
	call memset_256

	ld hl, $9866
	ld b, 8
	ld a, $00
	call memset_256

	ld hl, $98A6
	ld b, 8
	ld a, $00
	call memset_256

	ld hl, $98C6
	ld b, 8
	ld a, $00
	call memset_256

    ret