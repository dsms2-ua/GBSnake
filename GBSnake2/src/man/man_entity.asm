INCLUDE "constants.inc"

SECTION "Entity Manager Data", WRAM0

component_sprite:
	DS CMP_SPRITES_TOTAL_BYTES

num_entities_alive: DS 1
next_free_entity: DS 1

SECTION "Entity Manager Code", ROM0

man_entity_init::
	ld hl, component_sprite
	ld b, CMP_SPRITES_TOTAL_BYTES
	xor a
	call memset_256

	;; Init values
	ld [num_entities_alive], a
	ld [next_free_entity], a

	ret

;; ------------------
;; Allocates space for a new entity
;; 		RETURN 
;; 			HL => Memmory Addres of the New Component
man_entity_alloc::
	ld a, [num_entities_alive]
	inc a
	ld [num_entities_alive], a

	ld a, [next_free_entity]
	ld h, CMP_SPRITES_H
	ld l, a

	add SPRITE_SIZE
	ld [next_free_entity], a

	ret