INCLUDE "constants.inc"

SECTION "Utils", ROM0

;; ------------------
;; Waits for VBlank start line
wait_vblank_start::
   ld hl, $FF44
   ld a, $90
   .loop:
      cp [hl]
   jr nz, .loop
   ret

;; ------------------
;; Copy bytes (256 as maximum)
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

;; ------------------
;; Allows copying more than 256 bytes
;; INPUT
;; 		HL => Source
;; 		DE => Destination
;; 		BC => Bytes
copy_vram::
	.copy_loop:
		ld a, [hl+]
		ld [de], a
		inc de
		dec bc
		ld a, b
		or c
	jr nz, .copy_loop
	ret

;; ------------------
;; Copy the map to the desired position
;; INPUT
;; 		HL => Primer tile del mapa
;; 		DE => Posición destino
copy_map::
	ld b, MAP_WIDTH
	.copy_tile:
		ld a, [hl+]
		ld [de], a
		inc de
		dec b
		jr nz, .copy_tile

		;; Aquí saltas los tiles restantes
		ld a, e
		add a, 32 - MAP_WIDTH
		ld e, a
		jr nc, .no_carry
		inc d
	.no_carry:
		dec c
		jr nz, copy_map

;; ------------------
;; Set bytes (256 as maximum)
;; INPUT
;; 		HL: Destination
;;  	 B: Bytes
;;  	 A: Value to set
memset_256::
		ld [hl+], a
		dec b
	jr nz, memset_256
	ret

;; ------------------
;; Set bytes
;; INPUT
;; 	 HL: Destination
;;  	 BC: Bytes
;;  	 A: Value to set
memset::
	.set_loop:
		ld [hl+], a
		ld d, a
		dec bc
		ld a, b
		or c
		ld a, d
	jr nz, .set_loop
	ret

;; ------------------
;; Powers off the LCD screen before loading maps or tiles to VRAM
apaga_pantalla::
	di
	call wait_vblank_start
	ld a, [rLCDC]
	res 7, a
	ld [rLCDC], a
	ei
	ret

;; ------------------
;; Powers on the LCD screen
enciende_pantalla::
	ld hl, rLCDC
	set 7, [hl]
	ret

;; ------------------
;; Clear Nintendo Logos
clear_tiles_screen::
	ld hl, $9904
	ld a, $00
	ld b, 13
	call memset_256
	ld hl, $9924
	ld b, 12
	call memset_256
	ret

;; ------------------
;; Reads buttons state in possitive logic (1 = pressed)
;; OUTPUT
;; 		JoyPadState => State of buttons
;;						 		 UDLR  AB						
;;								%xxxxxxxx
read_joypad::
	;; Primero leemos el JoyPad
	ld a, SELECT_PAD
	ld [rP1], a
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1] ;; Leemos 3 veces por hardware
	and %00001111
	ld b, a

	ld a, SELECT_BUTTONS
	ld [rP1], a
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1] ;; Leemos 3 veces por hardware
	and %00001111

	swap b
	or b
	cpl
	ld [JoyPadState], a 

	ld a, SELECT_NONE ;; Reseteamos la selección
	ld [rP1], a

	ret


enable_sram::
	ld a, $0A
	ld [$0000], a
	ret

disabel_sram::
	ld a, $00
	ld [$0000], a
	ret 

save_high_score::
	ld a, [Score]
	ld b, a
	ld a, [HighScore]
	cp b
	;; Comprobamos si tenemos nuevo record
	jr nc, .no_new_highscore

	ld a, b
	ld [HighScore], a

	call enable_sram
	ld hl, $A000
	ld [hl], a
	call disabel_sram

.no_new_highscore
	ret

load_high_score::
	call enable_sram
	ld hl, $A000
	ld a, [hl]
	call disabel_sram
	ld [HighScore], a
	ret