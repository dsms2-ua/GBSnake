INCLUDE "constants.inc"

SECTION "Game Over Variables", WRAM0

GameOverOption::    DS 1
GameOverDelay::       DS 1

SECTION "Game Over Code", ROM0

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


game_over_init::
    ;; La pantalla está apagada

    ;; Pintamos el Game Over
    call draw_game_over

    ;; Pintamos el texto para las opciones
    call draw_game_over_options

    ;; Inicializamos las variables
    xor a
    ld [GameOverOption], a

    ld a, GAME_OVER_DELAY_FRAMES
    ld [GameOverDelay], a

    ;; Comprobamos si tenemos un nuevo récord
    call save_high_score

    ;; Pintamos el score
    call draw_score

    call enciende_pantalla

    ret


game_over_run::
    ;; Esperamos las opciones (A para Restart, Start para Menu)
.loop
    call read_joypad
    call game_over_wait_option

    ld hl, GameOverOption
    ld a, [hl]
    cp 0
    jr z, .loop ;; Si no se ha modificado la opción, volvemos arriba
    ret


game_over_clean::
    call apaga_pantalla

    ;; Limpiamos el Game Over y las opciones
    call clean_game_over_pantalla

    ret