INCLUDE "constants.inc"

SECTION "Utils Menu", ROM0

show_logo_menu::
	ld c, $40
	ld de, $9844
	ld b, 14
	call load_tiles_screen

	ld c, $56
	ld de, $9864
	ld b, 14
	call load_tiles_screen

	ret

show_text_menu::
    ld hl, TextClassic
    ld de, $98C7
    ld bc, TextClassicEnd - TextClassic
    call copy_vram

    ld hl, TextChaos
    ld de, $9907
    ld bc, TextChaosEnd - TextChaos
    call copy_vram

    ld hl, TextExit
    ld de, $9947
    ld bc, TextExitEnd - TextExit
    call copy_vram

    ld hl, TextPressA
    ld de, $99C6
    ld bc, TextPressAEnd - TextPressA
    call copy_vram

    ret

draw_selector_sprite::
    ld hl, OAMBuffer

    ld [hl], 64 ;; Y
    inc hl
    ld [hl], 40 ;; X
    inc hl
    ld [hl], $03
    inc hl
    ld [hl], 0
    inc hl

    ret

copy_OAM_buffer_menu::
	ld hl, OAMBuffer
	ld de, OAM_DIR
	ld b, 4
	call memcpy_256

	ret

update_menu_selector::
    ;; Primero, comprobamos si se cumple el delay
    ld hl, MenuDelay
    ld a, [hl]

    or a
    jr z, .check_input
    dec [hl]
    ret

.check_input
    ;; Leemos el joypad y actualizamos la opción
    ld a, [JoyPadState]
    
    bit KEY_DOWN, a
    jr z, .check_up

.pressed_down
    ;; Actualizamos la opción
    ld hl, MenuOption
    inc [hl]

    ;; Comprobamos si nos hemos pasado de opción
    ld a, [hl]
    cp MENU_MAX_OPTIONS

    jr nz, .set_delay

    ;; Si nos hemos pasado, volvemos a la primera opción
    xor a
    ld [hl], a
    jr .set_delay

.check_up
    ld a, [JoyPadState]
    bit KEY_UP, a
    ret z

.pressed_up
    ld hl, MenuOption
    ld a, [hl]
    
    ;; Comprobamos si ya estábamos en la primera opción
    or a
    jr z, .move_down_option
    dec [hl]
    jr .set_delay

.move_down_option
    ld a, MENU_MAX_OPTIONS - 1
    ld [hl], a

.set_delay
    ld a, MENU_DELAY_FRAMES
    ld [MenuDelay], a

.update_position
    ;; Ahora, movemos el sprite a la posición correcta
    ld a, [MenuOption]
    
    add a
    ld e, a
    ld d, 0

    ld hl, MenuPositions
    add hl, de

    ld de, OAMBuffer

    ld a, [hl+]
    ld [de], a
    inc de

    ld a, [hl]
    ld [de], a

    ret

clean_window_menu::
    ld hl, $9844
	ld b, 14
	ld a, $00
	call memset_256

    ld hl, $9864
	ld b, 14
	ld a, $00
	call memset_256

    ld hl, $98C7
	ld b, 7
	ld a, $00
	call memset_256

    ld hl, $9907
	ld b, 5
	ld a, $00
	call memset_256

    ld hl, $9947
	ld b, 4
	ld a, $00
	call memset_256

    ld hl, $99C6
	ld b, 7
	ld a, $00
	call memset_256
    ret