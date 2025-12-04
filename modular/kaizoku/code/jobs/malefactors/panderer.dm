/datum/job/kaizoku/panderer
	title = "Panderer"
	faction = FACTION_TOWN
	department_flag = FACTION_MALEFACTORS
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_CITIZEN_PLAYERS

	tutorial = "You own this den of indulgence with your associates, your hand controls the population \
	with vice, corruption and sin, be it drugs, assassinations or pleasures of the flesh, you provide \
	it all. Your infamous organized society thrives beyond the law's reach, as the sewers have no owners, \
	and the tower's clan tolerates you, as your gang ensures no more other syndicates intrude on their \
	domains with more aggressive drugs. Don't forget gambling, your only 'legal' business."
	min_pq = 0
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/kaizoku/panderer
	display_order = NITEMAN_ORDER
	give_bank_account = 120
	cmode_music = 'modular/stonekeep/sound/cmode/combat_hellish2.ogg'

/datum/outfit/job/kaizoku/panderer/pre_equip(mob/living/carbon/human/H)
	..()
	shirt = /obj/item/clothing/shirt/undershirt/webs
	belt = /obj/item/storage/belt/leather
	beltr = /obj/item/weapon/mace/cudgel
	beltl = /obj/item/storage/keyring/nitemaster
	if(H.gender == FEMALE)
		shoes = /obj/item/clothing/shoes/shortboots
		armor = /obj/item/clothing/shirt/dress/stewarddress
		cloak = /obj/item/clothing/cloak/cape/silk/dark
	// if(isdarkelf(H))
		//mask = /obj/item/clothing/face/spectacles/delf
	ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
	H.grant_language(/datum/language/thievescant)
	to_chat(H, "<span class='info'>I can gesture in thieves' cant with ,t before my speech.</span>")
	ADD_TRAIT(H, TRAIT_THIEVESGUILD, TRAIT_GENERIC)

	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)//a dishonourable noble isn't going to be fighting like a honorable knight
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/stealing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.change_stat("speed", 1)
	H.change_stat("intelligence", 1)
	H.change_stat("perception", 2)
	H.mind.teach_crafting_recipe(/datum/blueprint_recipe/forgery_nitemaiden)
	H.mind.teach_crafting_recipe(/datum/blueprint_recipe/forgery_adventurer)
	if(H.gender == MALE)
		head = /obj/item/clothing/head/roguehood/colored/brown
		armor = /obj/item/clothing/armor/leather/jacket/niteman
		shirt = /obj/item/clothing/armor/gambeson/arming//dark gambeson who only covers the chest + arms
		pants = /obj/item/clothing/pants/trou/leather
		shoes = /obj/item/clothing/shoes/nobleboot
		if(H.dna?.species)
			if(H.dna.species.id == "human")
				H.dna.species.soundpack_m = new /datum/voicepack/male/zeth()

/*	.................   Unique Nitemaster recipes   ................... */
/datum/blueprint_recipe/forgery_nitemaiden
	name = "Forge panderer license"
	construct_tool = /obj/item/natural/feather
	required_materials = list(/obj/item/paper = 1)
	result_type = /obj/item/paper/certificate/fake_health

/datum/blueprint_recipe/forgery_adventurer
	name = "Forge adventurer license"
	construct_tool = /obj/item/natural/feather
	required_materials = list(/obj/item/paper = 1)
	result_type = /obj/item/paper/certificate/adventurer_fake
