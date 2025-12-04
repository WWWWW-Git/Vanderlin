/mob/living/carbon/human/species/groveling
	race = /datum/species/groveling

/datum/species/groveling
	name = "Groveling"
	id = SPEC_ID_GROVELING
	native_language = "Groveling" //Change this.
	desc = "Mysterious living entities that do not even know their own destiny on the wheel of fate. \
	\n\n\
	Divine intervention channeled through flora by parasitic symbiosis, a fungal colony combined with tree \
	barks, vines and growths no different from kneestingers on Fog Islands after the fall of magic. Not even elvenkind \
	knows how they came to be, some believe they are revengeful spirits that slipped through Necra's fingers, \
	are Dendor's wraith made form, or an Abyssor's manifestation of symbiosis. No one knows.\
	\n\n\
	Grovelings are parasitic, able to choose a host tree to absorb its nutrients, and anchor itself on the ground \
	to heal and receive less damage from attacks at the cost of not moving at all, and cannot get diseased. \
	However, they are vulnerable to fire and receive semi-permanent damage when their host tree dies. \
	\n\n\
	Nonetheless, they have been formed in fungal flesh and fiber with little to no memory of why \
	and how, but they have an unconscious hate for the demonic, including tieflings."

	skin_tone_wording = "Chlorophyll"

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_NOHYGIENE)
	use_skintones = TRUE

	possible_ages = list(AGE_IMMORTAL)
	changesource_flags = WABBAJACK

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mm.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'

	soundpack_m = /datum/voicepack/male/serious

	offset_features_m = list(
		OFFSET_RING = list(0,0),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,0),\
		OFFSET_HEAD = list(0,0),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,0),\
		OFFSET_MOUTH = list(0,0),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
	)

	offset_features_f = list(
		OFFSET_RING = list(0,-1),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,-1),\
		OFFSET_HEAD = list(0,-1),\
		OFFSET_FACE = list(0,-1),\
		OFFSET_BELT = list(0,-1),\
		OFFSET_BACK = list(0,-1),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
	)

	specstats_m = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 2, STATKEY_CON = 1, STATKEY_END = 1, STATKEY_SPD = -1, STATKEY_LCK = 0)
	specstats_f = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 2, STATKEY_CON = 1, STATKEY_END = 1, STATKEY_SPD = -1, STATKEY_LCK = 0)

	enflamed_icon = "widefire"

	meat = /obj/item/grown/log/tree/small

	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
	)

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
	)

	body_markings = list(
		/datum/body_marking/tonage,
	)
	allowed_cultures = list("muqian", "kaizoku", "shuhen", "linyou", "dustwalker", "foreigner") // IDs
	allowed_body_types = list("mt_kit", "normalbody") // IDs
