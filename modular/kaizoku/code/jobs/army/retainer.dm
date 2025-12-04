//Remember: Daily ration ticket system to be 'recovered' in a INN, or on a Ration Machine (bad trashy food).
// Military Personnel right: Your food is paid by the Imperial Government.
// Military Personnel right: Health checkup is paid by the Imperial Government, once a week.

/datum/job/kaizoku/retainer
	title = "Custodian Retainer"
	flag = KZ_RETAINER
	department_flag = FACTION_MILITARY
	total_positions = 5 // Essentially, You can have 2 Elites, 5 Retainers, 4 Militia. This breaks down into 11 soldiers in total.
	spawn_positions = 5
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_CITIZEN_PLAYERS
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_IMMORTAL)
	tutorial = "War is routine as a sworn retainer. You know the imperial fogcruisers \
	enjoy plundering Grenzelhoft warships while you rot as the infantry backbone protecting the \
	homeland from the castaways, but steady pay keeps your loyalty and honor firm, so \
	long as the coin arrives, and unlike the Militia, you are not meant to die cheaply, \
	as you know well you are no conscript rabble."
	display_order = GARRISON_ORDER
	outfit = /datum/outfit/job/kaizoku/retainer //Default outfit for the Custodian Foreign Guard
	advclass_cat_rolls = list(CTAG_RETAINER = 20)	//Handles class selection.
	give_bank_account = 25 // Considered "Slightly above average pay (20) + The government provided you with the equipments you wear."
	min_pq = -10
	cmode_music = 'modular/kaizoku/sound/combat/combat_stormwarrior.ogg'

/datum/outfit/job/kaizoku/retainer // Reminder message
	var/oath = "<br><br><font color='#855b14'><span class='bold'>Remember to renew your oath of loyalty to the sovereign \
	at the start of the week, and train the Militia and New Rices. Your payment includes this requirement.</span></font><br><br>"

/datum/outfit/job/kaizoku/retainer/post_equip(mob/living/carbon/human/H)
	. = ..()
	to_chat(H, oath)
	if(istype(H.cloak, /obj/item/clothing/cloak/stabard/haramaki/jinbaori/guard) || istype(H.cloak, /obj/item/clothing/cloak/raincloak/guardsman))
		var/obj/item/clothing/S = H.cloak
		var/index = findtext(H.real_name, " ")
		if(index)
			index = copytext(H.real_name, 1, index)
		if(!index)
			index = H.real_name
		S.name = "retinue's cloak ([index])"

//Universal stuff for all guards, regardless of their class selection.
/datum/outfit/job/kaizoku/retainer
	pants = /obj/item/clothing/pants/trou/tobi/random
	shoes = /obj/item/clothing/shoes/ridingboots/gutal/custodian
	belt = /obj/item/storage/belt/kaizoku/leather/pursebelt
	wrists = /obj/item/clothing/wrists/bracers/leather/khudagach
	gloves = /obj/item/clothing/gloves/leather/abyssal

/datum/outfit/job/kaizoku/retainer/pre_equip(mob/living/carbon/human/H)
	..()
	// H.verbs |= /mob/proc/haltyell // Shitbroken.
	ADD_TRAIT(H, TRAIT_KNOWBANDITS, TRAIT_GENERIC)

/* ! ! ! Class Selection Section Below ! ! !
Design philosphy:
- Footman, specializes in using axes/maces and shields. - Medium armor
- Pikeman, specializes in polearms with some bonus stats. - Medium armor
- Archer, specializes in bow/crossbow and daggers. - Dodge expert, no armor training, some crafting stats (low)
- Fencer, specializes in swords and daggers. - Dodge expert, no armor training
*/

/datum/job/advclass/kaizoku/retainer/vanguard
	title = "Vanguard Retinue"
	tutorial = "You are a frontline warrior, the staple in any art of warfare in which the shield holds the borders of the realm. Raised under foreign banners, fighting in formation comes effortlessly under the discipline of steel, holding a sword or a mace to put down any evildoer."
	outfit = /datum/outfit/job/kaizoku/retainer/vanguard
	category_tags = list(CTAG_RETAINER)

//NECESSARY; Fix Jizamurai ; Rename Shieldbearer ; Give axe to Shieldbearer ; Remove Stingermaster ; Give Doggos as normal garrison item
// Maybe give them a sword to Shieldbearer, too. maybe.
//Upgrade Jizamurai's armor tho.
//May be worthy to change Chokuto to normal sword and give it to Shieldbearers.
//Increase jizamurai's strength to compensate lack of armor.

/datum/outfit/job/kaizoku/retainer/vanguard/pre_equip(mob/living/carbon/human/H)
	..()
	var/choice = input(H, "Choose your primary weapon:", "Retinue Armament") in list("Shieldbearer", "Stingermaster", "Crabizamurai")
	if(choice == "Shieldbearer")
		beltr = /obj/item/ammo_holder/cscabbard/scscabbard/loaded
		beltl = /obj/item/weapon/axe/battle/ono/fogono
		neck = /obj/item/clothing/neck/gorget/lazerrain
		backr = /obj/item/weapon/shield/tower/abyssaltower
		if(H.dna.species?.id != "abyssariad" && H.dna.species.name != "Undine")
			head = /obj/item/clothing/head/helmet/guardsman/heartfelt
			armor = /obj/item/clothing/armor/cuirass/custodian
		else
			head = /obj/item/clothing/head/helmet/guardsman
			armor = /obj/item/clothing/armor/medium/scale/shanwenkai
	if(choice == "Stingermaster")
		armor = /obj/item/clothing/armor/cuirass/zinger
		beltr = /obj/item/weapon/axe/battle/ono/fogono
		neck = /obj/item/clothing/neck/gorget/lazerrain
		head = /obj/item/clothing/head/helmet/guardsman/zinger
	if(choice == "Crabizamurai")
		armor = /obj/item/clothing/armor/cuirass/nanbando
		head = /obj/item/clothing/head/helmet/kettle/jingasa //Essentially a Kettle. Contrasts the full-closed helmets.
		neck = /obj/item/clothing/neck/bevor/crabstain //Fills in the gap of protection for the mouth and neck.
		H.change_stat(STATKEY_SPD, -1)
		H.change_stat(STATKEY_STR, 1) //So they can actually use their sword and kanabo.
		if(H.dna.species.name == "Ogrun")
			backr = /obj/item/weapon/mace/goden/kanabo //If Ogrun: Spawn with Kanabo.
		else
			backr = /obj/item/weapon/sword/long/greatsword/zwei/okatana //If Abyssariad, starts with the O-katana.
	to_chat(H, "<span class='warning'>My clan was bound to sworn to the king's cause under the Heavenly Emperor's will. As an Ashigaru retainer, their lineage is held in high regard, and I shall serve their bloodline as I would my daimyo.")
	shirt = /obj/item/clothing/armor/chainmail/tatami
	cloak = /obj/item/clothing/cloak/stabard/haramaki/jinbaori/guard
	backpack_contents = list(/obj/item/storage/keyring/garrison)

	H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE) //The elite garrison NEEDS to know HOW to read and write documents. Due to falconeer message delivery and more.
	H.change_stat(STATKEY_STR, 1)
	H.change_stat(STATKEY_END, 2)
	H.change_stat(STATKEY_CON, 2)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

/datum/job/advclass/kaizoku/retainer/phalangite
	title = "Phalangite Retinue"
	tutorial = "The bastion of leverage that puts a quick stop to any cavalry charge. Nothing passes the polearm that you wield as you anchor the line. You may not be the first to strike, yet it is your blow that breaks any mortal, and your strength shows it."
	outfit = /datum/outfit/job/kaizoku/retainer/phalangite

	category_tags = list(CTAG_RETAINER)

/datum/outfit/job/kaizoku/retainer/phalangite/pre_equip(mob/living/carbon/human/H)
	..()
	armor = /obj/item/clothing/armor/chainmail/hauberk/custodian // Steel equalizer.
	shirt = /obj/item/clothing/armor/gambeson/heavy/battleshirt
	neck = /obj/item/clothing/neck/bevor/crabstain
	cloak = /obj/item/clothing/cloak/stabard/haramaki/jinbaori/guard
	if(H.dna.species?.id != "abyssariad" && H.dna.species.name != "Undine")
		head = /obj/item/clothing/head/helmet/kettle/blasthammer/hfs
	else
		head = /obj/item/clothing/head/helmet/kettle/blasthammer/ffs
	beltr = /obj/item/weapon/sword/scimitar/messer/dao
	var/choice = input(H, "Choose your primary weapon:", "Retinue Armament") in list("Polearm", "Firelance")
	if(choice == "Polearm")
		backpack_contents = list(/obj/item/storage/keyring/garrison) //Does not require additional equipment beyond the keyring.
		backr = /obj/item/weapon/polearm/mancatcher
		if(H.dna.species?.id != "abyssariad" && H.dna.species.name != "Undine")
			var/obj/item/weapon/polearm/halberd/bardiche/P = new() //Standardize a Bardiche as the spawn item to differ from the Militia polearm.
			H.put_in_hands(P, forced = TRUE)
		else
			var/obj/item/weapon/polearm/halberd/bardiche/naginata/P = new() //Bardiche alt for foglanders
			H.put_in_hands(P, forced = TRUE)
	if(choice == "Firelance")
		to_chat(H, "<span class='boldwarning'>You remember your sensei's warnings.\n\n\ \
		DO NOT, EVER, CLOSE THE FIRELANCE WITHOUT A GOURD ON IT.\n\n\ \
		DO NOT PUT A GOURD ON IT WHILE IT IS ON YOUR BACK.\n\n\ \
		DO NOT DROP IT WHILE WITH A GOURD ON IT.\n\n\ \
		DO NOT PUT IT ON YOUR BACK WITH A GOURD EITHER. \
		REMEMBER. THE WEAPON IS AN ENEMY OF YOU JUST AS MUCH AS THE MAN INFRONT OF YOU.</span>")
		var/obj/item/weapon/polearm/firelance/P = new() //Special one-hand spear with fire capacities. May require nerfing when I settle 'different ammo' system.
		H.put_in_hands(P, forced = TRUE)
		backr = /obj/item/storage/backpack/satchel //Actually required. See below.
		backpack_contents = list(/obj/item/storage/keyring/garrison,/obj/item/sanctiflux,/obj/item/sanctiflux,/obj/item/sanctiflux) //Does not require additional equipment beyond the keyring.

	H.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE) //The elite garrison NEEDS to know HOW to read and write documents. Due to falconeer message delivery and more.
	H.change_stat(STATKEY_STR, 2)
	H.change_stat(STATKEY_END, 1)
	H.change_stat(STATKEY_CON, 2)
	H.change_stat(STATKEY_SPD, -1)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

/datum/job/advclass/kaizoku/retainer/marksman
	title = "Falconer Retinue"
	tutorial = "Your steady hands know the string just as much as your vision reachers farther than any other man, your precision has been shaped by the endless wind. You have a loyal companion for scouting, combat and communication as long it is alive."
	outfit = /datum/outfit/job/kaizoku/retainer/marksman
	category_tags = list(CTAG_RETAINER)


/datum/outfit/job/kaizoku/retainer/marksman/pre_equip(mob/living/carbon/human/H) //Made these more specialized in one type of ranged weapon.
	..()
	shirt = /obj/item/clothing/armor/gambeson/heavy/battleshirt
	cloak = /obj/item/clothing/cloak/raincloak/guardsman
	neck = /obj/item/clothing/neck/chaincoif/karuta_zukin/military
	wrists = /obj/item/clothing/wrists/bracers/leather/khudagach
	gloves = /obj/item/clothing/gloves/angle/falcon //This is a falconeer's gloves, name of the subrole. The falcons will also deal damage to those who does not use this glove.
	beltl = /obj/item/weapon/knife/steel/tanto
	ring = /obj/item/pet_command/whistle
	if(H.dna.species?.id != "abyssariad" && H.dna.species.name != "Undine")
		head = /obj/item/clothing/head/helmet/kettle/blasthammer/hfs
		armor = /obj/item/clothing/armor/leather/jacket/custodian
	else
		head = /obj/item/clothing/head/helmet/kettle/blasthammer/ffs
		armor = /obj/item/clothing/armor/leather/jacket/custodian/foglander
	backpack_contents = list(/obj/item/storage/keyring/garrison)
	var/choice = input(H, "Choose your primary weapon:", "Retinue Armament") in list("Long Bow", "Crossbow", "Chukonu")
	if(choice == "Long Bow")
		backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/long/yumi
		beltr = /obj/item/ammo_holder/quiver/arrows
	if(choice == "Crossbow")
		backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
		beltr = /obj/item/ammo_holder/quiver/bolts
	if(choice == "Chukonu")
		backr = /obj/item/gun/ballistic/revolver/grenadelauncher/chukonu
		beltr = /obj/item/ammo_holder/quiver/bolts
	var/obj/item/kaizoku/falcon_crate/P = new() //birb
	H.put_in_hands(P, forced = TRUE)

	//Stats for class
	H.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
	H.adjust_skillrank(/datum/skill/craft/tanning, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE) //Falconeers deserves one more skill of reading as a treat, since they are the ones writting afterall. Just got used to it.
	H.change_stat(STATKEY_PER, 2)
	H.change_stat(STATKEY_END, 1)
	H.change_stat(STATKEY_SPD, 1)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

//Special Alts per Clantype:

/datum/job/advclass/kaizoku/retainer/privateer // Court clan
	title = "Privateer Retinue"
	tutorial = "You are a swift warrior who tasted blood across ship decks rather than on the field, courtier and unorthodox. Your slim edge finds weakness in armor as you learnt the ways of ebb-and-flow so you never swing wide, you slide and stab, or shoot and scram."
	outfit = /datum/outfit/job/kaizoku/retainer/privateer

	category_tags = list(CTAG_RETAINER)

/datum/outfit/job/kaizoku/retainer/privateer/pre_equip(mob/living/carbon/human/H)
	..()
	shirt = /obj/item/clothing/armor/chainmail/iron/tatami
	cloak = /obj/item/clothing/cloak/raincloak/guardsman
	neck = /obj/item/clothing/neck/chaincoif/karuta_zukin/military
	beltl = /obj/item/weapon/knife/steel/tanto
	if(H.dna.species?.id != "abyssariad" && H.dna.species.name != "Undine")
		head = /obj/item/clothing/head/helmet/leather/paddedt
		armor = /obj/item/clothing/armor/leather/jacket/custodian
	else
		head = /obj/item/clothing/head/helmet/leather/paddedt/alt
		armor = /obj/item/clothing/armor/leather/jacket/custodian/foglander
	backpack_contents = list(/obj/item/storage/keyring/garrison)
	var/choice = input(H, "Choose your primary weapon:", "Retinue Armament") in list("Swift Blade", "Handcannon")
	if(choice == "Swift Blade")
		backpack_contents = list(/obj/item/storage/keyring/garrison)
		H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
		beltl = /obj/item/weapon/knife/steel/tanto
		beltr = /obj/item/weapon/sword/rapier/starfang
	if(choice == "Handcannon")
		H.adjust_skillrank(/datum/skill/combat/firearms, 3, TRUE)
		backr = /obj/item/gun/ballistic/revolver/grenadelauncher/handcannon
		beltr = /obj/item/ammo_holder/bullet/garrison
		beltl = /obj/item/reagent_containers/glass/bottle/aflask
		backpack_contents = list(/obj/item/storage/keyring/garrison,/obj/item/weapon/knife/steel/tanto,/obj/item/flint) //remember to make the flint actually activate the gun

	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE) //The elite garrison NEEDS to know HOW to read and write documents. Due to falconeer message delivery and more.
	H.change_stat(STATKEY_END, 2)
	H.change_stat(STATKEY_SPD, 2)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

/obj/item/ammo_holder/bullet/garrison/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/bullet/A = new(src)
		ammo_list += A
	update_icon()

/*
/datum/advclass/kaizoku/retainer/jizamurai //Samurai Clan
	name = "Jizamurai Retinue"
	tutorial = "."

/datum/advclass/kaizoku/retainer/operative // Orchid Clan
	name = "Operative Retinue"
	tutorial = "."

/datum/advclass/kaizoku/retainer/torghut // Horde Clan
	name = "Torghut Retinue"
	tutorial = "."

/datum/advclass/kaizoku/retainer/peasant // Heartfelt Clan
	name = "Peasant Warrior"
	tutorial = "."
*/
