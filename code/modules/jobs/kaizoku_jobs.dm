GLOBAL_LIST_INIT(noble_positions, list(
	/datum/job/kaizoku/sovereign::title,
	/datum/job/kaizoku/clanmember::title,
	/datum/job/kaizoku/doyen::title,
	/datum/job/kaizoku/performer::title,
	/datum/job/kaizoku/menial::title,

))
GLOBAL_PROTECT(noble_positions)

GLOBAL_LIST_INIT(garrison_positions, list(
	/datum/job/kaizoku/bachelor::title, //STONEKEEP EDIT: Removal
	/datum/job/kaizoku/militia::title,
	/datum/job/kaizoku/retainer::title,
	/datum/job/kaizoku/spectacler::title,
	))
GLOBAL_PROTECT(garrison_positions)

GLOBAL_LIST_INIT(church_positions, list(
	/datum/job/kaizoku/prophet::title,
	/datum/job/kaizoku/stormcaller::title,
	/datum/job/kaizoku/mastersohei::title,
	/datum/job/kaizoku/tideseeker::title,
	/datum/job/kaizoku/votary::title,
	))
GLOBAL_PROTECT(church_positions)

GLOBAL_LIST_INIT(serf_positions, list(

	/datum/job/kaizoku/panderer::title,
	/datum/job/kaizoku/cutthroat::title,
	/datum/job/kaizoku/tosher::title,
	/datum/job/kaizoku/massager::title,
	/datum/job/kaizoku/silkrunner::title,
	))
GLOBAL_PROTECT(serf_positions)

GLOBAL_LIST_INIT(peasant_positions, list(
	/datum/job/kaizoku/lowlife::title,
))
GLOBAL_PROTECT(peasant_positions)

GLOBAL_LIST_INIT(apprentices_positions, list(
/*
	/datum/job/bapprentice::title,
	/datum/job/wapprentice::title,
	/datum/job/servant::title,
	/datum/job/tapster::title,
	/datum/job/gaffer_assistant::title,
	/datum/job/orphan::title,
*/
	))
GLOBAL_PROTECT(apprentices_positions)

GLOBAL_LIST_INIT(youngfolk_positions, list(
/*
	/datum/job/innkeep_son::title,
	/datum/job/orphan::title,
	/datum/job/churchling::title,
*/
))
GLOBAL_PROTECT(youngfolk_positions)

GLOBAL_LIST_INIT(company_positions, list(//Stonekeep Edit start: The Quartermaster has its own faction.
	/datum/job/kaizoku/quartermaster::title,
	/datum/job/kaizoku/sieger::title,
	/datum/job/kaizoku/raider::title,
	/datum/job/kaizoku/seamen::title, //Stonekeep Edit Ending
	))

GLOBAL_PROTECT(company_positions)

GLOBAL_LIST_INIT(allmig_positions, list(
	/datum/job/kaizoku/citizen::title,
	/datum/job/kaizoku/migrant::title,
	/datum/job/kaizoku/wanderer::title,
	))

GLOBAL_LIST_INIT(roguewar_positions, list(
//	"Adventurer",
	))

GLOBAL_LIST_INIT(test_positions, list(
	"Tester",
	))

GLOBAL_LIST_EMPTY(job_assignment_order)

/proc/get_job_assignment_order()
	var/list/sorting_order = list()
	sorting_order += GLOB.noble_positions
	sorting_order += GLOB.garrison_positions
	sorting_order += GLOB.church_positions
	sorting_order += GLOB.serf_positions
	sorting_order += GLOB.company_positions
	sorting_order += GLOB.peasant_positions
	sorting_order += GLOB.apprentices_positions
	sorting_order += GLOB.allmig_positions
	sorting_order += GLOB.youngfolk_positions
	return sorting_order

GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_TOWNER = list("titles" = peasant_positions | apprentices_positions | youngfolk_positions | serf_positions | company_positions),
	EXP_TYPE_NOBLE = list("titles" = noble_positions),
	EXP_TYPE_CHURCH = list("titles" = church_positions),
	EXP_TYPE_GUARDS = list("titles" = garrison_positions),
	EXP_TYPE_ADVENTURER = list("titles" = allmig_positions),
))

GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_ANTAG = list(),
	EXP_TYPE_GHOST = list(), // dead people, observers
))
GLOBAL_PROTECT(exp_jobsmap)
GLOBAL_PROTECT(exp_specialmap)
