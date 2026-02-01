#define BB_FALCON_CURRENT_TARGET "falcon_current_target"
#define BB_FALCON_PERCH_TARGET "falcon_perch_target"
#define BB_FALCON_PERCH_TYPES "falcon_perch_types"
#define BB_FALCON_WANT_PERCH "falcon_want_perch"
#define BB_SUMMONER "summoner"
#define BB_FOCUS_TARGETS "focus_targets"
#define BB_PATROLLING "patrolling"
#define BB_FOLLOWING "following"
#define BB_TARGETTING_DATUM "targetting_datum"

/datum/ai_controller/falcon
	movement_delay = 0.4 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_FOCUS_TARGETS = list(),
		BB_PATROLLING = FALSE,
		BB_FOLLOWING = FALSE,
		BB_SUMMONER = null,
		BB_FALCON_PERCH_TYPES = list(),
		BB_FALCON_WANT_PERCH = FALSE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/falcon_custom_targeting,
		/datum/ai_planning_subtree/falcon_perch_behavior,
	)
	idle_behavior = /datum/idle_behavior/idle_random_walk
