INCLUDE "constants.inc"

SECTION "Menu Variables", WRAM0

MenuOption::    DS 1
MenuDelay::     DS 1

SECTION "Menu Code", ROM0

MenuPositions::
    DB 64, 36
    DB 80, 36
    DB 94, 36

TextClassic::
    DB $82, $8B, $80, $92, $92, $88, $82
TextClassicEnd::

TextCaos::
    DB $82, $80, $8E, $92
TextCaosEnd::

TextExit::
    DB $84, $97, $88, $93
TextExitEnd::

TextPressA::
    DB $8F, $91, $84, $92, $92, $00, $80
TextPressAEnd::

menu_init::
    ;; La pantalla ya está apagada del clean de la intro

    ;; Copiamos los tiles sobreescribiendo los que ya están
    ld hl, assets
    ld de, VRAM_TILE_DATA_START
    ld bc, 26*VRAM_TILE_SIZE
    call copy_vram

    ;; Mostramos el logo
    call show_logo_menu

    ;; Mostramos las opciones de juego
    call show_text_menu

    ;; Dibujamos el sprite del selector
    call draw_selector_sprite

    ;; Encendemos la pantalla
    call enciende_pantalla

    ;; Inicializamos las variables
    xor a
    ld [MenuOption], a

    ld a, MENU_DELAY_FRAMES
    ld [MenuDelay], a

    ret

menu_run::    
.menu_loop
    call wait_vblank_start

    call read_joypad

    call update_menu_selector

    call copy_OAM_buffer_menu

    ld a, [JoyPadState]
    bit KEY_A, a
    jr z, .menu_loop
    
    ret

menu_clean::
    call apaga_pantalla

    call clean_window_menu

    call init_oam

    ret

