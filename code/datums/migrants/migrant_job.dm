//This one is NOT Kaizoku's migrants. Disregard.

/// A basis for migrants allowing for infinite selection and setting relevant variables.
/// Positions and min_pq should not be changed.
/datum/job/migrant
	abstract_type = /datum/job/migrant
	title = "Migrant"
	department_flag = FACTIONLESS
	job_flags = NONE
	display_order = KZ_THISSUCKS
	faction = FACTION_MIGRANTS
	total_positions = 0
	spawn_positions = 0
	min_pq = -999
	is_foreigner = TRUE

	allowed_races = RACES_PLAYER_ALL
	allowed_sexes = list(MALE, FEMALE)

/// For cases where you have an advanced class migrant with no migrant job.
/datum/job/migrant/generic
