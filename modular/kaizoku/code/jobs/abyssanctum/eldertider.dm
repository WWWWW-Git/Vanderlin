
/datum/job/kaizoku/mastersohei
	title = "Elder Tideseeker"
	tutorial = "High-ranking Tideseeker who hold authority within multiple shrines and tideseekers \
	within their influence. Often in charge of militant activities, these senior warriors are in \
	search of demonic corruption to dismantle, following the will of Abyssor under the words of \
	the Prophet. Their duty is to organize expeditions and ensure Abyssanctum artifacts are protected from thieves."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACE_NATIVE_PLAYERS // Tideseekers are as tight-recruited as champions, since they are 'modern' offshoots.
	display_order = KZ_ELDERTIDER
	department_flag = FACTION_ABYSSANCTUM
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	faction = FACTION_TOWN
	total_positions = 1
	spawn_positions = 1
	allowed_patrons = list(/datum/patron/abyssanctum/tideweaver)

	bypass_lastclass = TRUE
	outfit = /datum/outfit/job/kaizoku/mastersohei
	min_pq = 0
	selection_color = "#c2a45d"
	cmode_music = 'modular/kaizoku/sound/combat/combat_emperor.ogg'
	// spells = list(
	//	/obj/effect/proc_holder/spell/self/convertrole/sohei,
	/// )

/datum/outfit/job/kaizoku/mastersohei/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/helmet/heavy/necked/soheidemon
	wrists = /obj/item/clothing/neck/psycross/silver/abyssanctum
	shirt = /obj/item/clothing/suit/roguetown/shirt/eastshirt2
	armor = /obj/item/clothing/armor/chainmail/hauberk/kusari
	pants = /obj/item/clothing/pants/chainlegs/sendan
	shoes = /obj/item/clothing/shoes/shortboots/cloudhead
	belt = /obj/item/storage/belt/kaizoku/leather/daisho/random
	beltl = /obj/item/storage/belt/pouch/coins/mid
	ring = /obj/item/clothing/ring/silver
	cloak = /obj/item/clothing/cloak/odoshisohei
	neck = /obj/item/clothing/neck/chaincoif/karuta_zukin/random
	gloves = /obj/item/clothing/gloves/chain/kikko
	r_hand = /obj/item/weapon/polearm/halberd/bisento
	if(H.mind)
		H.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
		H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
		H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.adjust_skillrank(/datum/skill/magic/holy, 2, TRUE)
		H.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.change_stat("strength", 2)
		H.change_stat("perception", 2)
		H.change_stat("intelligence", 2)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)
		H.change_stat("speed", -2) //Differently of templars, they don't have CHURN so they can have cleric-tier spells. Tideweaver focus only.

	/* This content will be replaced with the SMITE system
	var/datum/devotion/cleric_holder/C = new /datum/devotion/cleric_holder(H, H.patron)
	C.update_devotion(50, 50)
	C.holder_mob = H
	C.grant_spells_sohei(H)
	H.verbs += list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/icebind)
	*/
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC) //It's meant to be only heavy armor, but Kusari is medium. Idk how templar is doing, but in my testing, the armor was freaked.
	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)


/*
/obj/effect/proc_holder/spell/self/convertrole/sohei/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
	. = ..()
	if(!.)
		return

	if(!(ispath(recruit.patron, /datum/patron/abyssanctum/tideweaver) || ispath(recruit.patron, /datum/patron/abyssanctum/purifier) || ispath(recruit.patron, /datum/patron/abyssanctum/curator)))
		var/list/patron_options = list(
			"Tideweaver" = /datum/patron/abyssanctum/tideweaver,
			"Purifier" = /datum/patron/abyssanctum/purifier,
			"Curator" = /datum/patron/abyssanctum/curator
		)
		var/choice = input(recruit, "You are being converted to Abyssanctum.", "Choose your tributaries") as null|anything in patron_options
		if(!choice)
			to_chat(recruit, "<span class='warning'>You denied purification.</span>")
			return

		var/patron_path = patron_options[choice]
		recruit.set_patron(patron_path)

	//We are setting up something different for the Tideseekers, "Smite" powers unique to them.

	//var/datum/devotion/cleric_holder/C = new /datum/devotion/cleric_holder(recruit, recruit.patron)
	//C.grant_spells(recruit)
*/

/mob/living/carbon/human/proc/torture_victim()
	set name = "Extract Confession"
	set category = "Torture"

	var/obj/item/grabbing/I = get_active_held_item()
	var/mob/living/carbon/human/H
	if(!istype(I) || !ishuman(I.grabbed))
		return
	H = I.grabbed
	if(H == src)
		to_chat(src, span_warning("It would be stupid to torture myself!"))
		return
	if(!HAS_TRAIT(H, TRAIT_RESTRAINED) && !H.buckled)
		to_chat(src, span_warning("[H] needs to be restrained or buckled first!"))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("The tides has already claimed [H]..."))
		return
	var/painpercent = (H.get_complex_pain() / (H.STAEND * 12)) * 100
	if(painpercent < 100)
		to_chat(src, span_warning("Not ready to speak yet."))
		return
	if(!do_after(src, 4 SECONDS, H))
		return
	if(!HAS_TRAIT(H, TRAIT_RESTRAINED) && !H.buckled)
		to_chat(src, span_warning("[H] needs to be restrained or buckled first!"))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("The tides has already claimed [H]..."))
		return
	if(H.add_stress(/datum/stress_event/tortured))
		SEND_SIGNAL(src, COMSIG_TORTURE_PERFORMED, H)
		var/static/list/torture_lines = list(
			"CONFESS YOUR WRONGDOINGS!",
			"CONFESS YOUR STAINS BEFORE THE TIDE!",
			"THE SPIRITS WILL RIP THE TRUTH FROM YOU SOUL!",
			"DO NOT RESIST THE CURRENT, TELL YOUR SECRETS!",
			"NOTHING IS HIDDEN FROM THE DEEP!",
			"LET THE SALT WITHER YOUR DECEIT AWAY!",
		)
		say(pick(torture_lines), spans = list("torture"))
		H.emote("painscream")
		H.confession_time("antag", src)

/mob/living/carbon/human/proc/faith_test()
	set name = "Test Faith"
	set category = "Torture"

	var/obj/item/grabbing/I = get_active_held_item()
	var/mob/living/carbon/human/H
	if(!istype(I) || !ishuman(I.grabbed))
		return
	H = I.grabbed
	if(H == src)
		to_chat(src, span_warning("I won't torture myself!"))
		return
	if(!HAS_TRAIT(H, TRAIT_RESTRAINED) && !H.buckled)
		to_chat(src, span_warning("[H] needs to be restrained or buckled first!"))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("[H] is dead already..."))
		return
	var/painpercent = (H.get_complex_pain() / (H.STAEND * 12)) * 100
	if(painpercent < 100)
		to_chat(src, span_warning("Not ready to speak yet."))
		return
	if(!do_after(src, 4 SECONDS, H))
		return
	if(!HAS_TRAIT(H, TRAIT_RESTRAINED) && !H.buckled)
		to_chat(src, span_warning("[H] needs to be restrained or buckled first!"))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("[H] is dead already..."))
		return
	if(H.add_stress(/datum/stress_event/tortured))
		SEND_SIGNAL(src, COMSIG_TORTURE_PERFORMED, H)
		var/static/list/faith_lines = list(
			"DO YOU DENY THE DEEP? DO YOU DENY ABYSSOR?",
			"WHICH CURRENTS CLAIMS YOUR FAITH, SINNER?",
			"WHO DO YOU SERVE, HERETIC?",
			"TO WHICH SHEPHERD DO YOU FLOCK TO?",
		)
		say(pick(faith_lines), spans = list("torture"))
		H.emote("painscream")
		H.confession_time("patron", src)

/mob/living/carbon/human/proc/confession_time(confession_type = "antag", mob/living/carbon/human/user)
	var/timerid = addtimer(CALLBACK(src, PROC_REF(confess_sins), confession_type, FALSE, user), 10 SECONDS, TIMER_STOPPABLE)
	var/static/list/options = list("RESIST!!", "CONFESS!!")
	var/responsey = browser_input_list(src, "Resist torture?", "TEST OF PAIN", options)

	if(SStimer.timer_id_dict[timerid])
		deltimer(timerid)
	else
		to_chat(src, span_warning("Too late..."))
		return
	if(responsey == "RESIST!!")
		confess_sins(confession_type, resist=TRUE, interrogator=user)
	else
		confess_sins(confession_type, resist=FALSE, interrogator=user)

/mob/living/carbon/human/proc/confess_sins(confession_type = "antag", resist, mob/living/carbon/human/interrogator, torture=TRUE, obj/item/paper/confession/confession_paper, false_result)
	if(stat == DEAD)
		return
	var/static/list/innocent_lines = list(
		"I DON'T KNOW!",
		"STOP THIS MADNESS!!",
		"I DON'T DESERVE THIS!",
		"THE PAIN!",
		"I HAVE NOTHING TO SAY...!",
		"WHY ME?!",
		"I'M INNOCENT!",
		"I AM NO SINNER!",
	)
	var/resist_chance = 0
	if(resist)
		to_chat(src, span_boldwarning("I attempt to resist the torture!"))
		resist_chance = (STAINT + STAEND) + 10
		if(istype(buckled, /obj/structure/fluff/walldeco/chains)) // If the victim is on hanging chains, apply a resist penalty
			resist_chance -= 15
		if(confession_type == "antag")
			resist_chance += 25

	if(!prob(resist_chance))
		var/list/confessions = list()
		var/datum/antag_type = null
		switch(confession_type)
			if("antag")
				if(!false_result)
					for(var/datum/antagonist/antag in mind?.antag_datums)
						if(!length(antag.confess_lines))
							continue
						confessions += antag.confess_lines
						antag_type = antag.type
						break // Only need one antag type
			if("patron")
				if(ispath(false_result, /datum/patron))
					var/datum/patron/fake_patron = new false_result()
					if(length(fake_patron.confess_lines))
						confessions += fake_patron.confess_lines
						antag_type = fake_patron.type
				else
					if(length(patron?.confess_lines))
						confessions += patron.confess_lines
						antag_type = patron.type

		if(torture && interrogator && confession_type == "patron")
			var/datum/patron/interrogator_patron = interrogator.patron
			var/datum/patron/victim_patron = patron
			switch(interrogator_patron.associated_faith.type)
				if(/datum/faith/abyssanctum) //Stonekeep Edit
					if(ispath(victim_patron.type, /datum/patron/divine)) // Don't care much about the Ten.
						interrogator.add_stress(/datum/stress_event/torture_small_penalty)
					//else if(victim_patron.type == /datum/patron/psydon/progressive)
						//interrogator.add_stress(/datum/stress_event/torture_small_penalty)
					//else if(victim_patron.type == /datum/patron/godless/naivety)
						//interrogator.add_stress(/datum/stress_event/torture_small_penalty)
					else if(victim_patron.type == /datum/patron/abyssanctum)
						interrogator.add_stress(/datum/stress_event/torture_large_penalty)

		if(length(confessions))
			if(torture) // Only scream your confession if it's due to torture.
				say(pick(confessions), spans = list("torture"), forced = TRUE)
			else
				say(pick(confessions), forced = TRUE)
			if(has_confessed) // This is to check if the victim has already confessed, if so just inform the torturer and return. This is so that the Inquisitor cannot get infinite confession points and get all of the things upon getting thier first heretic.
				visible_message(span_warning("[name] has already signed a confession!"), "I have already signed a confession!")
				return
			var/obj/item/paper/confession/held_confession
			if(istype(confession_paper))
				held_confession = confession_paper
			else if(interrogator?.is_holding_item_of_type(/obj/item/paper/confession)) // This code is to process gettin a signed confession through torture.
				held_confession = interrogator.is_holding_item_of_type(/obj/item/paper/confession)
			if(held_confession && !held_confession.signed) // Check to see if the confession is already signed.
				// held_confession.bad_type = "AN EVILDOER" // In case new antags are added with confession lines but have yet to be added here.
				//this is no longer reliable as all patrons have confess lines now
				switch(antag_type)
					if(/datum/antagonist/bandit)
						held_confession.bad_type = "AN OUTLAW OF THE THIEF-LORD"
						held_confession.antag = initial(antag_type:name)
					if(/datum/patron/inhumen/matthios)
						held_confession.bad_type = "A FOLLOWER OF THE THIEF-LORD"
						held_confession.antag = "worshiper of " + initial(antag_type:name)
					if(/datum/antagonist/maniac)
						held_confession.bad_type = "A MANIAC DELUDED BY MADNESS"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/assassin)
						held_confession.bad_type = "A DEATH CULTIST"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/zizocultist)
						held_confession.bad_type = "A SERVANT OF THE FORBIDDEN ONE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/zizocultist/leader)
						held_confession.bad_type = "A SERVANT OF THE FORBIDDEN ONE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/patron/inhumen/zizo)
						held_confession.bad_type = "A FOLLOWER OF THE FORBIDDEN ONE"
						held_confession.antag = "worshiper of " + initial(antag_type:name)
					if(/datum/antagonist/werewolf)
						var/datum/antagonist/werewolf/werewolf_antag = mind.has_antag_datum(/datum/antagonist/werewolf, TRUE)
						if(werewolf_antag.transformed) // haha real clever of ya
							return
						held_confession.bad_type = "A BEARER OF DENDOR'S CURSE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/werewolf/lesser)
						var/datum/antagonist/werewolf/werewolf_antag = mind.has_antag_datum(/datum/antagonist/werewolf, TRUE)
						if(werewolf_antag.transformed)
							return
						held_confession.bad_type = "A BEARER OF DENDOR'S CURSE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/vampire)
						held_confession.bad_type = "A SCION OF KAINE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/vampire/lord)
						held_confession.bad_type = "THE BLOOD-LORD OF VANDERLIN"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/vampire/lesser)
						held_confession.bad_type = "AN UNDERLING OF THE BLOOD-LORD"
						held_confession.antag = initial(antag_type:name)
					if(/datum/patron/inhumen/graggar)
						held_confession.bad_type = "A FOLLOWER OF THE DARK SUN"
						held_confession.antag = "worshiper of " + initial(antag_type:name)
					/*if(/datum/patron/godless/godless) //Stonekeep Edit
						held_confession.bad_type = "A DAMNED ANTI-THEIST"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/autotheist)
						held_confession.bad_type = "A DELUSIONAL SELF-PROCLAIMED GOD"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/defiant) //need better desc
						held_confession.bad_type = "A DAMNED CHAINBREAKER"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/dystheist) //need better desc
						held_confession.bad_type = "A SPURNER OF THE DIVINE"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/naivety)
						held_confession.bad_type = "A IGNORANT FOOL"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/rashan)
						held_confession.bad_type = "A FOLLOWER OF A FALSE GOD"
						held_confession.antag = "worshiper of the false god, Rashan-Kahl"
					if(/datum/patron/inhumen/baotha)
						held_confession.bad_type = "A FOLLOWER OF THE REMORSELESS RUINER"
						held_confession.antag = "worshiper of " + initial(antag_type:name)
					*/
					else
						return // good job you tortured an innocent person
				has_confessed = TRUE
				held_confession.signed = real_name
				held_confession.info = "THE GUILTY PARTY ADMITS THEIR SINFUL NATURE AS <font color='red'>[held_confession.bad_type]</font>. THEY WILL SERVE ANY PUNISHMENT OR SERVICE AS REQUIRED BY THE ORDER OF THE PSYCROSS UNDER PENALTY OF DEATH.<br/><br/>SIGNED,<br/><font color='red'><i>[held_confession.signed]</i></font>"
				held_confession.update_appearance(UPDATE_ICON_STATE)
			return
		else
			if(torture) // Only scream your confession if it's due to torture.
				say(pick(innocent_lines), spans = list("torture"), forced = TRUE)
			else
				say(pick(innocent_lines), forced = TRUE)
			return
	to_chat(src, span_good("I resist the torture!"))
	say(pick(innocent_lines), spans = list("torture"), forced = TRUE)
	return
