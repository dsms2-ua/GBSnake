INCLUDE "definitions.inc"

SECTION "Utils", ROM0

wait_vblank_start::
   ld hl, $FF44
   ld a, $90
   .loop:
      cp [hl]
   jr nz, .loop
   ret

;; INPUT
;; 		HL: Source
;; 		DE: Destination
;;  	 	 B: bytes
;;
memcpy_256::
		ld a, [hl+]
		ld [de], a
		inc de
		dec b
	jr nz, memcpy_256
	ret

copyMap::
	ld b, MAP1_WIDTH
	.copy_tile:
		ld a, [hl+]
		ld [de], a
		inc de
		dec b
		jr nz, .copy_tile

		;; Aquí saltas los tiles restantes
		ld a, e
		add a, 32 - MAP1_WIDTH
		ld e, a
		jr nc, .no_carry
		inc d
	.no_carry:
		dec c
		jr nz, copyMap

;; INPUT
;; HL: Destination
;;  B: Bytes
;;  A: Value to set
memset_256::
		ld [hl+], a
		dec b
	jr nz, memset_256
	ret

;; Se utiliza para apagar la pantalla antes de cargar tiles o mapas
apaga_pantalla::
	di
	call wait_vblank_start
	ld hl, rLCDC
	rst 7, [hl]
	ei
	ret

;; Limpia los tiles de Nintendo
clear_tiles_screen::
	ld hl, $9904
	ld a, $00
	ld b, 13
	call memset_256
	ld hl, $9924
	ld b, 12
	call memset_256
	ret

;; OUTPUT
;; 	b => Bits direccionales
read_joypad::
	;; Primero leemos el JoyPad
	ld a, SELECT_JOYPAD
	ld [rP1], a
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1] ;; Leemos 3 veces por hardware
	and %00001111
	swap a ;; Los movemos a los bits de arriba
	ld b, a

	ld a, SELECT_BUTTONS
	ld [rP1], a
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1] ;; Leemos 3 veces por hardware
	and %00001111
	or b ;; Combinamos con los bits de dirección

	cpl 

	ld [JoyPadState], a
	ld a, SELECT_NONE ;; Reseteamos la selección
	ld [rP1], a
	ret