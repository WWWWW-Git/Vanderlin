/obj/item/organ/horns
	name = "horns"
	desc = "A severed pair of horns. What did you cut this off of?"
	icon_state = "severedtail" //placeholder
	visible_organ = TRUE
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_HORNS
	gender = PLURAL

/obj/item/organ/horns/tiefling
	name = "tiefling horns"
	accessory_type = /datum/sprite_accessory/horns/tiefling

/obj/item/organ/horns/humanoid

/obj/item/organ/horns/triton
	name = "triton horns"
	accessory_type = /datum/sprite_accessory/horns/triton

// ONI PARTS
// Oni Horns
/obj/item/organ/horns/oni
	name = "ogrun horns"
	accessory_type = /datum/sprite_accessory/horns/oni

/datum/customizer/organ/horns/oni
	customizer_choices = list(/datum/customizer_choice/organ/horns/oni)
	allows_disabling = FALSE

/datum/customizer_choice/organ/horns/oni
	name = "Ogrun Horn"
	organ_type = /obj/item/organ/horns/oni
	generic_random_pick = TRUE
	sprite_accessories = list(
		/datum/sprite_accessory/horns/oni,
		/datum/sprite_accessory/horns/oni_large)

