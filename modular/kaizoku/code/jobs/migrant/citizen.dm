/datum/job/kaizoku/citizen
	title = "Citizen"
	tutorial = "You are a citizen, granted privileges that people \
	from other nations will never taste. Though you are no longer trapped \
	in filth, everything you hold is balanced on blood in this decaying world. \
	As war looms ever closer, you understand that survival is never guaranteed, \
	and the fog hides dangers that no law can shield you from, even more for those \
	like you whom never properly trained for war."
	department_flag = FACTION_CITIZENS
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	faction = FACTION_FOREIGNERS
	display_order = KZ_CITIZEN
	total_positions = 20
	spawn_positions = 20
	min_pq = -100
	banned_leprosy = FALSE
	bypass_lastclass = TRUE
	advclass_cat_rolls = list(CTAG_CITIZEN = 20)
	allowed_races = RACES_PLAYER_ALL
	outfit = null
	outfit_female = null

	give_bank_account = TRUE

/datum/job/kaizoku/citizen/after_spawn(mob/living/carbon/spawned, client/player_client)
	..()

/datum/job/kaizoku/citizen/New()
	. = ..()
	for(var/X in GLOB.peasant_positions)
		peopleiknow += X
		peopleknowme += X
	for(var/X in GLOB.serf_positions)
		peopleiknow += X
	for(var/X in GLOB.church_positions)
		peopleiknow += X
	for(var/X in GLOB.garrison_positions)
		peopleiknow += X
	for(var/X in GLOB.noble_positions)
		peopleiknow += X
