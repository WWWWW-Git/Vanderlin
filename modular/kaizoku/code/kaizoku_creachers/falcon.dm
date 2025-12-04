//This animal alongside the Doggo has been organized this way because I seriously can't organize the code otherwise.
//Feel free to change it. In fact, I encourage you to do it. I just can't waste time on it right now.

//================== MACROS ==================

#define BB_FALCON_CURRENT_TARGET "falcon_current_target"
#define BB_FALCON_PERCH_TARGET "falcon_perch_target"
#define BB_FALCON_PERCH_TYPES "falcon_perch_types"
#define BB_FALCON_WANT_PERCH "falcon_want_perch"
#define BB_FALCON_DELIVERING_PAPER "falcon_delivering_paper"

#define TRAIT_FALCON_PERCHED "falcon_perched"
#define TRAIT_FALCON_FROZEN "falcon_frozen"
#define PERCH_SOURCE "perched"


//================== AI CONTROLLER ==================

/datum/ai_controller/falcon
	movement_delay = 0.4 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/falcon_patrol(),
		BB_FOCUS_TARGETS = list(),
		BB_PATROLLING = FALSE,
		BB_FOLLOWING = FALSE,
		BB_SUMMONER = null,
		BB_FALCON_PERCH_TYPES = list(),
		BB_FALCON_WANT_PERCH = FALSE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/falcon_behavior,
		/datum/ai_planning_subtree/falcon_perch_behavior,
	)
	idle_behavior = /datum/idle_behavior/idle_random_walk


// Focus targeting: Falcon only attacks mobs in its focus_targets list
/datum/targetting_datum/falcon_focus/can_attack(mob/living/living_mob, atom/the_target)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F = living_mob
	if(F.focus_targets && (the_target in F.focus_targets))
		return TRUE
	return FALSE

// Patrol targeting: Falcon attacks valid enemies, never self/summoner
/datum/targetting_datum/falcon_patrol/can_attack(mob/living/living_mob, atom/the_target)
	if(!the_target || !ismob(the_target)) return FALSE
	if(the_target == living_mob) return FALSE
	// Only check summoner for falcon mobs
	if(istype(living_mob, /mob/living/simple_animal/hostile/retaliate/custodianpet/falcon))
		var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F = living_mob
		if(the_target == F.summoner)
			return FALSE

	var/mob/H = the_target
	if(islist(H.faction) && ("orcs" in H.faction)) return TRUE
	if(isnum(H:mob_biotypes) && (H:mob_biotypes & MOB_UNDEAD)) return TRUE
	// Add more factions or conditions as needed here
	return FALSE

//================== PLANNING SUBTREE ==================

/datum/ai_behavior/falcon_unperch

/datum/ai_behavior/falcon_unperch/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/falcon_pawn = controller.pawn

	if(!HAS_TRAIT(falcon_pawn, TRAIT_FALCON_PERCHED))
		finish_action(controller, FALSE)
		return

	// If buckled to a human, unbuckle
	if(falcon_pawn.buckled)
		falcon_pawn.buckled.unbuckle_mob(falcon_pawn)
	else
		// If just perched on an object, toggle off
		falcon_pawn.toggle_perched(perched = FALSE)

	finish_action(controller, TRUE)
	return TRUE

/datum/ai_planning_subtree/falcon_behavior

/datum/ai_planning_subtree/falcon_behavior/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/falcon_pawn = controller.pawn
	if(!istype(falcon_pawn))
		return

	if(falcon_pawn && falcon_pawn.delivering_letter_anim)
		return SUBTREE_RETURN_FINISH_PLANNING
	if(HAS_TRAIT(falcon_pawn, TRAIT_FALCON_FROZEN)) // This will, ahem, "Shortcircuit" the animal. It won't move while perched.
		return SUBTREE_RETURN_FINISH_PLANNING
	if(HAS_TRAIT(falcon_pawn, TRAIT_FALCON_PERCHED) && controller.blackboard_key_exists(BB_FALCON_CURRENT_TARGET)) //We have a target while perched? Then unpearch first.
		controller.queue_behavior(/datum/ai_behavior/falcon_unperch)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(controller.blackboard[BB_FALCON_DELIVERING_PAPER]) //Priority one: Paper delivery. Your spiritual companion is getting bombarded by the enemy!
		return SUBTREE_RETURN_FINISH_PLANNING //Remember to NOT do anything else while you deliver the paper.

	var/list/focus_targets = controller.blackboard[BB_FOCUS_TARGETS] //Priority two: Attack the enemy you've been told to focus on. THIS CAN BE ANYONE OR ANYTHING.
	if(length(focus_targets))
		var/mob/target = null
		var/closest_dist = INFINITY
		for(var/mob/M in focus_targets)
			if(QDELETED(M))
				controller.blackboard[BB_FOCUS_TARGETS] -= M
				continue
			var/dist = get_dist(falcon_pawn, M)
			if(dist < closest_dist)
				closest_dist = dist
				target = M

		if(target)
			controller.set_blackboard_key(BB_FALCON_CURRENT_TARGET, target)
			controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/falcon, BB_FALCON_CURRENT_TARGET, BB_TARGETTING_DATUM, null)
			return SUBTREE_RETURN_FINISH_PLANNING

	var/want_perch = controller.blackboard[BB_FALCON_WANT_PERCH] //Second priority. This portion of the code handles perching command.
	if(want_perch && controller.blackboard_key_exists(BB_FALCON_PERCH_TARGET))
		var/atom/perch_target = controller.blackboard[BB_FALCON_PERCH_TARGET]
		if(!QDELETED(perch_target))
			var/dist = get_dist(falcon_pawn, perch_target)
			if(dist > 1)
				controller.queue_behavior(/datum/ai_behavior/falcon_follow, BB_FALCON_PERCH_TARGET) //Moves towards the target with pathfinding functions.
				return SUBTREE_RETURN_FINISH_PLANNING
			else
				controller.queue_behavior(/datum/ai_behavior/falcon_perch_on_target, BB_FALCON_PERCH_TARGET) //Well, the falcon is having issues. So snap on it instantly instead.
				return SUBTREE_RETURN_FINISH_PLANNING

	var/following = controller.blackboard[BB_FOLLOWING] //Priority three: Follow summonner when asked to.
	var/mob/summoner = controller.blackboard[BB_SUMMONER]
	if(following && summoner && !QDELETED(summoner))
		var/dist = get_dist(falcon_pawn, summoner)
		if(dist > 2)
			controller.queue_behavior(/datum/ai_behavior/falcon_follow, BB_SUMMONER)
			return SUBTREE_RETURN_FINISH_PLANNING

	var/patrolling = controller.blackboard[BB_PATROLLING] //Priority four: If not following the summoner, you are patrolling for enemies.
	if(patrolling)
		var/patrol_target = null
		var/closest_patrol_dist = INFINITY
		for(var/mob/M in hearers(7, falcon_pawn))
			var/datum/targetting_datum/falcon_patrol/td = new /datum/targetting_datum/falcon_patrol
			if(td.can_attack(falcon_pawn, M))
				var/dist = get_dist(falcon_pawn, M)
				if(dist < closest_patrol_dist)
					closest_patrol_dist = dist
					patrol_target = M

		if(patrol_target)
			controller.set_blackboard_key(BB_FALCON_CURRENT_TARGET, patrol_target)
			controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/falcon, BB_FALCON_CURRENT_TARGET, BB_TARGETTING_DATUM, null)
			return SUBTREE_RETURN_FINISH_PLANNING
		else
			controller.queue_behavior(/datum/ai_behavior/falcon_patrol)
			return SUBTREE_RETURN_FINISH_PLANNING

	if(summoner && !QDELETED(summoner)) //Priority five; Default 'follow summoner' but more relaxed, more likely to perch around to rest.
		var/dist = get_dist(falcon_pawn, summoner)
		if(dist > 3)
			controller.queue_behavior(/datum/ai_behavior/falcon_follow, BB_SUMMONER)
			return SUBTREE_RETURN_FINISH_PLANNING
	return

/datum/ai_planning_subtree/falcon_perch_behavior //This is a subtree so the bird perches on targets.
	var/perch_chance = 8 //Chance to perch
	var/unperch_chance = 12 //Chance to unperch

/datum/ai_planning_subtree/falcon_perch_behavior/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/falcon_pawn = controller.pawn
	var/is_perched = HAS_TRAIT(falcon_pawn, TRAIT_FALCON_PERCHED)

	if(HAS_TRAIT(falcon_pawn, TRAIT_FALCON_FROZEN))
		return SUBTREE_RETURN_FINISH_PLANNING

	if(is_perched)
		if((prob(unperch_chance) || controller.blackboard_key_exists(BB_FALCON_CURRENT_TARGET)))
			controller.queue_behavior(/datum/ai_behavior/falcon_unperch)
			return SUBTREE_RETURN_FINISH_PLANNING
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!prob(perch_chance) || controller.blackboard_key_exists(BB_FALCON_CURRENT_TARGET) || controller.blackboard[BB_FALCON_WANT_PERCH]) //Doing nothing? Perch and relax.
		return

	if(controller.blackboard_key_exists(BB_FALCON_PERCH_TARGET))
		controller.queue_behavior(/datum/ai_behavior/falcon_wait_and_perch, BB_FALCON_PERCH_TARGET) // Instead of instantly queuing perch, use new AI behavior for approach-and-perch
		return SUBTREE_RETURN_FINISH_PLANNING
	var/mob/summoner = controller.blackboard[BB_SUMMONER] //75% chance to perch on summoner if they're nearby, 25% chance for objects
	if(prob(75) && summoner && !QDELETED(summoner) && get_dist(falcon_pawn, summoner) <= 3)
		controller.set_blackboard_key(BB_FALCON_PERCH_TARGET, summoner)
		controller.queue_behavior(/datum/ai_behavior/falcon_perch_on_target, BB_FALCON_PERCH_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	else
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list, BB_FALCON_PERCH_TARGET, controller.blackboard[BB_FALCON_PERCH_TYPES])
		return

/datum/ai_behavior/falcon_wait_and_perch
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/falcon_wait_and_perch/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/falcon_pawn = controller.pawn
	var/mob/living/carbon/human/target = controller.blackboard[target_key]
	if(QDELETED(falcon_pawn) || QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	var/dist = get_dist(falcon_pawn, target)
	if(dist > 1)
		set_movement_target(controller, target)
		return

	if(falcon_pawn.start_perching(target)) 	// Adjacent? Then try to perch!
		finish_action(controller, TRUE, target_key)
	else
		finish_action(controller, FALSE, target_key)

//================== FALCON BEHAVIORS ==================

/datum/ai_behavior/falcon_follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/falcon_follow/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/falcon_follow/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	var/mob/falcon_pawn = controller.pawn
	var/dist = get_dist(falcon_pawn, target)

	var/required_distance = controller.blackboard[BB_FALCON_WANT_PERCH] ? 1 : 2	// If we're following for perch command, get closer

	if(dist <= required_distance)
		finish_action(controller, TRUE, target_key)
		return

	// Keep updating movement target
	set_movement_target(controller, target)

/datum/ai_behavior/falcon_patrol

/datum/ai_behavior/falcon_patrol/perform(delta_time, datum/ai_controller/controller)
	var/mob/falcon_pawn = controller.pawn
	var/mob/summoner = controller.blackboard[BB_SUMMONER]

	if(!summoner || QDELETED(summoner))
		finish_action(controller, FALSE)
		return

	var/patrol_radius = 5 // Pick a random location within patrol radius of summoner
	var/target_x = summoner.x + rand(-patrol_radius, patrol_radius)
	var/target_y = summoner.y + rand(-patrol_radius, patrol_radius)
	var/turf/target_turf = locate(target_x, target_y, summoner.z)

	if(target_turf)
		controller.set_movement_target(target_turf)
		spawn(30) // Move to new location after 3 seconds
			if(controller && !QDELETED(falcon_pawn))
				finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/falcon_perch_on_target // Falcon behavior that allows them to perch on a target.
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/falcon_perch_on_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	controller.set_movement_target(target)

/datum/ai_behavior/falcon_perch_on_target/perform(delta_time, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		finish_action(controller, FALSE)
		return

	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/falcon_pawn = controller.pawn
	var/dist = get_dist(falcon_pawn, target)

	if(dist > 1)
		controller.set_movement_target(target)
		return

	// Only try to perch if adjacent
	// This will call buckle_mob and "teleport" onto the player
	if(falcon_pawn.start_perching(target))
		controller.blackboard[BB_FALCON_WANT_PERCH] = FALSE
		finish_action(controller, TRUE)
	else
		controller.blackboard[BB_FALCON_WANT_PERCH] = FALSE
		finish_action(controller, FALSE)

/datum/ai_behavior/falcon_perch_on_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

//================== FALCON MELEE ATTACK ==================

/datum/ai_behavior/basic_melee_attack/falcon
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/falcon/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/falcon_pawn = controller.pawn
	if(falcon_pawn.next_click && world.time < falcon_pawn.next_click)
		return

	var/atom/target = controller.blackboard[target_key]
	if(!istype(falcon_pawn) || QDELETED(target))
		finish_action(controller, FALSE)
		return

	var/dist = get_dist(falcon_pawn, target)
	if(dist > 1)
		controller.set_movement_target(target)
		return

	if(dist <= 1 && isliving(target))
		var/mob/living/L = target
		var/list/limb_zones = list(
			BODY_ZONE_L_ARM, BODY_ZONE_R_ARM,
			BODY_ZONE_L_LEG, BODY_ZONE_R_LEG,
			BODY_ZONE_CHEST, BODY_ZONE_HEAD
		)
		var/zone = pick(limb_zones)
		var/obj/item/bodypart/target_bp = L.get_bodypart(zone)
		var/damage = rand(falcon_pawn.melee_damage_lower, falcon_pawn.melee_damage_upper)
		var/wound_class = BCLASS_CUT //Talons = cutting

		var/protected = FALSE //First, armor protection check.
		if(target_bp)
			if(zone == BODY_ZONE_HEAD) //First, check helmets.
				for(var/obj/item/clothing/C in L.contents)
					if(C.slot_flags & ITEM_SLOT_HEAD)
						if(islist(C.prevent_crits) && (wound_class in C.prevent_crits))
							protected = TRUE
							to_chat(L, "<span class='notice'>[C] deflects the falcon's talons!</span>")
							break
			else if(zone == BODY_ZONE_PRECISE_R_EYE || zone == BODY_ZONE_PRECISE_L_EYE)
				for(var/obj/item/clothing/C in L.contents)
					if(C.slot_flags & ITEM_SLOT_MASK)
						if(islist(C.prevent_crits) && (wound_class in C.prevent_crits))
							protected = TRUE
							to_chat(L, "<span class='notice'>[C] protects your eye from the falcon's talons!</span>")
							break

		if(protected)
			// Only cooldown, NO sound, NO visible_message, NO damage, NO wounds
			falcon_pawn.next_click = world.time + (falcon_pawn.melee_attack_cooldown || 15)
			finish_action(controller, TRUE, target_key)
			return

		// ---------- ATTACK ONLY IF NOT PROTECTED ------------------
		falcon_pawn.visible_message("<span class='danger'>[falcon_pawn] swoops down at [L], talons sink into [L.p_their()] [parse_zone(zone)]!</span>", COMBAT_MESSAGE_RANGE)
		playsound(get_turf(falcon_pawn), pick(falcon_pawn.attack_sound), 60, TRUE)
		L.apply_damage(damage, BRUTE, zone)

		// -- CRIT WOUND/GOUGE --
		if(target_bp)
			if(zone == BODY_ZONE_HEAD && prob(25))
				var/eye_type
				var/eye_side
				if(prob(50))
					eye_type = /datum/wound/facial/eyes/right
					eye_side = "right"
				else
					eye_type = /datum/wound/facial/eyes/left
					eye_side = "left"
				if(!L.has_wound(eye_type))
					var/datum/wound/W = new eye_type()
					W.apply_to_bodypart(target_bp, FALSE, TRUE)
					L.visible_message("<span class='critical'>[L]'s [eye_side] eye is gouged by sharp talons!</span>")
				else
					if(prob(10))
						var/datum/wound/W = new /datum/wound/slash/large()
						W.apply_to_bodypart(target_bp, FALSE, TRUE)
						L.visible_message("<span class='warning'>[L]'s [parse_zone(zone)] is deeply gouged!</span>")
					else if(prob(30))
						var/wound_type = damage > 18 ? /datum/wound/slash : /datum/wound/slash/small
						var/datum/wound/W = new wound_type()
						W.apply_to_bodypart(target_bp, FALSE, TRUE)
						L.visible_message("<span class='warning'>[L]'s [parse_zone(zone)] is cut open!</span>")
			else
				if(prob(10))
					var/datum/wound/W = new /datum/wound/slash/large()
					W.apply_to_bodypart(target_bp, FALSE, TRUE)
					L.visible_message("<span class='warning'>[L]'s [parse_zone(zone)] is deeply gouged!</span>")
				else if(prob(30))
					var/wound_type = damage > 18 ? /datum/wound/slash : /datum/wound/slash/small
					var/datum/wound/W = new wound_type()
					W.apply_to_bodypart(target_bp, FALSE, TRUE)
					L.visible_message("<span class='warning'>[L]'s [parse_zone(zone)] is cut open!</span>")

		// ------ SET NEXT ATTACK TIME -----
		falcon_pawn.next_click = world.time + (falcon_pawn.melee_attack_cooldown || 15)
		finish_action(controller, TRUE, target_key)
		return

/proc/OnFalconBuckled(mob/living/carbon/human/H, mob/living/M)
	H.update_falcon_perched_overlay()

/proc/OnFalconUnbuckled(mob/living/carbon/human/H, mob/living/M)
	H.update_falcon_perched_overlay()

/mob/living/carbon/human/proc/update_falcon_perched_overlay()
	if(falcon_perched_overlay)
		overlays -= falcon_perched_overlay
		falcon_perched_overlay = null

	// Only show overlay if falcon is actually buckled to us
	if(buckled_mobs)
		for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F in buckled_mobs)
			if(QDELETED(F) || F.stat == DEAD)
				continue
			// Only show the overlay, don't touch falcon invisibility
			falcon_perched_overlay = image(F.icon, F.icon_perched, F.dir)
			falcon_perched_overlay.pixel_x = 7
			falcon_perched_overlay.pixel_y = 8
			overlays += falcon_perched_overlay
			break

/mob/living/simple_animal/hostile/retaliate/custodianpet
	ai_controller = /datum/ai_controller/falcon
	max_buckled_mobs = 0
	var/summoner = null
	var/list/focus_targets = list()
	var/patrolling = FALSE
	var/following = FALSE
	var/delivering_paper = FALSE
	var/obj/item/paper/held_paper = null
	var/delivery_target = null
	var/old_following_state = FALSE
	var/delivering_letter_anim = FALSE
	var/has_smoke = FALSE
	var/obj/item/clothing/face/cigarette/rollie/falcon_smoke = null

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon
	name = "saintalon"
	desc = "The saintalon, whom each dive is a judgemental rite as the winged covenant of the skies. It like to smoke rollies."
	icon = 'modular/kaizoku/icons/mobs/falcon.dmi'
	icon_state = "falcon"
	icon_living = "falcon"
	icon_dead = "falcon_dead"
	environment_smash = ENVIRONMENT_SMASH_NONE
	pass_flags = PASSTABLE|PASSGRILLE
	limb_destroyer = 1
	movement_type = FLYING
	density = TRUE
	melee_damage_lower = 15
	melee_damage_upper = 20
	health = 100
	maxHealth = 100
	emote_see = list("scans the horizon", "judges you with a gaze", "swoops low.")
	speak_chance = 2
	attack_sound = list('modular/kaizoku/sound/animals/saintalon/saintalon_1.ogg','modular/kaizoku/sound/animals/saintalon/saintalon_1.ogg','modular/kaizoku/sound/animals/saintalon/saintalon_7.ogg','modular/kaizoku/sound/animals/saintalon/saintalon_2.ogg')
	butcher_results = list(/obj/item/reagent_containers/food/snacks/fat = 1,
						/obj/item/reagent_containers/food/snacks/meat/poultry = 1,
						/obj/item/natural/feather = 1)
	perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/fat = 1,
						/obj/item/reagent_containers/food/snacks/meat/poultry = 1,
						/obj/item/reagent_containers/food/snacks/meat/poultry/cutlet = 1,
						/obj/item/natural/feather = 1)
	food_type = list(/obj/item/natural/worms,
				/obj/item/reagent_containers/food/snacks/smallrat,
				/obj/item/reagent_containers/food/snacks/meat,
				/obj/item/reagent_containers/food/snacks/produce/grain/wheat,
				/obj/item/reagent_containers/food/snacks/produce/grain/oat)
	var/icon_perched = "falcon_perch"

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/Initialize(mapload)
	. = ..()
	base_pixel_x = pixel_x
	base_pixel_y = pixel_y
	if(ai_controller)
		ai_controller.blackboard[BB_SUMMONER] = summoner
		ai_controller.blackboard[BB_FOCUS_TARGETS] = focus_targets
		ai_controller.blackboard[BB_PATROLLING] = patrolling
		ai_controller.blackboard[BB_FOLLOWING] = following
		ai_controller.blackboard[BB_FALCON_WANT_PERCH] = FALSE
		ai_controller.blackboard[BB_FALCON_PERCH_TYPES] = list(
			/obj/structure/table,
			/obj/structure/chair,
			/obj/structure/bed,
			/obj/machinery,
			/obj/structure/statue
		)

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	if(HAS_TRAIT(src, TRAIT_FALCON_PERCHED))
		if(src.has_smoke)
			icon_state = "falcon_perch_smoke"
		else
			icon_state = icon_perched
	else
		if(src.has_smoke)
			icon_state = "falcon_smoke"
		else
			icon_state = icon_living
	if(buckled && istype(buckled, /mob/living/carbon/human))
		invisibility = 101
	else
		invisibility = 0

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/can_be_perched(mob/living/carbon/human/user)
	return stat != DEAD && !buckled

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/on_perched(mob/living/carbon/human/holder)
	ADD_TRAIT(src, TRAIT_FALCON_FROZEN, "perching")
	toggle_perched(TRUE)
	visible_message("<span class='notice'>[src] perches obediently on [holder]'s arm.</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/on_unperched()
	REMOVE_TRAIT(src, TRAIT_FALCON_FROZEN, "perching")
	toggle_perched(FALSE)
	update_icon_state() // Always force visual reset
	visible_message("<span class='notice'>[src] leaps off!</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/resist_from_perch()
	if(buckled)
		var/mob/living/carbon/human/H = buckled
		H.unbuckle_mob(src)
		update_icon_state() // Make sure sprite switches to non-perched!
	else
		toggle_perched(perched = FALSE)
		update_icon_state()

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/perch_on_human(mob/living/carbon/human/target)
	if(LAZYLEN(target.buckled_mobs) >= target.max_buckled_mobs)
		return FALSE
	// Always forceMove onto their tile before buckling, to be 100% sure
	var/old_dense = src.density
	src.density = FALSE
	src.forceMove(get_turf(target))
	src.density = old_dense
	sleep(1) // Sometimes you need a tick for forceMove to register

	// Now buckle
	if(!target.buckle_mob(src, TRUE))
		return FALSE
	on_perched(target)
	RegisterSignal(src, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_unbuckle))
	return TRUE

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/on_unbuckle(mob/living/source, atom/movable/new_buckled)
	SIGNAL_HANDLER
	if(new_buckled)
		return
	on_unperched()
	UnregisterSignal(src, COMSIG_LIVING_SET_BUCKLED)

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/after_move(atom/source)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	toggle_perched(perched = FALSE)

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/toggle_perched(perched)
	if(!perched)
		REMOVE_TRAIT(src, TRAIT_FALCON_PERCHED, PERCH_SOURCE)
		pixel_x = base_pixel_x
		pixel_y = base_pixel_y
	else
		ADD_TRAIT(src, TRAIT_FALCON_PERCHED, PERCH_SOURCE)
		pixel_y = base_pixel_y + 9
	update_icon_state()

#undef PERCH_SOURCE

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/toggle_patrol(mob/user)
	patrolling = !patrolling
	following = FALSE
	if(ai_controller)
		ai_controller.blackboard[BB_PATROLLING] = patrolling
		ai_controller.blackboard[BB_FOLLOWING] = following
		ai_controller.blackboard[BB_FALCON_WANT_PERCH] = FALSE
		ai_controller.clear_blackboard_key(BB_FALCON_PERCH_TARGET)
	to_chat(user, "<span class='notice'>The falcon is now [patrolling ? "patrolling" : "staying close"].</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/set_following(mob/user)
	following = TRUE
	patrolling = FALSE
	summoner = user
	if(ai_controller)
		ai_controller.blackboard[BB_FOLLOWING] = following
		ai_controller.blackboard[BB_PATROLLING] = patrolling
		ai_controller.blackboard[BB_SUMMONER] = summoner
		ai_controller.blackboard[BB_FALCON_WANT_PERCH] = FALSE
		ai_controller.clear_blackboard_key(BB_FALCON_PERCH_TARGET)
	to_chat(user, "<span class='notice'>The falcon begins following you closely.</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/set_perching(mob/user)
	following = FALSE
	patrolling = FALSE
	summoner = user

	if(ai_controller)
		ai_controller.blackboard[BB_FOLLOWING] = FALSE
		ai_controller.blackboard[BB_PATROLLING] = FALSE
		ai_controller.blackboard[BB_SUMMONER] = summoner
		ai_controller.blackboard[BB_FALCON_WANT_PERCH] = TRUE
		ai_controller.blackboard[BB_FALCON_PERCH_TARGET] = user
		ai_controller.queue_behavior(/datum/ai_behavior/falcon_wait_and_perch, BB_FALCON_PERCH_TARGET)

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/set_unperching()
	following = FALSE
	patrolling = FALSE
	if(buckled)
		buckled.unbuckle_mob(src)
	else
		toggle_perched(perched = FALSE)
	if(ai_controller)
		ai_controller.blackboard[BB_FOLLOWING] = FALSE
		ai_controller.blackboard[BB_PATROLLING] = FALSE
		ai_controller.blackboard[BB_FALCON_WANT_PERCH] = FALSE
		ai_controller.clear_blackboard_key(BB_FALCON_PERCH_TARGET)

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/add_focus_target(mob/target)
	if(!focus_targets)
		focus_targets = list()
	if(!(target in focus_targets))
		focus_targets = list(target) // CLEAR previous
		if(ai_controller)
			ai_controller.blackboard[BB_FOCUS_TARGETS] = list(target)

//================== HUMAN PERCH INTERFACE ==================

/mob/living/carbon/human/proc/perch_falcon_on_hand(var/falcon)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F = falcon
	if(!istype(F, /mob/living/simple_animal/hostile/retaliate/custodianpet/falcon) || !F.can_be_perched(src))
		to_chat(src, "<span class='warning'>You can't perch that falcon right now.</span>")
		return FALSE
	// Set up blackboard and let AI handle the approach and perch!
	if(F.ai_controller)
		F.ai_controller.blackboard[BB_FALCON_WANT_PERCH] = TRUE
		F.ai_controller.blackboard[BB_FALCON_PERCH_TARGET] = src
		F.ai_controller.queue_behavior(/datum/ai_behavior/falcon_wait_and_perch, BB_FALCON_PERCH_TARGET)
		to_chat(src, "<span class='info'>You beckon your falcon to perch on you.</span>")
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/drop_perched_falcon()
	if(buckled_mobs)
		for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F in buckled_mobs)
			F.resist_from_perch()
			F.on_unperched() // <-- Force reset every time
			return TRUE
	return FALSE

/mob/living/carbon/human/post_buckle_mob(mob/living/M)
	..()
	update_falcon_perched_overlay()

/mob/living/carbon/human/post_unbuckle_mob(mob/living/M)
	..()
	update_falcon_perched_overlay()

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/MouseDrop_T(mob/living/carbon/human/target, mob/living/user)
	if(target == user && !buckled)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.perch_falcon_on_hand(src)

/mob/living/carbon/human/MiddleClickOn(atom/A, params)
	// Falcon drop: middle-click yourself to release perched falcon
	if(A == src && buckled_mobs)
		for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F in buckled_mobs)
			F.resist_from_perch()
			return // Only drop one falcon at a time
	..() // Call parent for normal behavior

/obj/item/paper/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /mob/living/simple_animal/hostile/retaliate/custodianpet/falcon))
		return afterattack(I, user, TRUE, params)
	return ..()

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/attackby(obj/item/I, mob/living/carbon/human/user, params)
	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		return P.afterattack(src, user, TRUE, params)
	return ..()

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/MouseDrop_T(obj/item/paper/P, mob/living/carbon/human/user)
	if(istype(P, /obj/item/paper))
		return P.afterattack(src, user, TRUE, list())
	return ..()

/obj/item/paper/afterattack(var/obj, mob/user, reach, params)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F = obj
	if(!istype(F, /mob/living/simple_animal/hostile/retaliate/custodianpet/falcon) || F.delivering_paper || !info)
		return ..()
	if(!user || !user.real_name)
		return ..()
	// Prompt for recipient name
	var/recipient_name = input(user, "Who do you want to send this letter to? (Type their exact name)", "Send Letter")
	if(!recipient_name)
		return ..()
	// Find the player by real_name
	var/recipient = null
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.real_name == recipient_name)
			recipient = H
			break
	if(!recipient)
		to_chat(user, "<span class='warning'>No one by that name found!</span>")
		return ..()
	// Initiate delivery
	F.start_paper_delivery(src, user, recipient)
	return TRUE

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/start_paper_delivery(obj/item/paper/P, mob/living/carbon/human/sender, mob/living/carbon/human/recipient)
	if(delivering_paper)
		to_chat(sender, "<span class='warning'>I'm already delivering something!</span>")
		return

	// --- FORCE UNFREEZE/UNBUCKLE/UNPERCH ---
	REMOVE_TRAIT(src, TRAIT_FALCON_FROZEN, "perching")
	REMOVE_TRAIT(src, TRAIT_FALCON_PERCHED, "perched")
	if(buckled)
		buckled.unbuckle_mob(src)
	toggle_perched(FALSE)
	update_icon_state()
	// --------------------------------------

	delivering_paper = TRUE
	held_paper = P
	delivery_target = recipient
	old_following_state = following
	if(P.loc != src)
		P.forceMove(src)
	following = FALSE
	patrolling = FALSE
	if(ai_controller)
		ai_controller.blackboard[BB_FOLLOWING] = FALSE
		ai_controller.blackboard[BB_PATROLLING] = FALSE
		ai_controller.blackboard[BB_FALCON_WANT_PERCH] = FALSE
		ai_controller.blackboard[BB_FALCON_DELIVERING_PAPER] = TRUE
		ai_controller.clear_blackboard_key(BB_FALCON_PERCH_TARGET)
		ai_controller.clear_blackboard_key(BB_FALCON_CURRENT_TARGET)
		ai_controller.clear_blackboard_key(BB_FOCUS_TARGETS)

	//spawn(0)
	fly_and_deliver_paper(sender, recipient)

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/fly_and_deliver_paper(mob/living/carbon/human/sender, mob/living/carbon/human/recipient)
	// Begin delivery
	delivering_letter_anim = TRUE
	delivering_paper = TRUE
	if(ai_controller)
		ai_controller.blackboard[BB_FALCON_DELIVERING_PAPER] = TRUE

	// Takeoff animation: raise pixel_y, fade out
	visible_message("<span class='info'>The falcon spreads its wings and takes flight!</span>")
	var/original_pixel_y = pixel_y
	for(var/i = 1 to 8)
		pixel_y = original_pixel_y + i * 4   // Move up visually
		alpha = 255 - i * 30                // Fade out
		sleep(1)
	pixel_y = original_pixel_y + 32 // vanish off screen
	alpha = 0
	sleep(2)

	// "Teleport" to recipient
	if(QDELETED(recipient) || !delivering_paper) return finish_falcon_delivery()
	forceMove(get_turf(recipient))

	// Landing animation: start high/faded, land/fade in
	original_pixel_y = pixel_y
	for(var/i = 8 to 1 step -1)
		pixel_y = (i-1) * 4
		alpha = 255 - (i-1) * 30
		sleep(1)
	pixel_y = 0
	alpha = 255

	visible_message("<span class='info'>[src] arrives at [recipient.real_name] with a letter!</span>")
	to_chat(recipient, "<span class='info'>[src] is offering you a letter from [sender.real_name]. Use [src] to take it.</span>")

	// Wait for recipient to take or timeout
	var/wait_time = 0
	while(wait_time < 50 && held_paper && held_paper.loc == src && !QDELETED(src) && !QDELETED(recipient) && delivering_paper)
		if(get_dist(src, recipient) > 2) break
		sleep(2)
		wait_time++

	if(held_paper && held_paper.loc == src)
		visible_message("<span class='notice'>[src] grows impatient, drops the letter, and leaves.</span>")
		held_paper.forceMove(get_turf(src))
		held_paper = null

	if(!QDELETED(sender) && delivering_paper) //Return to the falconeer after delivering the paper.
		visible_message("<span class='info'>[src] prepares to return to [sender.real_name].</span>")
		original_pixel_y = pixel_y
		for(var/i = 1 to 8)
			pixel_y = original_pixel_y + i * 4
			alpha = 255 - i * 30
			sleep(1)
		pixel_y = original_pixel_y + 32
		alpha = 0
		sleep(2)

		forceMove(get_turf(sender))
		for(var/i = 8 to 1 step -1)
			pixel_y = (i-1) * 4
			alpha = 255 - (i-1) * 30
			sleep(1)
		pixel_y = 0
		alpha = 255
		sleep(8)
	finish_falcon_delivery()

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/finish_falcon_delivery()
	delivering_letter_anim = FALSE
	delivering_paper = FALSE
	delivery_target = null
	held_paper = null
	following = old_following_state
	if(ai_controller)
		ai_controller.blackboard[BB_FOLLOWING] = following
		ai_controller.blackboard[BB_SUMMONER] = summoner
		ai_controller.blackboard[BB_FALCON_DELIVERING_PAPER] = FALSE
	src.alpha = 255

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/simple_limb_hit(zone)
	if(!zone)
		return ""
	switch(zone)
		if(BODY_ZONE_PRECISE_R_EYE)
			return "head"
		if(BODY_ZONE_PRECISE_L_EYE)
			return "head"
		if(BODY_ZONE_PRECISE_NOSE)
			return "snout"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "snout"
		if(BODY_ZONE_PRECISE_SKULL)
			return "head"
		if(BODY_ZONE_PRECISE_EARS)
			return "head"
		if(BODY_ZONE_PRECISE_NECK)
			return "neck"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "foreleg"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "foreleg"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "leg"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "leg"
		if(BODY_ZONE_PRECISE_STOMACH)
			return "stomach"
		if(BODY_ZONE_HEAD)
			return "head"
		if(BODY_ZONE_R_LEG)
			return "leg"
		if(BODY_ZONE_L_LEG)
			return "leg"
		if(BODY_ZONE_R_ARM)
			return "foreleg"
		if(BODY_ZONE_L_ARM)
			return "foreleg"
	return ..()

/obj/item/clothing/face/cigarette/rollie/attack(mob/living/target, mob/living/carbon/human/user)
	if(istype(target, /mob/living/simple_animal/hostile/retaliate/custodianpet/falcon))
		var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F = target
		if(!F.has_smoke)
			user.visible_message("<span class='warning'>[user] tries to put a rollie on [F]'s beak...</span>")
			if(do_after(user, 2 SECONDS, F))
				user.dropItemToGround(src)
				F.has_smoke = TRUE
				src.forceMove(F)
				F.update_icon_state()
		else
			to_chat(user, "<span class='notice'>[F] is already smoking!</span>")
			return
	..()
/*
/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/get_sound(input)
	if("idle")
		return pick('modular/kaizoku/sound/animals/saintalon/saintalon_3.ogg','modular/kaizoku/sound/animals/saintalon/saintalon_4.ogg','modular/kaizoku/sound/animals/saintalon/saintalon_5.ogg','modular/kaizoku/sound/animals/saintalon/saintalon_6.ogg')
*/

//================== HUMAN EXTENSIONS ==================

/mob/living/carbon/human
	var/image/falcon_perched_overlay = null
	max_buckled_mobs = 1

/mob/living/carbon/human/MiddleClickOn(atom/A, params)
	..()
	if(A == src) // Player middle-clicks themselves
		drop_perched_falcon()

//================== WHISTLE OBJECT ==================

/datum/intent/whistle/attack
	name = "attack"
	icon_state = "inclaw"
	chargetime = 0
	noaa = TRUE
	rmb_ranged = TRUE

/datum/intent/whistle/attack/rmb_ranged(atom/target, mob/user)
	if(ismob(target))
		var/mob/L = target
		// Falcons
		for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F in view(7, user))
			if(!F.summoner) continue
			if(F.summoner != user)
				to_chat(user, "<span class='warning'>[F] ignores your command. It serves another master.</span>")
				continue
			if(F == L)
				to_chat(user, "<span class='warning'>The falcon gets confused. Why attack itself?</span>")
				continue
			F.add_focus_target(L)
		// Doggos
		for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/D in view(7, user))
			if(!D.summoner) continue
			if(D.summoner != user)
				to_chat(user, "<span class='warning'>[D] ignores your command. It serves another master.</span>")
				continue
			if(D == L)
				to_chat(user, "<span class='warning'>The doggo gets confused. Why attack itself?</span>")
				continue
			D.add_focus_target(L)
		to_chat(user, "<span class='info'>The sharp sounds command your animal(s) to attack [L].</span>")
		return

	// --- NEW: Send animals to bed ---
	if(istype(target, /obj/structure/bed))
		var/obj/structure/bed/B = target
		//for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F in view(7, user))
			//if(F.summoner == user)
				//F.set_resting_bed(B, user)
		for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/D in view(7, user))
			if(D.summoner == user)
				D.set_resting_bed(B, user)
		to_chat(user, "<span class='info'>You command your animal(s) to rest and heal on the bed.</span>")
		return

	// --- NEW: Send animals to turf ---
	if(istype(target, /turf/open/floor))
		var/turf/T = target
		for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F in view(7, user))
			if(F.summoner == user)
				F.move_to_turf(T, user)
		for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/D in view(7, user))
			if(D.summoner == user)
				D.move_to_turf(T, user)
		to_chat(user, "<span class='info'>You signal your animal(s) to move to a spot.</span>")
		return

/datum/intent/whistle/patrol
	name = "patrol/perch"
	icon_state = "inwring"
	chargetime = 0
	noaa = TRUE
	rmb_ranged = TRUE

/datum/intent/whistle/patrol/rmb_ranged(atom/target, mob/user)
	var/perch_done = FALSE
	// Falcons: handle perch/unperch
	for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F in view(7, user))
		if(!F.summoner)
			to_chat(user, "<span class='warning'>[F] does not have an owner.</span>")
			continue
		if(F.summoner != user)
			to_chat(user, "<span class='warning'>[F] does not recognize your whistle.</span>")
			continue

		// Falcon-specific perch logic
		if(HAS_TRAIT(F, TRAIT_FALCON_PERCHED) && F.buckled == user)
			F.set_unperching()
			to_chat(user, "<span class='info'>The sound warns your falcon to stop perching.</span>")
			perch_done = TRUE
			continue
		if(!HAS_TRAIT(F, TRAIT_FALCON_PERCHED) && !F.buckled)
			F.set_perching(user)
			to_chat(user, "<span class='info'>The sound beckons your falcon to perch on you.</span>")
			perch_done = TRUE
			continue
		// If target is a falcon, set patrol mode
		if(!perch_done && istype(target, /mob/living/simple_animal/hostile/retaliate/custodianpet/falcon))
			if(!F.summoner || F.summoner != user)
				F.summoner = user
			if(F.summoner == user)
				F.toggle_patrol(user)
				to_chat(user, "<span class='notice'>You signal for your falcon to seek enemies.</span>")

	// Doggos: patrol toggle only
	for(var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/D in view(7, user))
		if(!D.summoner)
			to_chat(user, "<span class='warning'>[D] does not have an owner.</span>")
			continue
		if(D.summoner != user)
			to_chat(user, "<span class='warning'>[D] does not recognize your whistle.</span>")
			continue
		D.toggle_patrol(user)
	to_chat(user, "<span class='notice'>You signal for your animal(s) to seek enemies.</span>")
	return

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/move_to_turf(var/turf/T, mob/user)
	// Optional: if you want them to just move there and stand, clear goals
	patrolling = FALSE
	following = FALSE
	if(ai_controller)
		ai_controller.blackboard[BB_PATROLLING] = FALSE
		ai_controller.blackboard[BB_FOLLOWING] = FALSE
		ai_controller.blackboard[BB_DOGGO_RESTING] = FALSE
		ai_controller.blackboard[BB_DOGGO_REST_BED] = null
	// Actually move there
	forceMove(T)
	to_chat(user, "<span class='notice'>[src] moves to the spot as commanded.</span>")

/obj/item/pet_command/whistle
	name = "dustwalker whistle"
	desc = "A metal whistle of dustwalker culture settled to allow communication between user and its spiritual companion."
	icon = 'modular/kaizoku/icons/mobs/falcon.dmi'
	icon_state = "whistle"
	possible_item_intents = list(/datum/intent/whistle/attack, /datum/intent/whistle/patrol)
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_RING|ITEM_SLOT_HIP|ITEM_SLOT_WRISTS

/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/proc/start_perching(atom/target)
	if(HAS_TRAIT(src, TRAIT_FALCON_PERCHED))
		return FALSE

	if(istype(target, /mob/living/carbon/human))
		if(get_dist(src, target) > 1)
			return FALSE
		return perch_on_human(target)

	// If perching on non-human perches
	var/list/perch_types = ai_controller?.blackboard[BB_FALCON_PERCH_TYPES]
	if(!perch_types || !is_type_in_list(target, perch_types))
		return FALSE
	if(get_dist(src, target) > 1)
		return FALSE

	// Perch on object: just move there, show sitting sprite
	src.forceMove(get_turf(target))
	toggle_perched(perched = TRUE)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(after_move))
	visible_message("<span class='notice'>[src] perches on [target].</span>")
	return TRUE

/obj/item/kaizoku/falcon_crate
	name = "falcon crate"
	desc = "A wooden crate with air holes. Scratching and chirping can be heard from inside."
	icon = 'modular/kaizoku/icons/mapset/tradesector32.dmi'
	icon_state = "animal_cage"
	var/mob_path = /mob/living/simple_animal/hostile/retaliate/custodianpet/falcon

/obj/item/kaizoku/falcon_crate/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/weapon/knife))
		to_chat(user, "<span class='info'>You carefully cut the bindings on the crate, and a falcon bursts out!</span>")
		playsound(src, 'sound/misc/slide_wood (1).ogg', 50, TRUE)
		var/mob/living/simple_animal/hostile/retaliate/custodianpet/falcon/F = new mob_path(get_turf(user))
		F.summoner = user
		if(F.ai_controller)
			F.ai_controller.blackboard[BB_SUMMONER] = user
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You need a knife to open this crate.</span>")

/obj/item/kaizoku/falcon_crate/doggo
	name = "doggo crate"
	desc = "A wooden crate with air holes. Scratching and chirping can be heard from inside."
	icon = 'modular/kaizoku/icons/mapset/tradesector32.dmi'
	icon_state = "animal_cage"
	mob_path = /mob/living/simple_animal/hostile/retaliate/custodianpet/doggo
