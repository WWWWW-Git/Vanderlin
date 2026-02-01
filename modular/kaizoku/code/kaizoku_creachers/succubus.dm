/mob/living
	var/tmp/succubus_reverse_controls = FALSE

/datum/targetting_datum/demon_succubus_target
/datum/targetting_datum/demon_succubus_target/can_attack(mob/living/self, atom/T)
	if(!T || !ismob(T))
		return FALSE
	if(T == self)
		return FALSE
	var/mob/living/M = T
	if(islist(M.faction))
		if(("demons" in M.faction) || ("cabal" in M.faction) || ("graggar" in M.faction))
			return FALSE
	return TRUE

/datum/ai_controller/demon_succubus
	movement_delay = 0.5 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/demon_succubus_target()
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/demon_succubus_adjacent_charm,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/succubus
	)
	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_planning_subtree/basic_melee_attack_subtree/succubus
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/succubus

/datum/ai_planning_subtree/demon_succubus_adjacent_charm
/datum/ai_planning_subtree/demon_succubus_adjacent_charm/SelectBehaviors(datum/ai_controller/C, delta_time)
	. = ..()
	var/mob/living/simple_animal/hostile/retaliate/demon/succubus/S = C.pawn
	if(!istype(S) || S.stat == DEAD)
		return
	if(S.vanishing)
		return // don’t plan anything while vanishing.

	var/mob/living/target = C.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return

	if(get_dist(S, target) <= 1 && S.CanAttemptCharm())
		C.queue_behavior(/datum/ai_behavior/demon_succubus_try_charm, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, null)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/demon_succubus_try_charm
	action_cooldown = 0.3 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/demon_succubus_try_charm/perform(delta_time, datum/ai_controller/C, target_key, _, __)
	var/mob/living/simple_animal/hostile/retaliate/demon/succubus/S = C.pawn
	if(!istype(S) || S.vanishing)
		finish_action(C, FALSE)
		return
	var/atom/T = C.blackboard[target_key]
	if(QDELETED(T))
		finish_action(C, FALSE)
		return
	if(S.TryCharm(T))
		S.next_click = world.time + (S.special_post_delay || 10)
		finish_action(C, TRUE, target_key)
	else
		finish_action(C, FALSE, target_key)

/datum/ai_behavior/basic_melee_attack/succubus
	action_cooldown = 0.2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/succubus/perform(delta_time, datum/ai_controller/C, target_key, targetting_datum_key, hiding_location_key)
	var/mob/living/simple_animal/hostile/retaliate/demon/succubus/S = C.pawn
	if(!istype(S) || S.vanishing)
		finish_action(C, FALSE, target_key)
		return

	var/atom/target = C.blackboard[target_key]
	var/datum/targetting_datum/TD = C.blackboard[targetting_datum_key]
	if(QDELETED(target) || !TD || !TD.can_attack(S, target))
		finish_action(C, FALSE, target_key)
		return
	if(ismob(target) && target:stat == DEAD)
		finish_action(C, FALSE, target_key)
		return
	if(get_dist(S, target) > 1)
		C.set_movement_target(target)
		return
	S.EnsureCombatIntent()
	S.face_atom(target)

	if(S.CanAttemptCharm())
		S.TryCharm(target)
	var/hiding_target = (TD ? TD.find_hidden_mobs(S, target) : null)
	if(hiding_target)
		C.ai_interact(hiding_target, TRUE, TRUE)
	else
		C.ai_interact(target, TRUE, TRUE)

	if(S.next_click < world.time)
		S.next_click = world.time + (S.melee_attack_cooldown || 15)
	SEND_SIGNAL(S, COMSIG_MOB_BREAK_SNEAK)
	finish_action(C, TRUE, target_key)


/mob/living/simple_animal/hostile/retaliate/demon/succubus
	name = "Succubus"
	desc = "A beguiling predator."

	icon = 'modular/kaizoku/icons/mobs/lust.dmi'
	icon_state = "lust"
	icon_dead = "lust_dead"

	faction = list("demons","cabal","graggar")
	ai_controller = /datum/ai_controller/demon_succubus

	density = TRUE
	speed = 1

	health = 240
	maxHealth = 240

	base_intents = list(
		/datum/intent/unarmed/claw,
		/datum/intent/simple/bigbite
	)

	melee_damage_lower = 8
	melee_damage_upper = 12
	melee_attack_cooldown = 18
	next_click = 0

	var/special_chance = 30
	var/special_cd = 80
	var/special_post_delay = 15
	var/charm_last_special = 0
	var/charm_duration = 300
	var/power_charm = 18

	var/illusion_chance = 35
	var/illusion_cd = 120
	var/illusion_last = 0
	var/illusion_count = 3
	var/illusion_hp = 75
	var/list/active_illusions = list()

	var/vanish_chance = 20
	var/vanish_cd = 250
	var/vanish_last = 0
	var/vanish_duration = 50
	var/vanish_heal_per_tick = 1
	var/vanish_hp_threshold = 0.6
	var/vanishing = FALSE

	var/list/whispers = list(
		'modular/stonekeep/sound/sexcon/vo/female/moan (2).ogg',
		'modular/stonekeep/sound/sexcon/vo/female/sex (6).ogg'
	)

	var/range = 6
	var/last_forced_melee = 0

/mob/living/simple_animal/hostile/retaliate/demon/succubus/Initialize()
	. = ..()
	if(hascall(src, "AddComponent"))
		AddComponent(/datum/component/ai_aggro_system, 10, range)
	EnsureCombatIntent()

/mob/living/simple_animal/hostile/retaliate/demon/succubus/Destroy()
	CleanupIllusions()
	return ..()

/mob/living/simple_animal/hostile/retaliate/demon/succubus/death(gibbed)
	CleanupIllusions()
	vanishing = FALSE
	alpha = 255
	invisibility = 0
	return ..()

/mob/living/simple_animal/hostile/retaliate/demon/succubus/Life()
	. = ..()
	if(stat == DEAD)
		return
	if(vanishing)
		return

	var/mob/living/target = null
	if(istype(ai_controller))
		target = ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]

	if(!target)
		var/datum/targetting_datum/td = ai_controller?.blackboard[BB_TARGETTING_DATUM]
		var/closest = INFINITY
		for(var/mob/living/M in hearers(7, src))
			if(td && td.can_attack(src, M))
				var/d = get_dist(src, M)
				if(d < closest)
					closest = d; target = M

	if(target && get_dist(src, target) <= 2)
		if(Now() >= illusion_last + illusion_cd && prob(illusion_chance))
			SpawnIllusions(target)
			illusion_last = Now()

	if(CanVanish() && target)
		if(prob(vanish_chance) && (health <= round(maxHealth * vanish_hp_threshold)))
			TryVanishRegen(target)

	if(target && get_dist(src, target) <= 1)
		if(world.time >= next_click && world.time > last_forced_melee)
			EnsureCombatIntent()
			face_atom(target)
			if(ai_controller)
				ai_controller.ai_interact(target, TRUE, TRUE)
			next_click = world.time + (melee_attack_cooldown || 15)
			SEND_SIGNAL(src, COMSIG_MOB_BREAK_SNEAK)
			last_forced_melee = world.time



/********************** Helpers (scoped) **********************/
/proc/_succ_now() return world.time

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/Now()
	return _succ_now()

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/EnsureCombatIntent()
	if(!islist(possible_a_intents) || !length(possible_a_intents))
		possible_a_intents = list(
			/datum/intent/unarmed/claw,
			/datum/intent/simple/bigbite
		)
	var/list/lethals = list()
	for(var/datum/intent/I as anything in possible_a_intents)
		if(istype(I, /datum/intent/unarmed/help) || istype(I, /datum/intent/unarmed/shove) || istype(I, /datum/intent/unarmed/grab))
			continue
		lethals += I
	if(length(lethals))
		a_intent = pick(lethals)
		used_intent = a_intent

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/CanAttemptCharm()
	return prob(src.special_chance) && (src.Now() >= src.charm_last_special + src.special_cd)

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/GetStatSafe(mob/living/L, name, def=6)
	if(!L)
		return def
	if(name in L.vars)
		var/v = L.vars[name]
		if(isnum(v))
			return v
	return def

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/OpposedRollCharm(mob/living/L)
	var/primary = src.GetStatSafe(L, "STADEX", 6)
	var/second  = src.GetStatSafe(L, "STACON", 6)
	var/atk = src.power_charm + rand(1,6)
	var/def = primary + round(second/2) + rand(1,6)
	return (atk > def)

//Charm attempt
/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/TryCharm(atom/T)
	if(!isliving(T))
		return FALSE
	var/mob/living/L = T

	visible_message(span_warning("[src]'s eyes glimmer with malice."))
	if(length(src.whispers))
		playsound(get_turf(src), pick(src.whispers), 70, TRUE)

	if(!src.OpposedRollCharm(L))
		L.visible_message(
			span_notice("[L] blinks.")
		)
		return FALSE

	L.apply_status_effect(/datum/status_effect/succubus_charmed, src.charm_duration)

	L.visible_message(
		span_danger("[L] sways, their will bewitched.")
	)

	src.charm_last_special = src.Now()
	return TRUE

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/CleanupIllusions()
	if(!active_illusions)
		return
	for(var/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion/I in active_illusions)
		if(I && !QDELETED(I)) qdel(I)
	active_illusions.Cut()

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/SafeSpot(turf/center, dir)
	if(!center)
		return null
	var/turf/T = get_step(center, dir)
	if(T && !T.density)
		return T
	for(var/turf/R in range(1, center))
		if(R && !R.density)
			return R
	return null

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/SpawnIllusions(mob/living/target)
	var/turf/center = get_turf(src)
	if(!center)
		return
	CleanupIllusions()
	var/base_dir = get_dir(src, target)
	if(!base_dir) base_dir = SOUTH
	var/list/spawn_dirs = list(
		turn(base_dir, 180),
		turn(base_dir, 90),
		turn(base_dir, -90)
	)

	active_illusions = list()
	var/spawned = 0

	for(var/dir_choice in spawn_dirs)
		if(spawned >= illusion_count) break
		var/turf/spot = SafeSpot(center, dir_choice)
		if(!spot) continue
		var/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion/I = new(spot)
		if(I)
			I.SetupFromParent(src, target, illusion_hp)
			active_illusions += I
			spawned++

//Status effect that reverses your movement.
/datum/status_effect/succubus_charmed
	id = "succubus_charmed"
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/succubus_charmed
	var/force_cd_scale = 0.5
	var/enable_autoswing = TRUE
	var/running = FALSE

/datum/status_effect/succubus_charmed/on_apply()
	. = ..()
	if(!.)
		return
	var/mob/living/L = owner
	if(!L)
		return
	L.succubus_reverse_controls = TRUE
	running = TRUE
	spawn(0) AutoswingLoop()

/datum/status_effect/succubus_charmed/on_remove()
	var/mob/living/L = owner
	running = FALSE
	if(L) L.succubus_reverse_controls = FALSE
	return ..()

/datum/status_effect/succubus_charmed/proc/AutoswingLoop()
	while(running && owner && !QDELETED(owner))
		var/mob/living/L = owner
		if(!L || L.stat == DEAD) break
		if(enable_autoswing)
			AutoSwing(L)
		sleep(10)

/datum/status_effect/succubus_charmed/proc/AutoSwing(mob/living/L)
	var/obj/item/W = L.get_active_held_item()
	if(!W)
		return
	if(L.next_click > world.time)
		return
	var/mob/living/target = FindAdjacentEnemy(L)
	if(!target)
		return
	W.melee_attack_chain(L, target, null)
	var/cd = 10
	if("melee_attack_cooldown" in L.vars)
		var/v = L.vars["melee_attack_cooldown"]
		if(isnum(v)) cd = v
	L.next_click = world.time + max(1, round(cd * force_cd_scale))

/datum/status_effect/succubus_charmed/proc/FindAdjacentEnemy(mob/living/L)
	for(var/mob/living/M in range(1, L))
		if(M == L || M.stat == DEAD) continue
		if(islist(M.faction) && (("demons" in M.faction) || ("cabal" in M.faction) || ("graggar" in M.faction)))
			continue
		return M
	return null

/atom/movable/screen/alert/status_effect/succubus_charmed
	name = "Charmed"
	desc = "Your will is enthralled..."
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'
	icon_state = "shaken"

/datum/ai_controller/demon_succubus_illusion
	movement_delay = 0.6 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/demon_succubus_target()
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/illusion
	)
	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_planning_subtree/basic_melee_attack_subtree/illusion
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/illusion

/datum/ai_behavior/basic_melee_attack/illusion
	action_cooldown = 0.25 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/illusion/perform(dt, datum/ai_controller/C, target_key, td_key, _)
	var/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion/I = C.pawn
	if(!istype(I))
		finish_action(C, FALSE, target_key)
		return

	var/atom/target = C.blackboard[target_key]
	var/datum/targetting_datum/TD = C.blackboard[td_key]
	if(QDELETED(target) || !TD || !TD.can_attack(I, target))
		finish_action(C, FALSE, target_key)
		return
	if(ismob(target) && target:stat == DEAD)
		finish_action(C, FALSE, target_key)
		return

	if(get_dist(I, target) > 1)
		C.set_movement_target(target)
		return
	I.EnsureCombatIntent_Illusion()
	I.face_atom(target)
	C.ai_interact(target, TRUE, TRUE)
	if(ismob(target))
		var/mob/living/L = target
		I.visible_message(span_danger("[I] rakes [L] with taloned fingers!"))

	if(I.next_click < world.time)
		I.next_click = world.time + (I.melee_attack_cooldown || 12)

	finish_action(C, TRUE, target_key)

/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion
	name = "Succubus"
	desc = "A beguiling predator whose gaze unthreads resolve and turns limbs traitor."
	icon = 'modular/kaizoku/icons/mobs/lust.dmi'
	icon_state = "lust"
	icon_dead = "lust_dead"

	faction = list("demons","cabal","graggar")
	ai_controller = /datum/ai_controller/demon_succubus_illusion

	density = TRUE
	speed = 1

	health = 75
	maxHealth = 75
	melee_damage_lower = 0
	melee_damage_upper = 0
	melee_attack_cooldown = 12
	next_click = 0

	base_intents = list(
		/datum/intent/unarmed/claw,
		/datum/intent/simple/bigbite
	)

/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion/Initialize()
	. = ..()
	EnsureCombatIntent_Illusion()

/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion/proc/SetupFromParent(mob/living/simple_animal/hostile/retaliate/demon/succubus/S, mob/living/target, hp = 75)
	if(S)
		name = S.name
		desc = S.desc
		icon = S.icon
		icon_state = S.icon_state
		icon_dead = S.icon_dead
		if("attack_sound" in S.vars) attack_sound = S.vars["attack_sound"]
	health = maxHealth = max(1, hp)
	if(istype(ai_controller))
		ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = target

/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion/proc/EnsureCombatIntent_Illusion()
	if(!islist(possible_a_intents) || !length(possible_a_intents))
		possible_a_intents = list(
			/datum/intent/unarmed/claw,
			/datum/intent/simple/bigbite
		)
	var/list/lethals = list()
	for(var/datum/intent/I as anything in possible_a_intents)
		if(istype(I, /datum/intent/unarmed/help) || istype(I, /datum/intent/unarmed/shove) || istype(I, /datum/intent/unarmed/grab))
			continue
		lethals += I
	if(length(lethals))
		a_intent = pick(lethals)
		used_intent = a_intent

/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion/death(gibbed)
	var/turf/T = get_turf(src)
	if(T)
		var/obj/effect/particle_effect/smoke/S = new /obj/effect/particle_effect/smoke(T)
		if("amount" in S.vars) S.amount = 0
	qdel(src)
	return
// ======================= Vanish & Regenerate (real succubus) =======================
/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/CanVanish()
	return Now() >= vanish_last + vanish_cd && !vanishing

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/TryVanishRegen(mob/living/target)
	if(!target)
		return FALSE
	if(!CanVanish())
		return FALSE

	vanishing = TRUE
	vanish_last = Now()

	var/turf/dest = null
	var/list/cands = list()
	for(var/turf/T in range(5, target))
		if(T && !T.density && get_dist(T, target) >= 3)
			cands += T
	if(cands.len)
		dest = pick(cands)
	else
		dest = get_turf(src)

	visible_message(span_notice("[src] dissolves into rose-scented smoke!"))
	alpha = 70
	invisibility = 101
	forceMove(dest)

	spawn(0)
		var/ticks = vanish_duration
		while(ticks-- > 0 && !QDELETED(src))
			if(health >= round(maxHealth * 0.75))
				break
			health = min(maxHealth, health + vanish_heal_per_tick)
			sleep(1)

		var/turf/ret = null
		if(target && !QDELETED(target))
			var/backdir = turn(get_dir(target, src), 180)
			var/turf/behind = get_step(target, backdir)
			if(behind && !behind.density)
				ret = behind
			else
				for(var/turf/T2 in range(1, target))
					if(T2 && !T2.density)
						ret = T2
						break

		if(ret)
			forceMove(ret)
		alpha = 255
		invisibility = 0
		visible_message(span_notice("[src] coalesces from drifting glamour!"))
		vanishing = FALSE
