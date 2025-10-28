INCLUDE "constants.inc"

SECTION "Entry point", ROM0[$150]

main::	
   call ge_init

   call intro_init
   call intro_run
   call intro_clean

   call menu_init
   call menu_run
   call menu_clean

   ;; Aquí leemos la variable MenuOption y seleccionamos lo correspondiente
   ld a, [MenuOption]
   cp 0
   jr z, .run_game_normal

   cp 1
   jr z, .run_game_caos

   jp .exit

.run_game_normal
   call game_init
   call game_run
   
   jp .exit

.run_game_caos

.exit
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
