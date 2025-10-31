INCLUDE "constants.inc"


SECTION "Entry point", ROM0[$150]

main::
   di
   ld sp, $E000
   call ge_init
   ei

   call intro_init
   call intro_run
   call intro_clean

.game_loop
   ld a, [MenuOption]
   cp 4
   jr nz, .no_menu

.menu
   call menu_init
   call menu_run
   call menu_clean

.no_menu
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
   call game_clean

   jp .game_finish

.run_game_caos
   call game_init_caos
   call game_run_caos
   call game_clean_caos

   jp .game_finish

.game_finish
   call game_finish_init
   call game_finish_run
   call game_finish_clean

   jp .game_loop

.exit
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
