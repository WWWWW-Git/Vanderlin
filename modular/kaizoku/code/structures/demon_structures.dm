#define DEMON_SPREAD_RADIUS 12
#define DEMON_CORE_BOX_NEWCORE 8
#define DEMON_HIVE_MAX_CORES 6
#define DECAL_LAYER 2.1
#define DEMON_CORE_SEED_COOLDOWN (20 SECONDS)
#define FIRST_COLONY_RANGE 8
#define SECOND_COLONY_RANGE 16
#define MIN_CORE_DISTANCE 6
#define STRUCTURE_MIN_SPACING 2

//Area of the code specific for hallucinations and whatnot
#define HALLU_MIN_INTERVAL (30 SECONDS)
#define HALLU_MAX_INTERVAL (120 SECONDS)

//Helpers and proc definitions
/proc/call_later(proc_ref, delay_seconds)
	addtimer(proc_ref, max(1, delay_seconds) SECONDS)

/proc/visible_message(msg)
	world << msg

var/global/datum/demon_hive/DEMON_HIVE
var/global/list/demon_spread_dirs = list(NORTH, SOUTH, EAST, WEST)
var/global/list/demon_all_dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
var/global/list/DEMON_SPAWNER_MATURE_TYPES = list(
	/mob/living/simple_animal/hostile/retaliate/troll,
	/mob/living/simple_animal/hostile/retaliate/blood,
	/mob/living/simple_animal/hostile/retaliate/lamia
)

/mob/living/var/ichor_next_burn_tick = 0

/proc/is_valid_corruption_turf(turf/T)
	if(!T)
		return FALSE
	if(T.density)
		return FALSE
	if(istype(T, /turf/open/transparent/openspace))
		return FALSE
	if(locate(/obj/effect/demon/corruption) in T)
		return FALSE
	// if(locate(/obj/effect/holy_ground) in T) return FALSE // Unfinished
	return TRUE

/proc/is_good_structure_spot(turf/T) //This code avoids the structures from spawning too close to each other.
	if(!T)
		return FALSE
	for(var/obj/structure/demon/DS in range(STRUCTURE_MIN_SPACING, T))
		if(istype(DS, /obj/structure/demon/railing)) //ignore railings & cocoons These are free game.
			continue
		if(istype(DS, /obj/structure/demon/cocoon))
			continue
		return FALSE
	return TRUE

/proc/pick_spread_out_spot(list/candidates) //The candidates are filtered for validity - nearest demon structure.
	if(!candidates || !candidates.len)
		return null
	var/turf/best = null
	var/best_score = -1
	for(var/turf/Ts in candidates)
		var/min_dist = 999
		for(var/obj/structure/demon/DS2 in range(12, Ts))
			if(istype(DS2, /obj/structure/demon/railing) || istype(DS2, /obj/structure/demon/cocoon))
				continue
			var/d_calc = max(abs(DS2.x - Ts.x), abs(DS2.y - Ts.y))
			if(d_calc < min_dist)
				min_dist = d_calc
		if(min_dist > best_score)
			best_score = min_dist
			best = Ts
	return best

/proc/remove_corruption_at(turf/T)
	if(!T) return
	for(var/obj/effect/demon/corruption/C in T)
		qdel(C)

/proc/pick_near_owner_spot(atom/owner, list/candidates, max_range = 2)
	if(!owner || !candidates || !candidates.len)
		return null
	var/turf/best = null
	var/best_dist = 1e9
	for(var/turf/T in candidates)
		var/d = get_dist(owner, T)
		if(max_range && d > max_range)
			continue
		if(d < best_dist)
			best_dist = d
			best = T
	if(!best)
		for(var/turf/T2 in candidates)
			var/d2 = get_dist(owner, T2)
			if(d2 < best_dist)
				best_dist = d2
				best = T2
	return best

// ---------------------------------------------------
// Hive Controller
// ---------------------------------------------------

/datum/demon_hive
	var/list/cores = list()
	var/list/corruptions = list()
	var/list/cocoons = list()
	var/obj/structure/demon/gateway/gateway
	var/is_active = FALSE
	var/colony_level = 1
	var/spread_delay_override = 0
	var/next_hallucination_at = 0
	var/hallucination_count = 0
	var/total_corruption_area = 0
	var/first_colony_railings_placed = FALSE
	var/second_colony_railings_placed = FALSE

/datum/demon_hive/proc/pick_slowdown_delay()
	var/list/buckets = list(3,5,8,12,15,20,25,30)
	return pick(buckets)

/datum/demon_hive/proc/maybe_apply_slowdown(chance)
	if(prob(chance))
		var/delay = pick_slowdown_delay()
		if(delay > spread_delay_override)
			spread_delay_override = delay

/datum/demon_hive/proc/start(anchor_loc)
	if(is_active)
		return
	is_active = TRUE
	if(!gateway || QDELETED(gateway))
		gateway = new /obj/structure/demon/gateway(anchor_loc)
	next_hallucination_at = world.time
	pulse()

/datum/demon_hive/proc/pulse()
	if(!is_active)
		return

	var/old_level = colony_level
	colony_level = (total_corruption_area >= 150) ? 2 : 1

	if(old_level != colony_level && colony_level == 2)
		visible_message("<span class='userdanger'>... The hive... grows hungry... graggar relives once more...</span>")
		upgrade_first_colony_structures()
		place_second_colony_railings()
		for(var/obj/structure/demon/spawner/SpG in world) // Colony upgraded? Force all spawners to second-colony rules.
			SpG.apply_colony_rules(2)

	if(colony_level == 1 && total_corruption_area >= 75 && !first_colony_railings_placed)
		place_first_colony_railings()
		first_colony_railings_placed = TRUE

	if(world.time >= next_hallucination_at && gateway && !QDELETED(gateway))
		send_random_hallucination()
		next_hallucination_at = world.time + rand(HALLU_MIN_INTERVAL, HALLU_MAX_INTERVAL)

	call_later(CALLBACK(src, /datum/demon_hive/proc/pulse), 15)

/datum/demon_hive/proc/place_first_colony_railings()
	if(!gateway)
		return
	for(var/obj/effect/demon/corruption/Cor in range(FIRST_COLONY_RANGE, gateway))
		for(var/dir_card in demon_spread_dirs)
			var/turf/Tc = get_step(Cor, dir_card)
			if(!Tc || !(locate(/obj/effect/demon/corruption) in Tc))
				if(!(locate(/obj/structure/demon/railing) in Cor.loc))
					var/obj/structure/demon/railing/R1 = new(Cor.loc)
					R1.dir = dir_card
				break

/datum/demon_hive/proc/place_second_colony_railings() //Second tier - second line of protection.
	if(!gateway || second_colony_railings_placed)
		return
	second_colony_railings_placed = TRUE
	for(var/obj/effect/demon/corruption/Cor2 in range(SECOND_COLONY_RANGE, gateway))
		var/dist = get_dist(gateway, Cor2)
		if(dist <= FIRST_COLONY_RANGE)
			continue
		for(var/dir_card2 in demon_spread_dirs)
			var/turf/Tc2 = get_step(Cor2, dir_card2)
			if(!Tc2 || !(locate(/obj/effect/demon/corruption) in Tc2))
				if(!(locate(/obj/structure/demon/railing) in Cor2.loc))
					var/obj/structure/demon/railing/R2 = new(Cor2.loc)
					R2.dir = dir_card2
				break

/datum/demon_hive/proc/upgrade_first_colony_structures()
	if(!gateway)
		return
	for(var/obj/structure/demon/core/CoUp in cores)
		if(get_dist(gateway, CoUp) <= FIRST_COLONY_RANGE)
			CoUp.upgrade_to_second_colony()
	for(var/obj/structure/demon/turret/TuUp in world)
		if(get_dist(gateway, TuUp) <= FIRST_COLONY_RANGE)
			TuUp.upgrade_to_second_colony()
	for(var/obj/structure/demon/spawner/SpUp in world)
		if(get_dist(gateway, SpUp) <= FIRST_COLONY_RANGE)
			SpUp.apply_colony_rules(2)

/datum/demon_hive/proc/send_random_hallucination()
	var/list/messages = list(
		" ...Flesh, always flesh... more flesh...",
		" ...I am power, I am the victor, I will feast on the lamentations of this world...",
		"...Mama, mama save me...",
		"... Lick the spewing hearts of your enemies, feast on the veins...",
		"... The Dark Star, The True God, Master, Sini-Star ...",
		"... Rip, Rip, tendons, ribbons, splatter it all...",
		"... Yes that's right, squirm on it. Bleed on the knife, it likes the way you twist...",
		"... The first squirt of hot blood, to the victor goes the spoils...",
		" ... The rush of it, when the light of their eyes fade, when hope is driven from their hearts..."
	)
	var/message = pick(messages)
	var/list/targets = list()
	for(var/mob/living/carbon/human/Hall in world)
		targets += Hall
	if(targets.len)
		var/mob/target = pick(targets)
		to_chat(target, "<span class='cult'>[message]</span>")
		hallucination_count++

/datum/demon_hive/proc/on_core_created(obj/structure/demon/core/C_new)
	if(!cores)
		cores = list()
	cores |= C_new

/datum/demon_hive/proc/on_core_destroyed(obj/structure/demon/core/C_gone)
	if(cores)
		cores -= C_gone
	for(var/obj/effect/demon/corruption/Corr in world)
		if(Corr.parent_core == C_gone)
			qdel(Corr)
	maybe_apply_slowdown(60)
	if((!gateway || QDELETED(gateway)) && (!cores || !cores.len))
		die()

/datum/demon_hive/proc/on_corruption_created(obj/effect/demon/corruption/C_make)
	if(!corruptions)
		corruptions = list()
	corruptions |= C_make
	total_corruption_area++

/datum/demon_hive/proc/on_corruption_destroyed(obj/effect/demon/corruption/C_break)
	if(corruptions)
		corruptions -= C_break
	total_corruption_area = max(0, total_corruption_area-1)
	maybe_apply_slowdown(5)

/datum/demon_hive/proc/on_cocoon_created(obj/structure/demon/cocoon/Cc_new)
	if(!cocoons)
		cocoons = list()
	cocoons |= Cc_new

/datum/demon_hive/proc/on_cocoon_destroyed(obj/structure/demon/cocoon/Cc_gone)
	if(cocoons)
		cocoons -= Cc_gone

/datum/demon_hive/proc/die()
	is_active = FALSE
	if(cores)
		for(var/obj/structure/demon/core/Cdie in cores)
			if(!QDELETED(Cdie))
				spawn(rand(10,60))
					if(!QDELETED(Cdie))
						qdel(Cdie)
	if(corruptions)
		for(var/obj/effect/demon/corruption/Corrdie in corruptions)
			if(!QDELETED(Corrdie))
				qdel(Corrdie)
	if(cocoons)
		for(var/obj/structure/demon/cocoon/Cocdie in cocoons)
			if(!QDELETED(Cocdie))
				qdel(Cocdie)
	DEMON_HIVE = null
	qdel(src)

/datum/demon_hive/proc/next_spread_delay(base_seconds)
	if(spread_delay_override > 0)
		return max(base_seconds, spread_delay_override)
	return base_seconds

// ---------------------------------------------------
// Owner-Child Relationship System (with reservation)
// ---------------------------------------------------

/datum/structure_slot
	var/slot_type
	var/occupied = FALSE
	var/reserved = FALSE
	var/obj/structure/demon/child_structure = null
	var/obj/structure/demon/cocoon/reserving_cocoon = null
	var/atom/owner = null

/datum/structure_slot/New(var/slot_name, var/owner_ref)
	slot_type = slot_name
	owner = owner_ref

/datum/structure_slot/proc/is_available()
	return !occupied && !reserved && (!child_structure || QDELETED(child_structure))

/datum/structure_slot/proc/fill_slot(var/obj/structure/demon/S)
	occupied = TRUE
	reserved = FALSE
	reserving_cocoon = null
	child_structure = S
	S.parent_slot = src

/datum/structure_slot/proc/reserve_for_cocoon(var/obj/structure/demon/cocoon/Cc)
	reserved = TRUE
	reserving_cocoon = Cc

/datum/structure_slot/proc/clear_reservation()
	reserved = FALSE
	reserving_cocoon = null

/datum/structure_slot/proc/clear_slot()
	occupied = FALSE
	if(child_structure && !QDELETED(child_structure))
		child_structure.parent_slot = null
	child_structure = null

//The main structure for demonz
/obj/structure/demon
	var/unholy = TRUE
	var/is_second_colony = FALSE
	var/datum/structure_slot/parent_slot = null

/* Stuff for later. Unfinished right now.
/obj/structure/demon/proc/reagent_act(datum/reagent/R, amount)
	if(istype(R, /datum/reagent/water/holywater))
		qdel(src)
		return
*/
/obj/structure/demon/Destroy()
	if(parent_slot)
		parent_slot.clear_slot()
	return ..()

/obj/structure/demon/proc/_apply_damage(amount)
	atom_integrity = max(0, (atom_integrity || max_integrity) - max(0, round(amount)))
	if(atom_integrity <= 0)
		qdel(src)

/obj/structure/demon/proc/_finalize_corruption_spawn(target, P, source_for_dir, anim)
	var/turf/T = target
	if(!T || QDELETED(src))
		return
	var/obj/structure/demon/core/CoreP = P
	var/obj/effect/temp_visual/expanding_corruption/A = anim
	var/obj/effect/demon/corruption/C = new /obj/effect/demon/corruption(T)
	C.parent_core = CoreP
	var/atom/from_atom = source_for_dir
	if(!from_atom)
		from_atom = src
	for(var/direction in GLOB.alldirs)
		var/turf/N = get_step(T, direction)
		if(!N)
			continue
		var/obj/effect/demon/corruption/Nc = locate(/obj/effect/demon/corruption) in N
		if(Nc && (!CoreP || Nc.parent_core == CoreP))
			from_atom = Nc
			break
	C.dir = get_dir(from_atom, T)
	C.update_icon()
	C.refresh_neighbors()
	if(A && !QDELETED(A))
		qdel(A)

/obj/structure/demon/proc/within_square_bounds(turf/T)
	return (abs(T.x - src.x) <= DEMON_SPREAD_RADIUS) && (abs(T.y - src.y) <= DEMON_SPREAD_RADIUS)

/obj/structure/demon/proc/get_organized_spread_candidates(var/obj/structure/demon/core/parent = null)
	var/list/candidates = list()
	var/list/corruption_tiles = list()
	if(parent)
		for(var/obj/effect/demon/corruption/Cp in range(DEMON_SPREAD_RADIUS, src))
			if(Cp.parent_core == parent)
				corruption_tiles += Cp
	else
		for(var/obj/effect/demon/corruption/Cu in range(DEMON_SPREAD_RADIUS, src))
			if(isnull(Cu.parent_core))
				corruption_tiles += Cu

	if(!corruption_tiles.len)
		for(var/dir_card3 in demon_spread_dirs)
			var/turf/Tcand = get_step(src, dir_card3)
			if(is_valid_corruption_turf(Tcand) && within_square_bounds(Tcand))
				candidates += Tcand
		return candidates

	for(var/obj/effect/demon/corruption/Cl in corruption_tiles)
		for(var/dir_card4 in demon_spread_dirs)
			var/turf/Tn = get_step(Cl, dir_card4)
			if(is_valid_corruption_turf(Tn) && within_square_bounds(Tn))
				if(!(Tn in candidates))
					candidates += Tn
	return candidates

// ---------------------------------------------------
// Gateway (Carcinoma)
// ---------------------------------------------------

/obj/structure/demon/gateway
	name = "CARCINOMA"
	desc = "... Malignant epithelical tumor, throbs in black ichor, connective tissues feeding the hive like a living idol...THE SOURCE OF ALL..."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_64x64.dmi'
	icon_state = "carcinoma"
	max_integrity = 500
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	var/corruption_spread_timer = 0
	var/last_core_seed = 0
	var/list/datum/structure_slot/structure_slots = list()
	var/next_structure_spawn = 0

/obj/structure/demon/gateway/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(QDELETED(src))
		return
	if(prob(30))
		playsound(get_turf(src), 'sound/misc/gods/astrata_scream.ogg', 85, FALSE)
		for(var/mob/living/M in oview(1, src))
			M.Knockdown(30)
			shake_camera(M, 4, 3)
		visible_message("<span class='danger'>[src] screams!</span>")

/obj/structure/demon/gateway/Initialize()
	. = ..()
	if(!DEMON_HIVE)
		DEMON_HIVE = new
	DEMON_HIVE.gateway = src
	for(var/mob/living/carbon/human/TSeek in world)
		if(TSeek.job == "Tideseeker")
			to_chat(TSeek, "<span class='cult'><font size=5>I LIVE AGAIN, LITTLE TIDER</font></span>")
	// (slot setup unchanged)
	structure_slots = list()
	structure_slots += new /datum/structure_slot("tendril", src)
	structure_slots += new /datum/structure_slot("turret", src)
	structure_slots += new /datum/structure_slot("spawner", src)
	structure_slots += new /datum/structure_slot("mine", src)
	structure_slots += new /datum/structure_slot("mine", src)
	structure_slots += new /datum/structure_slot("spawner", src)
	structure_slots += new /datum/structure_slot("turret", src)
	structure_slots += new /datum/structure_slot("tentacle", src)
	structure_slots += new /datum/structure_slot("tentacle", src)
	structure_slots += new /datum/structure_slot("tentacle", src)

	if(!DEMON_HIVE.is_active)
		DEMON_HIVE.start(get_turf(src))
	corruption_spread_timer = world.time
	next_structure_spawn = world.time + 30 SECONDS
	spread_corruption()
	return .

/obj/structure/demon/gateway/proc/spawn_next_structure()
	if(QDELETED(src) || !DEMON_HIVE || !DEMON_HIVE.is_active)
		return

	var/datum/structure_slot/available_slot = null
	for(var/datum/structure_slot/SL in structure_slots)
		if(SL.is_available())
			available_slot = SL
			break
	if(!available_slot)
		return

	// Collect raw ichor tiles around the gateway (no spacing filter yet)
	var/list/spawn_spots = list()
	for(var/turf/T in range(4, src))
		if(T && !T.density && !(locate(/obj/structure/demon) in T) && (locate(/obj/effect/demon/corruption) in T))
			spawn_spots += T
	if(!spawn_spots.len)
		return

	var/turf/spot = null

	if(available_slot.slot_type == "tendril")
		// Tendrils (MESOTHELIOMA) should be pretty much huging the gateway.
		// Pick the closest ichor tile within 2 tiles, then fallback to the nearest autism I made
		var/turf/best = null
		var/best_dist = 1e9
		for(var/turf/Tnear in spawn_spots)
			var/d = get_dist(src, Tnear)
			if(d <= 2 && d < best_dist)
				best_dist = d
				best = Tnear
		if(!best)
			for(var/turf/Tnear2 in spawn_spots)
				var/d2 = get_dist(src, Tnear2)
				if(d2 < best_dist)
					best_dist = d2
					best = Tnear2
		spot = best
	else
		// Non-tendrils STILL respect spacing and prefer spread-out placement, different of TENDRILS.
		var/list/spaced = list()
		for(var/turf/Ts in spawn_spots)
			if(is_good_structure_spot(Ts))
				spaced += Ts
		if(!spaced.len)
			return
		spot = pick_spread_out_spot(spaced)

	if(available_slot.slot_type == "tendril")
		var/obj/structure/demon/tentacle/Ten = new /obj/structure/demon/tentacle(spot)
		available_slot.fill_slot(Ten)
	else
		var/obj/structure/demon/cocoon/Cc = new(spot)
		Cc.cocoon_type = available_slot.slot_type
		Cc.target_slot = available_slot
		Cc.maturation_time = 60 SECONDS
		available_slot.reserve_for_cocoon(Cc)

	next_structure_spawn = world.time + 45 SECONDS

/obj/structure/demon/gateway/proc/spread_corruption()
	if(QDELETED(src) || !DEMON_HIVE || !DEMON_HIVE.is_active)
		return

	var/list/cands = get_organized_spread_candidates()
	if(cands.len)
		var/turf/Tpick = cands[1]
		spawn_corruption_with_animation(Tpick, null, src)

	try_seed_core_edge()

	if(world.time >= next_structure_spawn)
		spawn_next_structure()

	var/next = DEMON_HIVE ? DEMON_HIVE.next_spread_delay(6) : 6
	call_later(CALLBACK(src, /obj/structure/demon/gateway/proc/spread_corruption), next)

/obj/structure/demon/gateway/proc/try_seed_core_edge()
	if(DEMON_HIVE && DEMON_HIVE.cores && DEMON_HIVE.cores.len >= DEMON_HIVE_MAX_CORES)
		return
	if(world.time < last_core_seed + DEMON_CORE_SEED_COOLDOWN)
		return
	var/minx = 1e9, miny = 1e9, maxx = -1e9, maxy = -1e9
	var/list/owned = list()
	for(var/obj/effect/demon/corruption/Cov in range(DEMON_SPREAD_RADIUS, src))
		if(!isnull(Cov.parent_core))
			continue
		owned += Cov
		if(Cov.x < minx)
			minx = Cov.x
		if(Cov.y < miny)
			miny = Cov.y
		if(Cov.x > maxx)
			maxx = Cov.x
		if(Cov.y > maxy)
			maxy = Cov.y
	if(!owned.len)
		return
	var/w = (maxx - minx + 1)
	var/h = (maxy - miny + 1)
	if(w < DEMON_CORE_BOX_NEWCORE && h < DEMON_CORE_BOX_NEWCORE)
		return
	if(!prob(15))
		return

	var/list/spots = list()
	for(var/obj/effect/demon/corruption/Cov2 in owned)
		if(get_dist(src, Cov2) < MIN_CORE_DISTANCE)
			continue

		var/too_close_to_core = FALSE
		for(var/obj/structure/demon/core/existing_core in DEMON_HIVE.cores)
			if(get_dist(existing_core, Cov2) < MIN_CORE_DISTANCE)
				too_close_to_core = TRUE
				break
		if(too_close_to_core)
			continue

		if(Cov2.x == minx)
			var/turf/Tw = locate(Cov2.x - 1, Cov2.y, Cov2.z)
			if(Tw && !Tw.density && !(locate(/obj/structure/demon) in Tw) && !(locate(/obj/effect/demon/corruption) in Tw))
				if(is_good_structure_spot(Tw))
					spots += Tw
		if(Cov2.x == maxx)
			var/turf/Te = locate(Cov2.x + 1, Cov2.y, Cov2.z)
			if(Te && !Te.density && !(locate(/obj/structure/demon) in Te) && !(locate(/obj/effect/demon/corruption) in Te))
				if(is_good_structure_spot(Te))
					spots += Te
		if(Cov2.y == miny)
			var/turf/Ts = locate(Cov2.x, Cov2.y - 1, Cov2.z)
			if(Ts && !Ts.density && !(locate(/obj/structure/demon) in Ts) && !(locate(/obj/effect/demon/corruption) in Ts))
				if(is_good_structure_spot(Ts))
					spots += Ts
		if(Cov2.y == maxy)
			var/turf/Tn = locate(Cov2.x, Cov2.y + 1, Cov2.z)
			if(Tn && !Tn.density && !(locate(/obj/structure/demon) in Tn) && !(locate(/obj/effect/demon/corruption) in Tn))
				if(is_good_structure_spot(Tn))
					spots += Tn
	if(!spots.len)
		return

	var/obj/structure/demon/cocoon/Cc_new = new /obj/structure/demon/cocoon(pick_spread_out_spot(spots))
	Cc_new.cocoon_type = "core"
	Cc_new.maturation_time = 120 SECONDS
	last_core_seed = world.time
	visible_message("<span class='userdanger'>... A throbbing mass buds at the colony's edge...</span>")

// ---------------------------------------------------
// Core (Sarcoma)
// ---------------------------------------------------

/obj/structure/demon/core
	name = "SARCOMA"
	desc = "... malignant tumors of connective tissue with twisted folds resulting in a strangely feminine frame... an open womb."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_64x64.dmi'
	icon_state = "thewomb"
	max_integrity = 300
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	var/corruption_spread_timer = 0
	var/corruption_count = 0
	var/max_corruption = 25
	var/placed_railings = FALSE
	var/list/datum/structure_slot/structure_slots = list()
	var/next_structure_spawn = 0

/obj/structure/demon/core/Initialize()
	. = ..()
	if(!DEMON_HIVE)
		DEMON_HIVE = new
	DEMON_HIVE.on_core_created(src)

	structure_slots = list()
	structure_slots += new /datum/structure_slot("tendril", src)
	structure_slots += new /datum/structure_slot("turret", src)
	structure_slots += new /datum/structure_slot("spawner", src)
	structure_slots += new /datum/structure_slot("mine", src)
	structure_slots += new /datum/structure_slot("mine", src)
	structure_slots += new /datum/structure_slot("spawner", src)
	structure_slots += new /datum/structure_slot("tentacle", src)
	structure_slots += new /datum/structure_slot("tentacle", src)
	structure_slots += new /datum/structure_slot("tentacle", src)

	corruption_spread_timer = world.time
	next_structure_spawn = world.time + 45 SECONDS
	spread_corruption()
	return .

/obj/structure/demon/core/Destroy()
	if(DEMON_HIVE)
		DEMON_HIVE.on_core_destroyed(src)
	return ..()

/obj/structure/demon/core/proc/upgrade_to_second_colony()
	if(is_second_colony)
		return
	is_second_colony = TRUE
	max_integrity = round(max_integrity * 1.5)
	atom_integrity = max_integrity
	max_corruption = 40
	visible_message("<span class='danger'>[src]'s tissue pulses and restructures into a sturdier frame.</span>")

/obj/structure/demon/core/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(QDELETED(src))
		return
	if(prob(15))
		playsound(get_turf(src), 'sound/misc/gods/astrata_scream.ogg', 85, FALSE)
		for(var/mob/living/M in oview(1, src))
			M.Knockdown(30)
			shake_camera(M, 4, 3)
		visible_message("<span class='danger'>[src] screams!</span>")

/obj/structure/demon/core/proc/spawn_next_structure()
	if(QDELETED(src) || !DEMON_HIVE || !DEMON_HIVE.is_active)
		return

	var/datum/structure_slot/available_slot = null
	for(var/datum/structure_slot/SLc in structure_slots)
		if(SLc.is_available())
			available_slot = SLc
			break
	if(!available_slot)
		return

	// Collect raw ichor tiles owned by this core (no spacing filter yet)
	var/list/spawn_spots = list()
	for(var/obj/effect/demon/corruption/C in range(3, src))
		if(C.parent_core == src && !(locate(/obj/structure/demon) in C.loc))
			spawn_spots += C.loc
	if(!spawn_spots.len)
		return

	var/turf/spot = null

	if(available_slot.slot_type == "tendril")
		// Core tendrils hug their owning core.
		var/turf/best = null
		var/best_dist = 1e9
		for(var/turf/Tnear in spawn_spots)
			var/d = get_dist(src, Tnear)
			if(d <= 2 && d < best_dist)
				best_dist = d
				best = Tnear
		if(!best)
			for(var/turf/Tnear2 in spawn_spots)
				var/d2 = get_dist(src, Tnear2)
				if(d2 < best_dist)
					best_dist = d2
					best = Tnear2
		spot = best
	else
		var/list/spaced = list()
		for(var/turf/Ts in spawn_spots)
			if(is_good_structure_spot(Ts))
				spaced += Ts
		if(!spaced.len)
			return
		spot = pick_spread_out_spot(spaced)

	if(available_slot.slot_type == "tendril")
		var/obj/structure/demon/tentacle/Ten2 = new /obj/structure/demon/tentacle(spot)
		available_slot.fill_slot(Ten2)
	else
		var/obj/structure/demon/cocoon/Cc4 = new(spot)
		Cc4.cocoon_type = available_slot.slot_type
		Cc4.target_slot = available_slot
		Cc4.maturation_time = 60 SECONDS
		available_slot.reserve_for_cocoon(Cc4)

	next_structure_spawn = world.time + 60 SECONDS

/obj/structure/demon/core/proc/spread_corruption()
	if(QDELETED(src) || !DEMON_HIVE || !DEMON_HIVE.is_active)
		return

	var/list/cands = get_organized_spread_candidates(src)
	if(cands.len && corruption_count < max_corruption)
		var/turf/Tpick = cands[1]
		var/atom/source_for_dir = src

		for(var/dir_all in demon_all_dirs)
			var/turf/Nt = get_step(Tpick, dir_all)
			if(!Nt) continue
			var/obj/effect/demon/corruption/Nc = locate(/obj/effect/demon/corruption) in Nt
			if(Nc && Nc.parent_core == src)
				source_for_dir = Nc
				break

		spawn_corruption_with_animation(Tpick, src, source_for_dir)
		corruption_count++

	if(corruption_count >= max_corruption && !placed_railings)
		placed_railings = TRUE
		place_railings_around_own_corruption()

	if(world.time >= next_structure_spawn)
		spawn_next_structure()

	var/next = DEMON_HIVE ? DEMON_HIVE.next_spread_delay(8) : 8
	call_later(CALLBACK(src, /obj/structure/demon/core/proc/spread_corruption), next)

/obj/structure/demon/core/proc/place_railings_around_own_corruption()
	for(var/obj/effect/demon/corruption/CorOwn in range(DEMON_SPREAD_RADIUS, src))
		if(CorOwn.parent_core != src)
			continue
		for(var/dir_card5 in demon_spread_dirs)
			var/turf/Tb = get_step(CorOwn, dir_card5)
			if(!Tb)
				continue
			if(!(locate(/obj/effect/demon/corruption) in Tb))
				if(!(locate(/obj/structure/demon/railing) in CorOwn.loc))
					var/obj/structure/demon/railing/Rown = new(CorOwn.loc)
					Rown.dir = dir_card5

// ---------------------------------------------------
// Corruption tile (METASTASIS)
// ---------------------------------------------------

/obj/effect/demon/corruption
	name = "METASTASIS"
	desc = "Viscous black ichor crawling over the ground."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_32x32.dmi'
	icon_state = "ichor_single"
	layer = DECAL_LAYER
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_ICON
	var/health = 40
	var/max_health = 40
	var/obj/structure/demon/core/parent_core = null
	var/unholy = TRUE
	var/list/edge_objs = null
	var/full_variant = 0

/obj/effect/demon/corruption/Initialize()
	. = ..()
	if(DEMON_HIVE)
		DEMON_HIVE.on_corruption_created(src)
	update_icon()
	refresh_neighbors()
	update_edges()

/obj/effect/demon/corruption/Destroy()
	refresh_neighbors()
	clear_edge_overlays()
	if(DEMON_HIVE)
		DEMON_HIVE.on_corruption_destroyed(src)
	return ..()

/obj/effect/demon/corruption/attackby(obj/item/I, mob/user)
	if(!I)
		return
	var/damage = (I.force >= 8) ? rand(6,12) : 0
	if(!damage)
		return
	shake_camera(user, 2, 1)
	playsound(get_turf(src), 'sound/foley/meatslap.ogg', 50, TRUE)
	health -= damage
	if(health <= 0)
		qdel(src)

/obj/effect/demon/corruption/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		if(FACTION_CABAL in (L.faction || list()))
			return
		if(!(L.mob_biotypes & MOB_SPIRIT))
			if(world.time >= (L.ichor_next_burn_tick || 0))
				L.adjustFireLoss(rand(2,4))
				to_chat(L, "<span class='warning'>The ichor sears your skin.</span>")
				L.ichor_next_burn_tick = world.time + 20

/obj/effect/demon/corruption/take_damage(amount, damage_type)
	. = ..()
	health -= max(0, amount)
	if(health <= 0)
		qdel(src)

/obj/effect/demon/corruption/proc/has_neighbor(D)
	var/turf/Tnb = get_step(src, D)
	if(!Tnb)
		return FALSE
	if(locate(/obj/structure/demon) in Tnb)
		return FALSE
	return !!(locate(/obj/effect/demon/corruption) in Tnb)

/obj/effect/demon/corruption/proc/refresh_neighbors()
	for(var/D in GLOB.alldirs)
		var/turf/T = get_step(src, D)
		if(!T)
			continue
		for(var/obj/effect/demon/corruption/C in T)
			C.update_icon()
			C.update_edges()
	update_edges()

/obj/effect/demon/corruption/update_icon()
	. = ..()
	var/n = has_neighbor(NORTH)
	var/e = has_neighbor(EAST)
	var/s = has_neighbor(SOUTH)
	var/w = has_neighbor(WEST)
	var/count = (n?1:0) + (e?1:0) + (s?1:0) + (w?1:0)
	if(count <= 0)
		icon_state = "ichor_single"
		dir = SOUTH
		return
	if(count == 1)
		icon_state = "ichor_end"
		if(n)      dir = NORTH
		else if(e) dir = EAST
		else if(s) dir = SOUTH
		else       dir = WEST
		return
	if(count == 2)
		if((n && s) || (e && w))
			icon_state = "ichor_straight"
			dir = (n && s) ? NORTH : EAST
		else
			icon_state = "ichor_curve"
			if(n && e)      dir = NORTHEAST
			else if(e && s) dir = SOUTHEAST
			else if(s && w) dir = SOUTHWEST
			else            dir = NORTHWEST
		return
	if(count == 3)
		icon_state = "ichor_t"
		if(!n)      dir = NORTH
		else if(!e) dir = EAST
		else if(!s) dir = SOUTH
		else        dir = WEST
		return
	if(!full_variant)
		full_variant = rand(1,3)
	icon_state = "ichor_full[full_variant]"
	dir = SOUTH
	update_edges()

/obj/effect/demon/corruption/proc/clear_edge_overlays()
	if(!edge_objs)
		return
	for(var/obj/effect/decal/corruption_rim/R in edge_objs)
		if(!QDELETED(R))
			R.remove_supporter()
	edge_objs.Cut()

/obj/effect/demon/corruption/proc/_neighbor_has_corruption(turf/T)
	if(!T)
		return FALSE
	if(locate(/obj/structure/demon) in T)
		return FALSE
	return !!(locate(/obj/effect/demon/corruption) in T)

/obj/effect/demon/corruption/proc/_ensure_rim_on(turf/T, typepath, dirval)
	if(!T)
		return null
	for(var/obj/effect/decal/corruption_rim/R in T)
		if(istype(R, typepath) && R.dir == dirval)
			R.add_supporter()
			return R
	var/obj/effect/decal/corruption_rim/N = new typepath(T, dirval)
	return N

/obj/effect/demon/corruption/proc/update_edges()
	var/turf/T = get_turf(src)
	if(!T)
		return
	clear_edge_overlays()
	edge_objs = list()
	var/has_N = has_neighbor(NORTH)
	var/has_S = has_neighbor(SOUTH)
	var/has_E = has_neighbor(EAST)
	var/has_W = has_neighbor(WEST)
	if(!has_N)
		var/turf/Nt = get_step(T, NORTH)
		if(Nt)
			var/obj/effect/decal/corruption_edge/E1 = _ensure_rim_on(Nt, /obj/effect/decal/corruption_edge, SOUTH)
			if(E1) edge_objs += E1
	if(!has_S)
		var/turf/St = get_step(T, SOUTH)
		if(St)
			var/obj/effect/decal/corruption_edge/E2 = _ensure_rim_on(St, /obj/effect/decal/corruption_edge, NORTH)
			if(E2) edge_objs += E2
	if(!has_E)
		var/turf/Et = get_step(T, EAST)
		if(Et)
			var/obj/effect/decal/corruption_edge/E3 = _ensure_rim_on(Et, /obj/effect/decal/corruption_edge, WEST)
			if(E3) edge_objs += E3
	if(!has_W)
		var/turf/Wt = get_step(T, WEST)
		if(Wt)
			var/obj/effect/decal/corruption_edge/E4 = _ensure_rim_on(Wt, /obj/effect/decal/corruption_edge, EAST)
			if(E4) edge_objs += E4
	var/turf/NEN = get_step(T, NORTHEAST)
	var/turf/NWN = get_step(T, NORTHWEST)
	var/turf/SEN = get_step(T, SOUTHEAST)
	var/turf/SWN = get_step(T, SOUTHWEST)
	var/openN = !has_N
	var/openS = !has_S
	var/openE = !has_E
	var/openW = !has_W
	if(openN && openE && NEN && !_neighbor_has_corruption(NEN))
		var/obj/effect/decal/corruption_corner/C1 = _ensure_rim_on(NEN, /obj/effect/decal/corruption_corner, SOUTHWEST)
		if(C1) edge_objs += C1
	if(openN && openW && NWN && !_neighbor_has_corruption(NWN))
		var/obj/effect/decal/corruption_corner/C2 = _ensure_rim_on(NWN, /obj/effect/decal/corruption_corner, SOUTHEAST)
		if(C2) edge_objs += C2
	if(openS && openE && SEN && !_neighbor_has_corruption(SEN))
		var/obj/effect/decal/corruption_corner/C3 = _ensure_rim_on(SEN, /obj/effect/decal/corruption_corner, NORTHWEST)
		if(C3) edge_objs += C3
	if(openS && openW && SWN && !_neighbor_has_corruption(SWN))
		var/obj/effect/decal/corruption_corner/C4 = _ensure_rim_on(SWN, /obj/effect/decal/corruption_corner, NORTHEAST)
		if(C4) edge_objs += C4

/obj/structure/demon/proc/spawn_corruption_with_animation(turf/where, obj/structure/demon/core/owner_core, atom/source_for_dir)
	if(!where)
		return
	var/obj/effect/temp_visual/expanding_corruption/A = new /obj/effect/temp_visual/expanding_corruption(where)
	A.plan_finalize(owner_core, source_for_dir)

/obj/effect/temp_visual/expanding_corruption
	name = "METASTASIS SPREAD"
	desc = "The corruption spreads..."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_32x32.dmi'
	icon_state = "ichor_anim"
	layer = DECAL_LAYER
	anchored = TRUE
	density = FALSE
	mouse_opacity = 0

/obj/effect/temp_visual/expanding_corruption/Initialize()
	. = ..()
	flick("ichor_anim", src)
	QDEL_IN(src, duration)
	return .

/obj/effect/temp_visual/expanding_corruption/proc/plan_finalize(obj/structure/demon/core/core_ref, atom/source_for_dir)
	addtimer(CALLBACK(src, .proc/finalize_spawn, core_ref, source_for_dir), duration)

/obj/effect/temp_visual/expanding_corruption/proc/finalize_spawn(obj/structure/demon/core/core_ref, atom/source_for_dir)
	if(QDELETED(src) || !loc)
		return
	var/turf/T = loc
	var/obj/effect/demon/corruption/C = new(T)
	C.parent_core = core_ref
	var/atom/from_atom = source_for_dir || core_ref
	if(!from_atom) from_atom = C
	for(var/D in GLOB.alldirs)
		var/turf/N = get_step(T, D)
		if(!N) continue
		var/obj/effect/demon/corruption/Nc = locate(/obj/effect/demon/corruption) in N
		if(Nc && (!core_ref || Nc.parent_core == core_ref))
			from_atom = Nc
			break
	C.dir = get_dir(from_atom, T)
	C.update_icon()
	C.refresh_neighbors()
	qdel(src)

/obj/effect/decal/corruption_rim
	name = ""
	desc = ""
	icon = 'modular/kaizoku/icons/mapset/carcinoma_32x32.dmi'
	icon_state = null
	mouse_opacity = 0
	anchored = TRUE
	layer = DECAL_LAYER + 0.01
	var/supporters = 0

/obj/effect/decal/corruption_rim/New(loc, dirval)
	. = ..()
	dir = dirval
	supporters = 1

/obj/effect/decal/corruption_rim/proc/add_supporter()
	supporters++

/obj/effect/decal/corruption_rim/proc/remove_supporter()
	supporters--
	if(supporters <= 0)
		qdel(src)

/obj/effect/decal/corruption_edge
	parent_type = /obj/effect/decal/corruption_rim

/obj/effect/decal/corruption_edge/New(loc, dirval)
	. = ..()
	switch(dirval)
		if(NORTH) icon_state = "ichor_edge-n[rand(1,3)]"
		if(SOUTH) icon_state = "ichor_edge-s[rand(1,3)]"
		if(EAST)  icon_state = "ichor_edge-e[rand(1,3)]"
		if(WEST)  icon_state = "ichor_edge-w[rand(1,3)]"

/obj/effect/decal/corruption_corner
	parent_type = /obj/effect/decal/corruption_rim

/obj/effect/decal/corruption_corner/New(loc, dirval)
	. = ..()
	switch(dirval)
		if(NORTHEAST) icon_state = "ichor_corner-ne[rand(1,3)]"
		if(NORTHWEST) icon_state = "ichor_corner-nw[rand(1,3)]"
		if(SOUTHEAST) icon_state = "ichor_corner-se[rand(1,3)]"
		if(SOUTHWEST) icon_state = "ichor_corner-sw[rand(1,3)]"


// ---------------------------------------------------
// Cocoons
// ---------------------------------------------------

/obj/structure/demon/cocoon
	name = "METAPLASIA"
	desc = "A pulsing, organic cocoon. Something is growing inside..."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_64x64.dmi'
	icon_state = "rebuild"
	max_integrity = 100
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	var/cocoon_type = "turret" // turret, tendril, core, spawner, mine
	var/maturation_time = 120 SECONDS
	var/matures_at = 0
	var/obj/structure/demon/gateway/owner_gateway = null
	var/obj/structure/demon/core/owner_core = null
	var/datum/structure_slot/target_slot = null

/obj/structure/demon/cocoon/Initialize()
	. = ..()
	if(DEMON_HIVE)
		DEMON_HIVE.on_cocoon_created(src)
	matures_at = world.time + max(10, maturation_time)
	START_PROCESSING(SSfastprocess, src)

/obj/structure/demon/cocoon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(target_slot)
		target_slot.clear_reservation()
	if(DEMON_HIVE)
		DEMON_HIVE.on_cocoon_destroyed(src)
	return ..()

/obj/structure/demon/cocoon/process()
	if(world.time >= matures_at)
		mature()

/obj/structure/demon/cocoon/proc/mature()
	if(QDELETED(src))
		return
	var/obj/structure/demon/created = null
	switch(cocoon_type)
		if("turret")
			created = new /obj/structure/demon/turret(loc)
		if("tendril")
			created = new /obj/structure/demon/tendril(loc)
		if("core")
			created = new /obj/structure/demon/core(loc)
		if("spawner")
			created = new /obj/structure/demon/spawner(loc)
		if("mine")
			created = new /obj/structure/demon/mine(loc)
	if(created && target_slot)
		target_slot.fill_slot(created)
	qdel(src)

/obj/structure/demon/cocoon/take_damage(amount, damage_type)
	. = ..()
	var/dmg = max(0, round(amount))
	if(dmg <= 0)
		return
	qdel(src)

// ---------------------------------------------------
// Tentacle (walk-through, paralyze+poison)
// ---------------------------------------------------

/obj/structure/demon/tentacle
	name = "LEIMYOMA"
	desc = "... Smooth fibrous tissues elongated into coiling appendages that disperses poison... You better not have fun ideas with it, degenerate."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_64x64.dmi'
	icon_state = "tentacle"
	anchored = TRUE
	max_integrity = 200
	density = FALSE
	layer = OBJ_LAYER

/obj/structure/demon/tentacle/Crossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(FACTION_CABAL in (L.faction || list()))
		return
	L.Paralyze(20)
	if(istype(L, /mob/living/carbon))
		var/mob/living/carbon/Ccar = L
		if(Ccar.reagents)
			if(prob(50))
				Ccar.reagents.add_reagent(/datum/reagent/berrypoison, 0.5)
			else
				Ccar.reagents.add_reagent(/datum/reagent/stampoison, 1)

// ---------------------------------------------------
// Tendril guardian (Mesothelioma)
// ---------------------------------------------------

/obj/structure/demon/tendril
	name = "MESOTHELIOMA"
	desc = "Protector of the malignant cores, corrupted tree with joint tissues with sharp bones as blades. Even dendor shall weep."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_64x64.dmi'
	icon_state = "slashtree"
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	pixel_x = -16
	var/radius = 2
	var/active = FALSE
	max_integrity = 200
	var/anchor_gateway
	attacked_sound = list('modular/kaizoku/sound/woosh/zatana_nimble(1).ogg','modular/kaizoku/sound/woosh/zatana_nimble(2).ogg','modular/kaizoku/sound/woosh/zatana_nimble(3).ogg')

/obj/structure/demon/tendril/Initialize()
	. = ..()
	call_later(CALLBACK(src, /obj/structure/demon/tendril/proc/tick), 3)

/obj/structure/demon/tendril/proc/tick()
	if(QDELETED(src) || !DEMON_HIVE || !DEMON_HIVE.is_active)
		return
	var/has_targets = FALSE
	for(var/mob/living/Lt in oview(radius, src))
		if(!(FACTION_CABAL in (Lt.faction || list())))
			has_targets = TRUE
			break
	active = has_targets
	if(active)
		lash()
	call_later(CALLBACK(src, /obj/structure/demon/tendril/proc/tick), active ? 3 : 8)

/obj/structure/demon/tendril/proc/lash()
	var/list/targets = list()
	for(var/mob/living/Lt2 in oview(radius, src))
		if(!(FACTION_CABAL in (Lt2.faction || list())))
			targets += Lt2
	if(!targets.len)
		return

	flick("slashtree_attack", src)
	playsound(get_turf(src), pick(attacked_sound), 100)

	for(var/mob/living/Lt3 in targets)
		var/list/limb_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_CHEST, BODY_ZONE_HEAD)
		var/zone = pick(limb_zones)
		var/obj/item/bodypart/target_bp = Lt3.get_bodypart(zone)
		var/damage = rand(20,40) //Don't stay near this.
		var/wound_class = BCLASS_CUT
		var/protected = FALSE

		if(target_bp && zone == BODY_ZONE_HEAD) //Checks for head protection.
			for(var/obj/item/clothing/Cl in Lt3.contents)
				if(Cl.slot_flags & ITEM_SLOT_HEAD)
					if(islist(Cl.prevent_crits) && (wound_class in Cl.prevent_crits))
						protected = TRUE
						to_chat(Lt3, "<span class='notice'>[Cl] catches the barbs from [src]!</span>")
						break
		//Seems vulnerable...
		if(target_bp && zone == BODY_ZONE_HEAD && !protected)
			var/obj/item/I = Lt3.get_item_by_slot(ITEM_SLOT_HEAD) //If the head is unprotected even with a headslot, push it off.
			if(I)
				Lt3.doUnEquip(I)
				I.forceMove(get_turf(Lt3))
			Lt3.visible_message(
				"<span class='danger'>Barbed tendrils from [src] scythe across [Lt3]'s neck, severing the head!</span>",
				"<span class='userdanger'>A barbed lash bites your neck—your head is torn free!</span>"
			)
			var/obj/item/bodypart/head = Lt3.get_bodypart(BODY_ZONE_HEAD)
			if(head)
				head.dismember()
			Lt3.emote("scream")
			continue
		if(protected) //The head was protected? Then continue with a normal behavior.
			continue

		Lt3.visible_message(
			"<span class='danger'>Barbed tendrils whip from [src], raking [Lt3]'s [parse_zone(zone)]!</span>",
			"<span class='userdanger'>Barbed tendrils rake your [parse_zone(zone)]!</span>"
		)
		Lt3.apply_damage(damage, BRUTE, zone)

		if(target_bp)
			var/datum/wound/W
			if(prob(15))
				W = new /datum/wound/slash/large()
			else if(prob(35))
				W = new ((damage > 10) ? /datum/wound/slash : /datum/wound/slash/small)
			if(W)
				W.apply_to_bodypart(target_bp, FALSE, TRUE)
				Lt3.visible_message("<span class='warning'>[Lt3]'s [parse_zone(zone)] is torn open by barbs!</span>")

/obj/structure/demon/tendril/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(QDELETED(src))
		return

// ---------------------------------------------------
// Turret & projectile (Angiosarcoma)
// ---------------------------------------------------

/obj/structure/demon/turret
	name = "ANGIOSARCOMA"
	desc = "... Swollen blood vessels compacted into a maligned mass in mockery of the steadfast, coughing gouts of blistering rot ..."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_64x64.dmi'
	icon_state = "turret"
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	max_integrity = 200
	var/fire_cooldown = 6 SECONDS
	var/last_fire = 0
	var/range = 6

/obj/structure/demon/turret/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/demon/turret/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/demon/turret/proc/upgrade_to_second_colony()
	if(is_second_colony)
		return
	is_second_colony = TRUE
	max_integrity = round(max_integrity * 1.5)
	atom_integrity = max_integrity
	fire_cooldown = 5 SECONDS
	range = 8
	visible_message("<span class='danger'>[src] hums... the fibers contracting.</span>")

/obj/structure/demon/turret/process()
	if(QDELETED(src) || !DEMON_HIVE || !DEMON_HIVE.is_active)
		return
	if(world.time < last_fire + fire_cooldown)
		return
	var/mob/living/target = null
	for(var/mob/living/Ltt in oview(range, src))
		if(!(FACTION_CABAL in (Ltt.faction || list())))
			if(!target || get_dist(src, Ltt) < get_dist(src, target))
				target = Ltt
	if(target)
		fire_at_target(target)
		last_fire = world.time

/obj/structure/demon/turret/proc/fire_at_target(mob/living/target)
	if(!target || QDELETED(target))
		return
	dir = get_dir(src, target)
	var/obj/projectile/demon/glop/P = new /obj/projectile/demon/glop(get_turf(src))
	P.firer = src
	P.fired_from = src
	P.is_second_colony = is_second_colony
	var/base = dir2angle(get_dir(src, target))
	var/spread = rand(-6, 6)
	P.fire(base + spread)
	flick("turret_crack", src)
	playsound(get_turf(src), 'sound/foley/meatslap.ogg', 60, FALSE)

/obj/projectile/demon/glop
	name = "rot"
	icon = 'modular/kaizoku/icons/mapset/carcinoma_32x32.dmi'
	icon_state = "glop"
	speed = 2
	range = 12
	damage = 0
	var/is_second_colony = FALSE

/obj/projectile/demon/glop/on_hit(atom/target, blocked)
	if(isliving(target))
		var/mob/living/Lhit = target
		var/dmg = is_second_colony ? rand(30,20) : rand(20,10)
		Lhit.adjustFireLoss(dmg)
		Lhit.visible_message("<span class='danger'>rot splashes over [Lhit]!</span>", "<span class='userdanger'>The glop rot burns your flesh!</span>")
	return ..()

// ---------------------------------------------------
// Demon railing (Glioma)
// ---------------------------------------------------

/obj/structure/demon/railing
	name = "GLIOMA"
	desc = "... Only the disgrace can thread, doorways leading to the mouth of dispair ..."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_32x32.dmi'
	icon_state = "fence"
	density = FALSE
	anchored = TRUE
	flags_1 = ON_BORDER_1
	climbable = TRUE
	var/pass_crawl = FALSE
	layer = ABOVE_MOB_LAYER

/obj/structure/demon/railing/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(isobserver(mover))
		return TRUE
	if(istype(mover, /mob/camera))
		return TRUE
	if(istype(mover, /obj/projectile))
		return TRUE
	if(mover.throwing)
		return TRUE
	if(isliving(mover))
		var/mob/living/M = mover
		if(FACTION_CABAL in (M.faction || list()))
			return TRUE
		if(get_dir(loc, target) == dir)
			return FALSE
	return TRUE

/obj/structure/demon/railing/CanAStarPass(ID, to_dir, requester)
	if(isliving(requester))
		var/mob/living/Mr = requester
		if(FACTION_CABAL in (Mr.faction || list()))
			return TRUE
		if(to_dir == dir)
			return FALSE
	return TRUE

/obj/structure/demon/railing/do_climb(atom/movable/A, mob/user)
	if(isliving(user))
		var/mob/living/Mu = user
		if(!(FACTION_CABAL in (Mu.faction || list())))
			to_chat(Mu, "<span class='warning'>The bones from that thing would impale you alive.</span>")
			return FALSE
	return ..()

// ---------------------------------------------------
// Demon Mine (Carcinoid)
// ---------------------------------------------------

/obj/structure/demon/mine
	name = "HEMAGNGIOMA"
	desc = "... Blood vessel... ready to burst into a spray of acidic pus..."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_64x64.dmi'
	icon_state = "mine"
	anchored = TRUE
	density = FALSE
	layer = OBJ_LAYER - 0.1
	max_integrity = 100
	alpha = 180
	var/armed = TRUE
	var/explosion_damage = 25

/obj/structure/demon/mine/Crossed(atom/movable/AM)
	. = ..()
	if(!armed)
		return
	if(isliving(AM))
		var/mob/living/Lm = AM
		if(!(FACTION_CABAL in (Lm.faction || list())))
			explode(Lm)

/obj/structure/demon/mine/proc/explode(mob/living/trigger_mob = null)
	if(!armed)
		return
	armed = FALSE

	visible_message("<span class='userdanger'>[src]'s acidic pus is sprayed as it explodes!</span>")
	playsound(get_turf(src), 'sound/misc/explode/explosionclose (1).ogg', 100, FALSE)

	new /obj/effect/temp_visual/explosion(get_turf(src))

	for(var/mob/living/Lme in range(2, src))
		if(FACTION_CABAL in (Lme.faction || list()))
			continue
		var/distance = get_dist(src, Lme)
		var/damage_mult = 1.0
		switch(distance)
			if(0)
				damage_mult = 1.5
			if(1)
				damage_mult = 1.0
			if(2)
				damage_mult = 0.5
		var/acid_damage = round(explosion_damage * damage_mult)
		var/fire_damage = round((explosion_damage * 0.7) * damage_mult)
		Lme.adjustFireLoss(fire_damage)
		Lme.adjustBruteLoss(acid_damage)
		Lme.visible_message("<span class='danger'>[Lme] is caught in the acidic explosion!</span>",
				  "<span class='userdanger'>Fetid smell- and extreme burn.</span>")
		if(distance <= 1)
			if(istype(Lme, /mob/living/carbon))
				var/mob/living/carbon/Cme = Lme
				if(Cme.reagents)
					Cme.apply_status_effect(/datum/status_effect/debuff/acidsplash, 2)
		shake_camera(Lme, 5, 4)

	for(var/obj/O in range(1, src))
		if(istype(O, /obj/structure/demon))
			continue
		if(istype(O, /atom/movable) && istype(O, /obj))
			if(istype(O, /obj/structure))
				var/obj/structure/OS = O
				OS.take_damage(explosion_damage, BURN)

// ---------------------------------------------------
//The Hyperplasia
//>>Essentially an "Spawner"
//>Very limited spawn amount until maturation; Low cooldown per respawn.
//>Proper for spawning a BUNCH of enemies on the edges of a demon colony.
// ---------------------------------------------------
/mob/living/var/obj/structure/demon/spawner/spawner_parent = null

/obj/structure/demon/spawner
	name = "HYPERPLASIA"
	desc = "... malformed creatures are made from here..."
	icon = 'modular/kaizoku/icons/mapset/carcinoma_64x64.dmi'
	icon_state = "spawner"
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	max_integrity = 300
	var/spawn_cooldown = 60 SECONDS
	var/next_spawn = 0
	var/owned_limit = 2
	var/check_radius = 8
	var/is_mature = FALSE
	var/matures_at = 0
	var/mature_delay = (60 SECONDS) // 20 minutes until it matures. ; 1200 seconds; put it 60 for testing.

/obj/structure/demon/spawner/Initialize()
	. = ..()
	apply_colony_rules(DEMON_HIVE ? DEMON_HIVE.colony_level : 1)
	matures_at = world.time + mature_delay
	START_PROCESSING(SSfastprocess, src)
	next_spawn = world.time + rand(5, 12)

/obj/structure/demon/spawner/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/demon/spawner/proc/apply_colony_rules(colony_level)
	if(colony_level >= 2)
		is_second_colony = TRUE
		owned_limit = 1
		spawn_cooldown = 120 SECONDS
	else
		is_second_colony = FALSE
		owned_limit = 2
		spawn_cooldown = 60 SECONDS

/obj/structure/demon/spawner/proc/become_mature(force_now = FALSE)
	if(is_mature && !force_now)
		return

	is_mature = TRUE
	if(max_integrity)
		max_integrity = round(max_integrity * 1.5)
		atom_integrity = max_integrity
	else
		if(!isnum(atom_integrity))
			atom_integrity = 0
		atom_integrity += 50
	if(icon_state != "spawner_mature")
		icon_state = "spawner_mature"
	if(name != "MATURE HYPERPLASIA")
		name = "MATURE HYPERPLASIA"
	visible_message("<span class='warning'>[src] contracts…</span>")


/obj/structure/demon/spawner/proc/get_spawn_list()
	var/list/base_pool = list( 	// Base pool (first colony / unmatured fallback)
		/mob/living/simple_animal/hostile/retaliate/spider,
		/mob/living/simple_animal/hostile/retaliate/wolf,
		/mob/living/carbon/human/species/goblin/npc/ambush/hell
	)
	if(is_mature && DEMON_SPAWNER_MATURE_TYPES && DEMON_SPAWNER_MATURE_TYPES.len) //Anti-runtime purposes, since you NEVER know.
		return DEMON_SPAWNER_MATURE_TYPES
	return base_pool

/obj/structure/demon/spawner/process()
	if(!is_mature && world.time >= matures_at)
		become_mature()

	if(world.time < next_spawn)
		return

	var/owned_near = 0
	for(var/mob/living/Ls in view(check_radius, src))
		if(Ls.spawner_parent == src)
			owned_near++

	if(owned_near >= owned_limit)
		next_spawn = world.time + (spawn_cooldown / 2)
		return

	if(locate(/mob/living) in loc)
		next_spawn = world.time + (spawn_cooldown / 2)
		return

	var/list/_choices = get_spawn_list()
	var/mob_type = pick(_choices)

	var/mob/living/new_mob = new mob_type(loc)
	if(new_mob)
		if(!islist(new_mob.faction))
			new_mob.faction = list()
		if(!(FACTION_CABAL in new_mob.faction))
			new_mob.faction += FACTION_CABAL
		new_mob.spawner_parent = src
		visible_message("<span class='danger'>A [new_mob.name] sloughs out of [src]!</span>")

	next_spawn = world.time + spawn_cooldown

/obj/structure/demon/spawner/mature //If someone wants to spawn it already mature.
	name = "MATURE HYPERPLASIA"
	icon_state = "spawner_mature"

/obj/structure/demon/spawner/mature/Initialize()
	. = ..()
	become_mature(TRUE)

// ---------------------------------------------------
// Utilities
// ---------------------------------------------------

/proc/SpawnDemonIncursion(turf/center, cores = 2)
	if(!center)
		return
	if(!DEMON_HIVE)
		DEMON_HIVE = new
	new /obj/structure/demon/gateway(center)
	cores = min(cores, 2)
	var/list/radials = list(NORTH, SOUTH, EAST, WEST)
	for(var/i=1, i<=cores, i++)
		var/dir_pick = pick(radials)
		radials -= dir_pick
		var/turf/Tc5 = get_step(center, dir_pick)
		for(var/attempts = 0; attempts < 10; attempts++)
			Tc5 = locate(center.x + rand(-8, 8), center.y + rand(-8, 8), center.z)
			if(Tc5 && !Tc5.density && get_dist(center, Tc5) >= MIN_CORE_DISTANCE)
				break
		if(Tc5 && !Tc5.density)
			if(is_good_structure_spot(Tc5))
				var/obj/structure/demon/cocoon/Cc6 = new /obj/structure/demon/cocoon(Tc5)
				Cc6.cocoon_type = "core"
				Cc6.maturation_time = 120 SECONDS
	DEMON_HIVE.start(center)

/proc/DemonHiveStatus()
	if(!DEMON_HIVE)
		return "No demon hive active"
	var/colony_status = (DEMON_HIVE.colony_level == 2) ? "Second Colony" : "First Colony"
	return "Cores: [DEMON_HIVE.cores?.len || 0] | Corruption: [DEMON_HIVE.corruptions?.len || 0] | Cocoons: [DEMON_HIVE.cocoons?.len || 0] | Hallu Sent: [DEMON_HIVE.hallucination_count] | Colony: [colony_status]"

// ---------------------------------------------------

#undef DEMON_SPREAD_RADIUS
#undef DEMON_CORE_BOX_NEWCORE
#undef DEMON_HIVE_MAX_CORES
#undef DECAL_LAYER
#undef DEMON_CORE_SEED_COOLDOWN
#undef FIRST_COLONY_RANGE
#undef SECOND_COLONY_RANGE
#undef MIN_CORE_DISTANCE
#undef HALLU_MIN_INTERVAL
#undef HALLU_MAX_INTERVAL

//testing shit
/*
/obj/structure/demon/gateway/reagent_act(datum/reagent/R, amount)
	if(istype(R, /datum/reagent/water/holywater))
		_apply_damage(round(amount * 3))
		visible_message("<span class='warning'>[src] sizzles and steams from the holy water!</span>")
		return

/obj/structure/demon/core/reagent_act(datum/reagent/R, amount)
	if(istype(R, /datum/reagent/water/holywater))
		_apply_damage(round(amount * 2))
		visible_message("<span class='warning'>[src] smolders under the holy water!</span>")
		return

/obj/effect/demon/corruption/proc/reagent_act(datum/reagent/R, amount)
	if(istype(R, /datum/reagent/water/holywater))
		qdel(src)
		return
*/
