INCLUDE "constants.inc"

SECTION "Game Finish Variables", WRAM0

GameFinishOption::       DS 1
GameFinishDelay::       DS 1

SECTION "Game Finish Code", ROM0

TextGameOver1::
    DB $40, $41, $48, $49, $4E, $4F, $4C, $4D
TextGameOver1End::

TextGameOver2::
    DB $56, $57, $5E, $5F, $64, $65, $62, $63
TextGameOver2End::

TextGameOver3::
    DB $50, $51, $52, $53, $4C, $4D, $54, $55
TextGameOver3End::

TextGameOver4::
    DB $66, $67, $68, $69, $62, $63, $6A, $6B
TextGameOver4End::

TextRestart::
    DB $91, $84, $92, $93, $80, $91, $93, $00, $A7, $80, $A8
TextRestartEnd::

TextMenu::
    DB $86, $8E, $00, $8C, $84, $8D, $94, $00, $A7, $92, $93, $80, $91, $93, $A8
TextMenuEnd::

TextNewRecord::
    DB $8D, $84, $96, $00, $91, $84, $82, $8E, $91, $83, $A5
TextNewRecordEnd::

TextGameWin1::
    DB $6C, $6E, $70, $72, $46, $47, $46, $47, $4C, $4D, $54, $55, $74, $76
TextGameWin1End::

TextGameWin2::
    DB $6D, $6F, $71, $73, $5C, $5D, $5C, $5D, $62, $63, $6A, $6B, $75, $77
TextGameWin2End::


game_finish_init::
    ;; La pantalla está apagada

    ;; Leemos la variable para ver si hemos ganado o hemos perdido
    ld a, [GameFinish]
    cp 0
    jr z, .game_over

    call draw_game_win
    jp .paint_text

.game_over
    call draw_game_over

.paint_text
    ;; Pintamos el texto para las opciones
    call draw_game_finish_options

    ;; Inicializamos las variables
    xor a
    ld [GameFinishOption], a

    ld a, GAME_OVER_DELAY_FRAMES
    ld [GameFinishDelay], a

    ;; Pintamos el score
    call draw_score_finish

    ;; Comprobamos si tenemos un nuevo récord
    call save_high_score

    call enciende_pantalla

    ret


game_finish_run::
    ;; Esperamos las opciones (A para Restart, Start para Menu)
.loop
    call read_joypad
    call game_finish_wait_option

    ld hl, GameFinishOption
    ld a, [hl]
    cp 0
    jr z, .loop ;; Si no se ha modificado la opción, volvemos arriba
    ret


game_finish_clean::
    call apaga_pantalla

    ;; Limpiamos las opciones comunes
    call clean_game_finish_common

    ;; Ahora limpiamos el texto principal
    ld hl, GameFinish
    ld a, [hl]
    cp 0
    jr z, .clean_game_over

    call clean_game_finish_win
    jp .exit

.clean_game_over
    call clean_game_finish_lose

.exit
    ret