INCLUDE "constants.inc"
; =============================================
; RUTINA DE ATENCIÓN A INTERRUPCIONES (ISR)
; =============================================
SECTION "VBlankInterrupt", ROM0[$0040]
    jp VBlank

SECTION "Interrupt Routines", ROM0

VBlank:
    ; Este código se ejecuta cuando ocurre el V-Blank.
    ; Lo único que necesitamos es que termine para despertar al 'halt'.

    ;; Guardamos el estado de los registros
    push hl
    push af

    call music_player

    pop af
    pop hl

    reti    ; Return from Interrupt (ESENCIAL)
SECTION "Entry point", ROM0[$150]

main::
    ;; Inicializamos las interrupciones
	di
	ld sp, $E000
	ld a, $00000001
	ld [rIE], a
	

   call ge_init
   ei
   call intro_init
   call intro_run
   call intro_clean

   call game_init
   call game_run

   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
