//This animal alongside the Falcon has been organized this way because I seriously can't organize the code otherwise.
//Feel free to change it. In fact, I encourage you to do it. I just can't waste time on it right now.

// ==================== MACROS ====================
#define BB_FOCUS_TARGETS "focus_targets"
#define BB_PATROLLING "patrolling"
#define BB_CURRENT_TARGET "current_target"
#define BB_SUMMONER "summoner"
#define BB_FOLLOWING "following"
#define BB_DOGGO_RESTING "doggo_resting"
#define BB_DOGGO_REST_BED "doggo_rest_bed"

// ==================== AI CONTROLLER ====================

/datum/ai_controller/doggo
	movement_delay = 0.4 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	blackboard = list(
		BB_FOCUS_TARGETS = list(),
		BB_PATROLLING = FALSE,
		BB_FOLLOWING = FALSE,
		BB_SUMMONER = null,
		BB_DOGGO_RESTING = FALSE,
		BB_DOGGO_REST_BED = null,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/doggo_behavior,
	)
	idle_behavior = /datum/idle_behavior/idle_random_walk

// ==================== AI PLANNING SUBTREE ====================

/datum/ai_planning_subtree/doggo_behavior

/datum/ai_planning_subtree/doggo_behavior/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/doggo_pawn = controller.pawn
	if(!istype(doggo_pawn)) return

	if(doggo_pawn.doggo_bellyup) return SUBTREE_RETURN_FINISH_PLANNING
	if(doggo_pawn.doggo_held) return SUBTREE_RETURN_FINISH_PLANNING
	if(doggo_pawn.stat == DEAD) return SUBTREE_RETURN_FINISH_PLANNING
	if(doggo_pawn.doggo_napping) return SUBTREE_RETURN_FINISH_PLANNING // blocks all actions while napping

	// === NAP ON BED LOGIC ===
	var/bed = controller.blackboard[BB_DOGGO_REST_BED]
	if(bed)
		var/turf/bed_turf = get_turf(bed)
		if(get_turf(doggo_pawn) != bed_turf)
			// Walk to bed
			controller.set_blackboard_key("DOGGO_BED_GOAL", bed)
			controller.queue_behavior(/datum/ai_behavior/doggo_follow, "DOGGO_BED_GOAL")
			return SUBTREE_RETURN_FINISH_PLANNING
		else
			// Now at the bed!
			if(!doggo_pawn.doggo_resting)
				doggo_pawn.doggo_resting = TRUE
				if(controller)
					controller.blackboard[BB_DOGGO_RESTING] = TRUE
				doggo_pawn.start_nap()
			return SUBTREE_RETURN_FINISH_PLANNING
	// Focus targets
	var/list/focus_targets = controller.blackboard[BB_FOCUS_TARGETS]
	if(length(focus_targets))
		var/mob/target = null
		var/closest_dist = INFINITY
		for(var/mob/M in focus_targets)
			if(QDELETED(M))
				controller.blackboard[BB_FOCUS_TARGETS] -= M
				continue
			var/dist = get_dist(doggo_pawn, M)
			if(dist < closest_dist)
				closest_dist = dist
				target = M
		if(target)
			controller.set_blackboard_key(BB_CURRENT_TARGET, target)
			controller.blackboard["doggo_focus"] = new /datum/targetting_datum/doggo_focus // Add this line!
			controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/doggo, BB_CURRENT_TARGET, "doggo_focus", null)
			return SUBTREE_RETURN_FINISH_PLANNING

	// Following
	var/following = controller.blackboard[BB_FOLLOWING]
	var/mob/summoner = controller.blackboard[BB_SUMMONER]
	if(following && summoner && !QDELETED(summoner))
		var/dist = get_dist(doggo_pawn, summoner)
		if(dist > 2)
			controller.queue_behavior(/datum/ai_behavior/doggo_follow, BB_SUMMONER)
			return SUBTREE_RETURN_FINISH_PLANNING

	// Patrolling
	var/patrolling = controller.blackboard[BB_PATROLLING]
	if(patrolling)
		var/patrol_target = null
		var/closest_patrol_dist = INFINITY
		var/datum/targetting_datum/doggo_patrol/td = new
		for(var/mob/M in hearers(7, doggo_pawn))
			if(td.can_attack(doggo_pawn, M))
				var/dist = get_dist(doggo_pawn, M)
				if(dist < closest_patrol_dist)
					closest_patrol_dist = dist
					patrol_target = M
		if(patrol_target)
			controller.set_blackboard_key(BB_CURRENT_TARGET, patrol_target)
			controller.blackboard["doggo_patrol"] = new /datum/targetting_datum/doggo_patrol // Add this line!
			controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/doggo, BB_CURRENT_TARGET, "doggo_patrol", null)
			return SUBTREE_RETURN_FINISH_PLANNING
		else
			controller.queue_behavior(/datum/ai_behavior/doggo_patrol)
			return SUBTREE_RETURN_FINISH_PLANNING

	// Lazy follow
	if(summoner && !QDELETED(summoner))
		var/dist = get_dist(doggo_pawn, summoner)
		if(dist > 3)
			controller.queue_behavior(/datum/ai_behavior/doggo_follow, BB_SUMMONER)
			return SUBTREE_RETURN_FINISH_PLANNING

	return

// ==================== DOGGO MOB ====================

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo
	name = "doggo"
	icon = 'modular/kaizoku/icons/mobs/doggo.dmi'
	desc = "Mixed breed between Foglander zingerhound and heartfeltean landstrider. Loyal, powerful and affectionate, replacing stingers for size."
	icon_state = "doggo"
	icon_living = "doggo"
	icon_dead = "doggo_dead"
	var/icon_rest = "doggo_rest"
	var/icon_bellyup = "doggo_bellyup"
	health = 300
	maxHealth = 300
	melee_damage_lower = 20
	melee_damage_upper = 28
	limb_destroyer = 0
	density = TRUE
	ai_controller = /datum/ai_controller/doggo
	var/doggo_resting = FALSE
	var/doggo_bellyup = FALSE
	var/last_rest_tick = 0
	var/doggo_held = FALSE
	var/nappytime = 10 SECONDS
	var/doggo_napping = FALSE
	next_click = 0
	melee_attack_cooldown = 15
	attack_sound = list('sound/vo/mobs/vw/attack (1).ogg','sound/vo/mobs/vw/attack (2).ogg','sound/vo/mobs/vw/attack (3).ogg','sound/vo/mobs/vw/attack (4).ogg')


/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/get_sound(input)
	switch(input)
		if("aggro")
			return pick('sound/vo/mobs/vw/aggro (1).ogg','sound/vo/mobs/vw/aggro (2).ogg')
		if("pain")
			return pick('sound/vo/mobs/vw/pain (1).ogg','sound/vo/mobs/vw/pain (2).ogg','sound/vo/mobs/vw/pain (3).ogg')
		if("death")
			return pick('sound/vo/mobs/vw/death (1).ogg','sound/vo/mobs/vw/death (2).ogg','sound/vo/mobs/vw/death (3).ogg','sound/vo/mobs/vw/death (4).ogg','sound/vo/mobs/vw/death (5).ogg')
		if("idle")
			return pick('sound/vo/mobs/vw/idle (1).ogg','sound/vo/mobs/vw/idle (2).ogg','sound/vo/mobs/vw/idle (3).ogg','sound/vo/mobs/vw/idle (4).ogg')
		if("cidle")
			return pick('sound/vo/mobs/vw/bark (1).ogg','sound/vo/mobs/vw/bark (2).ogg','sound/vo/mobs/vw/bark (3).ogg','sound/vo/mobs/vw/bark (4).ogg','sound/vo/mobs/vw/bark (5).ogg','sound/vo/mobs/vw/bark (6).ogg','sound/vo/mobs/vw/bark (7).ogg')

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/var/napping = FALSE

// ======= Targeting for doggo =======
/datum/targetting_datum/doggo_focus
// No vars needed, just procs
/datum/targetting_datum/doggo_focus/can_attack(mob/living/living_mob, atom/the_target)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/D = living_mob
	if(D.focus_targets && (the_target in D.focus_targets))
		return TRUE
	return FALSE

/datum/targetting_datum/doggo_patrol
// No vars needed, just procs
/datum/targetting_datum/doggo_patrol/can_attack(mob/living/living_mob, atom/the_target)
	if(!the_target || !ismob(the_target)) return FALSE
	if(the_target == living_mob) return FALSE
	if(istype(living_mob, /mob/living/simple_animal/hostile/retaliate/custodianpet/doggo))
		var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/D = living_mob
		if(the_target == D.summoner) return FALSE
	var/mob/H = the_target
	if(islist(H.faction) && ("orcs" in H.faction)) return TRUE
	if(isnum(H:mob_biotypes) && (H:mob_biotypes & MOB_UNDEAD)) return TRUE
	return FALSE

// ========== DOGGO AI BEHAVIORS =============

/datum/ai_behavior/basic_melee_attack/doggo
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/doggo/perform(delta_time, datum/ai_controller/controller, target_key, _, _)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/doggo_pawn = controller.pawn
	if(doggo_pawn.next_click && world.time < doggo_pawn.next_click)
		return

	var/atom/target = controller.blackboard[target_key]
	if(!istype(doggo_pawn) || QDELETED(target))
		finish_action(controller, FALSE)
		return

	var/dist = get_dist(doggo_pawn, target)
	if(dist > 1)
		controller.set_movement_target(target)
		return

	if(dist <= 1 && isliving(target))
		var/mob/living/L = target
		var/list/zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
		var/zone = pick(zones)
		var/damage = rand(doggo_pawn.melee_damage_lower, doggo_pawn.melee_damage_upper)

		doggo_pawn.visible_message("<span class='danger'>[doggo_pawn] leaps at [L], biting [L.p_their()] [parse_zone(zone)]!</span>", COMBAT_MESSAGE_RANGE)
		playsound(get_turf(doggo_pawn), pick(doggo_pawn.attack_sound), 50, TRUE)
		L.apply_damage(damage, BRUTE, zone)
		switch(zone)
			if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
				if(prob(30))
					var/obj/item/W = L.get_active_held_item()
					if(W)
						L.dropItemToGround(W)
						L.visible_message("<span class='warning'>[L]'s weapon is torn from their grip by a bite!</span>")
			if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				if(prob(35))
					L.Immobilize(15)
					L.visible_message("<span class='warning'>[L]'s legs lose movement from the dog's bite!</span>")
			if(BODY_ZONE_CHEST)
				if(prob(25))
					L.Knockdown(20)
					L.visible_message("<span class='warning'>[L]'s chest is overwhelmed by the bite!</span>")
		doggo_pawn.next_click = world.time + (doggo_pawn.melee_attack_cooldown || 15)
		finish_action(controller, TRUE, target_key)
		return

/datum/ai_behavior/doggo_follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/doggo_follow/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/doggo_follow/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/doggo_pawn = controller.pawn
	if(doggo_pawn?.doggo_napping)
		finish_action(controller, FALSE)
		return

	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	var/dist = get_dist(doggo_pawn, target)
	if(dist <= 2)
		finish_action(controller, TRUE, target_key)
		return

	set_movement_target(controller, target)

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/proc/move_to_turf(var/turf/T, mob/user)
	patrolling = FALSE
	following = FALSE
	doggo_resting = FALSE
	if(ai_controller)
		ai_controller.blackboard[BB_PATROLLING] = FALSE
		ai_controller.blackboard[BB_FOLLOWING] = FALSE
		ai_controller.blackboard[BB_DOGGO_RESTING] = FALSE
		ai_controller.blackboard[BB_DOGGO_REST_BED] = null
		ai_controller.blackboard["move_target"] = T
		ai_controller.queue_behavior(/datum/ai_behavior/doggo_follow, "move_target")
	to_chat(user, "<span class='notice'>[src] trots off towards the chosen location.</span>")

/datum/ai_behavior/doggo_patrol

/datum/ai_behavior/doggo_patrol/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/doggo_pawn = controller.pawn

	if(doggo_pawn?.doggo_napping)
		finish_action(controller, FALSE)
		return

	var/mob/summoner = controller.blackboard[BB_SUMMONER]
	if(!summoner || QDELETED(summoner))
		finish_action(controller, FALSE)
		return

	var/patrol_radius = 5
	var/target_x = summoner.x + rand(-patrol_radius, patrol_radius)
	var/target_y = summoner.y + rand(-patrol_radius, patrol_radius)
	var/turf/target_turf = locate(target_x, target_y, summoner.z)
	if(target_turf)
		controller.set_movement_target(target_turf)
		spawn(30)
			if(controller && !QDELETED(doggo_pawn))
				finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

// ==================== DOGGO PROCS & LIFE ====================

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/Initialize(mapload)
	. = ..()
	if(ai_controller)
		ai_controller.blackboard[BB_SUMMONER] = src.summoner
		ai_controller.blackboard[BB_FOCUS_TARGETS] = src.focus_targets
		ai_controller.blackboard[BB_PATROLLING] = src.patrolling
		ai_controller.blackboard[BB_FOLLOWING] = src.following
		ai_controller.blackboard[BB_DOGGO_RESTING] = src.doggo_resting
		ai_controller.blackboard[BB_DOGGO_REST_BED] = null

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/update_icon_state()
	. = ..()
	if(stat == DEAD)
		icon_state = icon_dead
		return
	if(doggo_bellyup)
		icon_state = icon_bellyup
		return
	if(doggo_resting)
		icon_state = icon_rest
		return
	icon_state = icon_living

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/proc/add_focus_target(target)
	if(!focus_targets) focus_targets = list()
	if(!(target in focus_targets))
		focus_targets = list(target)
		if(ai_controller)
			ai_controller.blackboard[BB_FOCUS_TARGETS] = list(target)
			ai_controller.clear_blackboard_key(BB_CURRENT_TARGET)
		patrolling = FALSE
		following = FALSE
		if(ai_controller)
			ai_controller.blackboard[BB_PATROLLING] = FALSE
			ai_controller.blackboard[BB_FOLLOWING] = FALSE

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/proc/toggle_patrol(user)
	if(summoner && summoner != user)
		to_chat(user, "<span class='warning'>[src] ignores your command. It serves another master.</span>")
		return
	patrolling = !patrolling
	following = FALSE
	doggo_resting = FALSE
	if(ai_controller)
		ai_controller.blackboard[BB_PATROLLING] = patrolling
		ai_controller.blackboard[BB_FOLLOWING] = FALSE
		ai_controller.blackboard[BB_DOGGO_RESTING] = FALSE
		ai_controller.clear_blackboard_key(BB_CURRENT_TARGET)
		ai_controller.blackboard[BB_FOCUS_TARGETS] = list()
		ai_controller.blackboard[BB_DOGGO_REST_BED] = null
	to_chat(user, "<span class='notice'>The doggo is now [patrolling ? "patrolling" : "staying close"].</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/proc/set_following(user)
	if(summoner && summoner != user)
		to_chat(user, "<span class='warning'>[src] ignores your command. It serves another master.</span>")
		return
	following = TRUE
	patrolling = FALSE
	doggo_resting = FALSE
	summoner = user
	if(ai_controller)
		ai_controller.blackboard[BB_FOLLOWING] = TRUE
		ai_controller.blackboard[BB_PATROLLING] = FALSE
		ai_controller.blackboard[BB_SUMMONER] = user
		ai_controller.clear_blackboard_key(BB_CURRENT_TARGET)
		ai_controller.blackboard[BB_FOCUS_TARGETS] = list()
		ai_controller.blackboard[BB_DOGGO_RESTING] = FALSE
		ai_controller.blackboard[BB_DOGGO_REST_BED] = null
	to_chat(user, "<span class='notice'>The doggo begins following you closely.</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/proc/set_resting_bed(obj/structure/bed/bed, mob/user)
	if(summoner && summoner != user)
		to_chat(user, "<span class='warning'>[src] ignores your command. It serves another master.</span>")
		return
	if(ai_controller)
		ai_controller.blackboard[BB_DOGGO_REST_BED] = bed
	update_icon_state()
	to_chat(user, "<span class='notice'>[src] has been allowed to rest on the bed nearby.</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/proc/start_nap()
	doggo_napping = TRUE
	update_icon_state()
	to_chat(src, "<span class='notice'>[src] curls up without regards for the bed's hygiene.</span>")
	spawn(nappytime)
		if(doggo_napping && stat != DEAD)
			src.finish_nap()

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/proc/finish_nap()
	fully_heal()  // Finished napping? You will fully heal.
	doggo_napping = FALSE
	doggo_resting = FALSE
	if(ai_controller)
		ai_controller.blackboard[BB_DOGGO_RESTING] = FALSE
		ai_controller.blackboard[BB_DOGGO_REST_BED] = null
	update_icon_state()
	to_chat(src, "<span class='notice'>[src] yawns and stretches its rested body.</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/attack_hand(mob/living/carbon/human/user)
	if(user && user.used_intent && user.used_intent.type == INTENT_HELP && !doggo_bellyup && stat != DEAD)
		doggo_bellyup = TRUE
		update_icon_state()
		visible_message("<span class='notice'>[src] rolls onto its back as [user] gives [src] a belly rub.</span>")
		spawn(30)
			if(QDELETED(src) || stat == DEAD)
				return
			doggo_bellyup = FALSE
			update_icon_state()
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/proc/pickup_by(mob/living/carbon/human/user)
	if(doggo_held || stat == DEAD || doggo_resting) //If the doggo is already held, dead, or resting, we can't pick it up.
		to_chat(user, "<span class='warning'>You cannot pick up the doggo in this state.</span>")
		return
	var/obj/item/doggo_item/I = new /obj/item/doggo_item(user.loc)
	I.contained = src
	doggo_held = TRUE
	src.invisibility = 100 //Makes the true doggo invisible.

	src.forceMove(I) // This will MOVE the doggo into "item", so it can be picked up.
	var/success = user.put_in_hands(I)
	if(!success)
		I.attack_hand(user)

	to_chat(user, "<span class='info'>You pick up [src] gently.</span>")

/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/MouseDrop(atom/over_object)
	// Only allow player to scoop up their own doggo!
	var/mob/living/carbon/human/H = over_object
	if(!istype(H) || !Adjacent(H)) return ..()
	if(H != summoner) return ..() // Only the owner

	pickup_by(H)
	return

// =============== DOGGO ITEM FOR PICKUP/DROP ===============

/obj/item/doggo_item
	name = "doggo"
	icon = 'modular/kaizoku/icons/mobs/doggo.dmi'
	icon_state = "doggo_held"
	desc = "The doggo looks afraid. Perhaps acrophobic?" //Reference for Gundam, specifically for him.
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_HANDS | ITEM_SLOT_BACK
	var/mob/living/simple_animal/hostile/retaliate/custodianpet/doggo/contained = null
	pixel_x = -12
	force_wielded = TRUE

/obj/item/doggo_item/dropped(mob/living/carbon/human/user)
	..()

	if(contained)
		if(user.get_active_held_item() == src || user.get_inactive_held_item() == src)
			return
		contained.doggo_held = FALSE
		contained.invisibility = 0
		contained.forceMove(get_turf(user))
		contained = null
		qdel(src)

/obj/item/doggo_item/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 1,"sx" = 0,"sy" = 0,"nx" = 0,"ny" = 0,"wx" = 0,"wy" = 0,"ex" = 0,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
			if("onback")
				return list("shrink" = 1,"sx" = 0,"sy" = 0,"nx" = 0,"ny" = 0,"wx" = 0,"wy" = 0,"ex" = 0,"ey" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)
			if("wielded")
				return list("shrink" = 1,"sx" = -8,"sy" = 0,"nx" = 0,"ny" = 0,"wx" = 0,"wy" = 0,"ex" = 0,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.6,"sx" = -4,"sy" = -6,"nx" = 5,"ny" = -6,"wx" = 0,"wy" = -6,"ex" = -1,"ey" = -6,"nturn" = 100,"sturn" = 156,"wturn" = 90,"eturn" = 180,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
