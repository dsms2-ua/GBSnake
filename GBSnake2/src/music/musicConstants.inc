;; GENERAL
DEF rNR50 		equ $FF24 ;; Control de Paneo (Izq/Der)
DEF rNR51 		equ $FF25 ;; Volumen general y selección de salida
DEF rNR52 		equ $FF36 ;; Encendido/Apagado general

;; CANAL 1 => Pulso con barrido (Sweep)
DEF rNR10 		equ $FF10 ;; Registro de barrido (Sweep)
DEF rNR11 		equ $FF11 ;; Longitud de onda y ciclo de trabajo
DEF rNR12 		equ $FF12 ;; Envolvente de volumen
DEF rNR13 		equ $FF13 ;; Frecuencia (bits bajos)
DEF rNR14 		equ $FF14 ;; Frecuencia (bits altos) e inicio

;; CANAL 2 => Pulso Simple
DEF rNR21 		equ $FF16 ;; Longitud de onda y ciclo de volumen
DEF rNR22 		equ $FF17 ;; Envolvente de volumen
DEF rNR23 		equ $FF18 ;; Frecuencia (bits bajos)
DEF rNR24 		equ $FF19 ;; Frecuencia (bits altos) e inicio

;; CANAL 3 => Onda (Wave)
DEF rNR30 		equ $FF1A ;; Activar / Desactivar canal
DEF rNR31 		equ $FF1B ;; Longitud
DEF rNR32 		equ $FF1C ;; Volumen
DEF rNR33 		equ $FF1D ;; Frecuencia (bits bajos)
DEF rNR34 		equ $FF1E ;; Frecuencia (bits altos) e inicio
DEF rWaveRAM 	equ $FF30 ;; Inicio de la RAM de Onda

;; CANAL 4 => Ruido
DEF rNR41 		equ $FF20 ;; Longitud de onda
DEF rNR42 		equ $FF21 ;; Envolvente de volumen
DEF rNR43 		equ $FF22 ;; Polinomio del contador
DEF rNR44 		equ $FF23 ;; Inicio y contador


;; -----------------------------------------
DEF Freq_Base 	equ 2048

;; Silencio
DEF SILENCIO 	equ 0

;; Notas 4ª Octava
DEF C4			equ 44
DEF CS4			equ 156
DEF D4			equ 262
DEF DS4			equ 363
DEF E4 			equ 457
DEF F4 			equ 547
DEF FS4			equ 631
DEF G4 			equ 710
DEF GS4			equ 786
DEF A4 			equ 854
DEF AS4 		equ 923
DEF B4 			equ 986

;; NOtas 5ª Octava
DEF C5 			equ 1046
DEF D5 			equ 1159
DEF E5			equ 1265
DEF F5 			equ 1329
DEF G5			equ 1420
DEF A5			equ 1502
DEF B5			equ 1575