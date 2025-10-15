INCLUDE "constants.inc"
; =============================================
; RUTINA DE ATENCIÓN A INTERRUPCIONES (ISR)
; =============================================
SECTION "VBlankInterrupt", ROM0[$0040]

VBlank:
    ; Este código se ejecuta cuando ocurre el V-Blank.
    ; Lo único que necesitamos es que termine para despertar al 'halt'.
    reti    ; Return from Interrupt (ESENCIAL)
SECTION "Entry point", ROM0[$150]

main::
   call ge_init
   call intro_init
   call intro_run
   call intro_clean

   call game_init
   call game_run

   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
