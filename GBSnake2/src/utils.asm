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

disable_sram::
	ld a, $00
	ld [$0000], a
	ret 

load_high_score::
	call enable_sram

	;; Comparamos si el número mágico está en la primera posición
	ld hl, $A000
	ld a, [hl]
	cp $42
	jr z, .load_valid_data

.initialize_ram
	;; Si es la primera vez o los datos están corruptos
	xor a
	ld [HighScores], a
	ld [HighScores + 1], a

	;; Guardamos los valores en SRAM para la próxima vez
	ld hl, $A000
	ld a, $42
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl], a
	jr .done

.load_valid_data
	inc hl
	ld a, [hl]
	ld [HighScores], a

	inc hl
	ld a, [hl]
	ld [HighScores + 1], a

.done
	call disable_sram
	ret

save_high_score::
	ld a, [MenuOption]
	ld c, a ;; Guardamos en c la opción de juego	

	ld b, 0
	ld hl, HighScores
	add hl, bc
	ld a, [hl]

	;; Comparamos con el score actual
	ld b, a
	ld a, [Score]
	cp b
	
	;; Si no es estrictamente mayor, no hago nada
	ret c
	ret z

	ld b, a

	;; Actualizamos la variable en WRAM
	ld [hl], a

	;; Ahora en SRAM
	call enable_sram

	;; Guardamos el número mágico para comprobar la validez de los datos
	ld hl, $A000
	ld a, $42
	ld [hl+], a

	ld a, [HighScores]
	ld [hl+], a
	ld a, [HighScores + 1]
	ld [hl], a
	call disable_sram

	ret