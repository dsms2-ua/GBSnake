INCLUDE "music/musicConstants.inc"

SECTION "Music Variables", WRAM0
wCurrentSong::  DS 2
wNoteDuration:: DS 1

SECTION "Intro Music", ROM0[$0002]
IntroMusic::
    DW G4, 1
    DW A4, 1
    DW B4, 1
    DW C5, 3
    DW SILENCIO, 1
    DW C5, 1
    DW B4, 1
    DW A4, 1
    DW G4, 3
    DW $FFFF ;; Fin de la canción

SECTION "Music Code", ROM0

init_sound::
    ;; Encendemos la APU
    ld a, %10000000
    ld [rNR52], a

    ;; Configuramos que el sonido salga por los dos altavoces
    ld a, $FF
    ld [rNR50], a
    ld a, $77
    ld [rNR51], a

    ret

music_player::
    ;; Comprobamos si hay una canción sonando
    ld hl, wCurrentSong
    ld a, [hl+]
    or [hl]
    ret z

    ld hl, wNoteDuration
    ld a, [hl]
    dec a
    ld [hl], a

    ret nz ;; Si no ha llegado a 0, salimos

.load_next_note
    ld hl, wCurrentSong ;; Puntero a la canción actual
    ld a, [hl+] ;; Cargamos el byte alto de la direccion
    ld h, [hl] ;; Cargamos el byte bajo
    ld l, a ;; HL apunta a la nota

    ld a, [hl+] ;; Leemos el valor de la nota (16) bits
    ld e, a
    ld a, [hl+]
    ld d, a     ;; DE => Nota siguiente

    ;; Comprobamos si es el fin de la canción
    ld a, d
    cp $FF
    jr z, .song_end
    ld a, e
    cp $FF
    jr z, .song_end

    ;; Guardamos el puntero de la siguiente nota
    push hl

    ld a, d
    or e
    jr z, .play_silencio

.play_note
    ld hl, Freq_Base
    or a
    ld a, l
    sub e
    ld l, a
    ld a, h
    sbc d
    ld h, a

    ;; Escribimos en los registros del canal 1
    ld a, %01000000 ;; Ciclo de trabajo 50%
    ld [rNR11], a
    ld a, %11110010 ;; Envolvente de volumen
    ld [rNR12], a
    ld a, l
    ld [rNR13], a
    ld a, %10000000 ;; Iniciamos sonido
    or h
    ld [rNR14], a
    jr .load_duration

.play_silencio
    ld a, 0
    ld [rNR12], a

.load_duration 
    ;; Recuperamos la duración de la nota
    pop hl
    ld a, [hl+]
    ld [wNoteDuration], a

    ld a, l
    ld [wCurrentSong], a
    ld a, h
    ld [wCurrentSong + 1], a
    ret

.song_end
    ld hl, IntroMusic
    ld a, l
    ld [wCurrentSong], a
    ld a, h
    ld [wCurrentSong + 1], a
    jr .load_next_note


play_music::
    ld a, l
    ld [wCurrentSong], a
    ld a, h
    ld [wCurrentSong + 1], a

    ld a, 1
    ld [wNoteDuration], a
    ret


play_sound_eat::
	;; Usamos el canal 2
    ;; 1. Configuramos el volumen
    ld a, %11110010 ;; Volumen al máximo (F), descendente (0), 2 pasos de envolvente
    ld [rNR22], a

    ;; Configuramos la nota (C5)
    ld hl, Freq_Base - C5
    ld a, l
    ld [rNR23], a ;; Frecuencia baja
    ld a, h
    ld [rNR24], a ;; Frecuencia alta

    ;; Iniciamos el sonido
    ld a, h
    or %10000000
    ld [rNR24], a

    ret

play_sound_die::
    ;; Usamos el canal 4
    ;; 1. Configuramos el volumen
    ld a, %11110011 ;; Volumen al máximo, descendente y 3 pasos de envolvente
    ld [rNR42], a

    ;; 2. Configuramos el "tono" del ruido
    ld a, %00110010
    ld [rNR43], a

    ;; 3. Iniciamos el sonido
    ld a, %10000000
    ld [rNR44], a

    ret