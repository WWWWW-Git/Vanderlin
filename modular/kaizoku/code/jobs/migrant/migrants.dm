/datum/job/kaizoku/migrant // /datum/job/pilgrim
	title = "Migrant"
	tutorial = "Placeholder."
	department_flag = FACTIONLESS
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = KZ_MIGRANT
	faction = FACTION_FOREIGNERS
	total_positions = 20
	spawn_positions = 20
	min_pq = -20
	banned_leprosy = FALSE
	bypass_lastclass = TRUE

	allowed_races = RACES_PLAYER_ALL

	outfit = null
	outfit_female = null
	advclass_cat_rolls = list(CAT_MIGRANT = 15)

	same_job_respawn_delay = 0

	is_foreigner = TRUE
	can_have_apprentices = TRUE

	selection_color = "#a33096" //Change this...?
