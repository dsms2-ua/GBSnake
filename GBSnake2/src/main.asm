INCLUDE "constants.inc"
SECTION "Entry point", ROM0[$150]

main::
   call ge_init
   call intro_init
   call intro_run

   call game_init
   ;; call game_run

   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
