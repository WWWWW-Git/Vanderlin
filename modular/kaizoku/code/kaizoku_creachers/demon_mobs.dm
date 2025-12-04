// ============================== PACK GOON AI ===============================

/datum/ai_controller/demon/goonpack
	movement_delay = 0.6 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items()
	)

	// find target → use our melee (flurry+special)
	planning_subtrees = list(
		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/goonpack
	)

	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_planning_subtree/basic_melee_attack_subtree/goonpack
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/goonpack

/datum/ai_behavior/basic_melee_attack/goonpack
	action_cooldown = 0.2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/goonpack/perform(delta_time, datum/ai_controller/C, target_key, td_key, hide_key)
	var/mob/living/simple_animal/basic = C.pawn //Not using ..() here. The global cooldowns are DESTROYING my special attack code.
	if(!istype(basic, /mob/living/simple_animal/hostile/retaliate/demon/goonpack))
		finish_action(C, FALSE, target_key); return
	var/mob/living/simple_animal/hostile/retaliate/demon/goonpack/G = basic

	var/atom/target = C.blackboard[target_key]
	var/datum/targetting_datum/TD = C.blackboard[td_key]
	if(QDELETED(target) || !TD || !TD.can_attack(basic, target))
		finish_action(C, FALSE, target_key); return

	if(ismob(target))
		if(target:stat == DEAD)
			finish_action(C, FALSE, target_key); return

	var/atom/hiding_target = TD.find_hidden_mobs(basic, target) //Because it is important to respect hidden targets.
	C.set_blackboard_key(hide_key, hiding_target)

	if(ismob(target))
		basic.face_atom(target)
	var/list/possible_intents = list()
	for(var/datum/intent/intent as anything in basic.possible_a_intents)
		if(istype(intent, /datum/intent/unarmed/help) || istype(intent, /datum/intent/unarmed/shove) || istype(intent, /datum/intent/unarmed/grab))
			continue
		possible_intents |= intent
	if(length(possible_intents))
		basic.a_intent = pick(possible_intents)
		basic.used_intent = basic.a_intent

	if(!basic.CanReach(hiding_target || target))
		finish_action(C, FALSE, target_key); return
	C.ai_interact(hiding_target || target, TRUE, TRUE)

	if(G.pack_size > 1) //This is meant to increase the amount of attacks depending of how many demons are around. Does not work 100%, sadly.
		var/extras = G.pack_size - 1
		for(var/i = 1, i <= extras, i++) //I will come back to this when I'm less stressed.
			C.ai_interact(hiding_target || target, TRUE, TRUE)

	if(G.pack_size >= 2 && G.CanSpecial() && prob(G.special_prob))
		if(isliving(target))
			if(G.TryDogpile(target)) //Special attack!
				G.MarkSpecialUsed()

	finish_action(C, TRUE, target_key)


/mob/living/simple_animal/hostile/retaliate/demon/goonpack/sinful1
	name = "gaki"
	sinful_index = 1

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/sinful2
	name = "akaname"
	sinful_index = 2

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/sinful3
	name = "the infected"
	sinful_index = 3

/mob/living/simple_animal/hostile/retaliate/demon/goonpack
	name = "gaki"
	desc = "Minor manifestation of greed, insatiable hunger and hoarding of earthly desires brought this humen soul into damnation."
	faction = list("demons","cabal","graggar")

	ai_controller = /datum/ai_controller/demon/goonpack

	density = TRUE
	speed = 1
	icon = 'modular/kaizoku/icons/mobs/sinful.dmi'
	icon_state = "sinful1"
	icon_living = "sinful1"
	icon_dead = "sinful1_dead"

	see_in_dark = 8
	move_to_delay = 7
	vision_range = 6
	aggro_vision_range = 6
	aggressive = TRUE
	minimum_distance = 0
	retreat_distance = 0
	deaggroprob = 0
	var/range = 6 // for ai_aggro_system
	base_intents = list(/datum/intent/unarmed/claw, /datum/intent/simple/bigbite) //Their default melee behavior. Sourced from normal animals.

	var/pack_size = 1 //Maximum of three friend boyz
	var/max_pack_size = 3
	var/member_hp = 55
	health = 120
	maxHealth = 120

	// melee baseline (AI uses this; our behavior flurries on top)
	melee_damage_lower = 15
	melee_damage_upper = 25
	melee_attack_cooldown = 12
	next_click = 0
	var/special_cooldown = 45 //Special attacks for dogpilling system.
	var/special_prob = 15   //15% chance of dealing a special attack.
	var/post_special_delay = 6
	var/last_special_time = 0
	var/power_disarm_base = 14
	var/power_offbalance_base = 16
	var/power_kd_base = 18
	var/sinful_index = 0 //Variants; 0 is random.
	var/base_icon_ref = null //Little sad system for the sake of keeping deathstates working. Very "sorry" code. Someone replace this.
	var/base_living_state_ref = null
	var/base_dead_state_ref = null
	var/flip_on_death_cached = FALSE
	var/list/member_overlays = null //Overlay for the GANG
	var/list/member_states = null
	var/list/member_healths = null
	var/static/list/offsets_pack = list(
		list(  0,  0), // center mob. 'The Leader' and last one to die.
		list(-13,  0),
		list( 13,  0)
	)
	var/next_merge_time = 0

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_aggro_system, 10, range)
	if(sinful_index <= 0 || sinful_index > 3) //Chooses a random variant.
		sinful_index = rand(1, 3)

	switch(sinful_index)
		if(1)
			name = "gaki"
			desc = "Minor manifestation of greed, insatiable hunger and hoarding of \
			earthly desires brought this humen soul into damnation."
		if(2)
			name = "akaname"
			desc = "Minor manifestation of sloth. Whom creeps through filth and neglect, \
			feeding on the laziness and thriving where effort has decayed."
		if(3)
			name = "the infected"
			desc = "Minor manifestation of wrath. A mind of festered rage controls the vessel\
			of an invasive force from the mainland, grenzelhoft in flesh and clothes."

	var/L = "sinful[sinful_index]"
	var/D = "sinful[sinful_index]_dead"
	icon_state = L
	if("icon_living" in vars) vars["icon_living"] = L
	if("icon_dead"   in vars) vars["icon_dead"]   = D

	base_icon_ref = icon
	base_living_state_ref = ("icon_living" in vars && vars["icon_living"]) ? vars["icon_living"] : icon_state
	base_dead_state_ref   = ("icon_dead"   in vars && vars["icon_dead"])   ? vars["icon_dead"]   : "[base_living_state_ref]_dead"
	if("flip_on_death" in vars && vars["flip_on_death"]) flip_on_death_cached = TRUE

	// Initialize member arrays
	if(!islist(member_states))  member_states  = list()
	if(!islist(member_healths)) member_healths = list()
	member_states.Cut()
	member_healths.Cut()
	for(var/i = 1, i <= pack_size, i++)
		member_healths += member_hp // one slot per member

	SyncVitalsToMembers()
	RebuildOverlays()

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/Life()
	. = ..()
	if(stat == DEAD) return
	if(world.time >= next_merge_time)
		TryMergeNearby()
		next_merge_time = world.time + 10 // ~0.1s on 1ds tick servers

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/Destroy()
	ClearOverlays()
	return ..()

// ============================ DAMAGE & HEALTH ============================

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/RescalePackHealth()
	maxHealth = max(1, pack_size * member_hp)
	health = clamp(health, 1, maxHealth)

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/GPStat(mob/living/L, key, def=6)
	if(!L) return def
	if(!(key in L.vars)) return def
	var/v = L.vars[key]
	return isnum(v) ? v : def

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/SyncVitalsToMembers()
	var/total = 0
	if(member_healths)
		for(var/h in member_healths)
			if(isnum(h)) total += h
	maxHealth = max(0, pack_size * member_hp)
	if(pack_size <= 0)
		health = 0
	else
		health = max(1, min(total, maxHealth))

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, forced = FALSE, spread_damage = FALSE)
	if(damage <= 0 || pack_size <= 0)
		return 0 //No damage dealt, so ignore it.
	var/dmg = max(0, damage - (blocked || 0)) //Blocked? no damage.
	while(dmg > 0 && pack_size > 0) // if we have members left, chew from the back line toward the leader. Otherwise the leader will DIE instantly.
		var/idx = member_healths.len// target the LAST member
		var/hp = member_healths[idx]
		var/take = min(dmg, hp)
		hp -= take
		dmg -= take
		if(hp <= 0)
			PopMember(idx) //Kills this member. However, if it is the final one, does not spawn their body. Let /death do it.
		else
			member_healths[idx] = hp
	SyncVitalsToMembers() //sync vitals
	if(pack_size <= 0 && stat != DEAD) //All members gone? Then spawn the real corpse.
		death(FALSE)
	return damage

// =============================== OVERLAYS ================================

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/ClearOverlays() //Clean the deadass
	if(!member_overlays)
		return
	for(var/image/I in member_overlays)
		overlays -= I
	member_overlays.Cut()

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/RebuildOverlays() //Rebuild the deadass
	ClearOverlays()
	member_overlays = list()
	while(length(member_states) > max(0, pack_size - 1)) //Ensures the pack size always matches. Otherwise we will have very naught bugs.
		member_states.Cut(member_states.len, member_states.len+1)
	while(length(member_states) < max(0, pack_size - 1))
		member_states += base_living_state_ref

	var/limit = min(length(member_states), max(0, length(offsets_pack) - 1))
	for(var/i = 1, i <= limit, i++)
		var/list/off = offsets_pack[i + 1]
		var/ist = member_states[i]
		var/image/I = image(base_icon_ref, ist)
		I.pixel_x = off[1]
		I.pixel_y = off[2]
		I.layer   = MOB_LAYER
		I.appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
		member_overlays += I
		overlays += I


/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/PopMember(idx)
	if(pack_size <= 1)
		pack_size = 0 //Last member > don't spawn an corpse effect.
		if(member_healths) member_healths.Cut()
		if(member_states)  member_states.Cut()
		ClearOverlays()
		return

	var/popped_state = base_living_state_ref
	if(member_states && member_states.len) // overlays to member type. Avoid spawning the wrong body.
		popped_state = member_states[member_states.len]
		member_states.Cut(member_states.len, member_states.len+1)
	if(member_healths && member_healths.len >= idx) //Remove the HP slot after killing the last member.
		member_healths.Cut(idx, idx+1)
	if(member_overlays && member_overlays.len) //And finally, remove the last overlay image.
		var/image/oi = member_overlays[member_overlays.len]
		overlays -= oi
		member_overlays.Cut(member_overlays.len, member_overlays.len+1)
	pack_size = max(0, pack_size - 1)
	SpawnMemberRemains(popped_state)



// ============================ REMAINS (EFFECT) ============================

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/SpawnMemberRemains(living_state)
	var/turf/T = get_turf(src)
	if(!T) //Somehow this runtimed, so I gave this check. I hate this.
		return

	var/use_live = living_state ? living_state : base_living_state_ref
	var/dead_guess = "[use_live]_dead" //Choose deadtype.
	var/list/all_states = icon_states(base_icon_ref)
	var/use_dead = (all_states && (dead_guess in all_states)) ? dead_guess : base_dead_state_ref

	var/obj/effect/decal/remains/goon/R = new(T)
	R.icon = base_icon_ref
	R.icon_state = use_dead
	R.pixel_x = pick(-10, 10)
	R.pixel_y = pick(-6, 6)
	spawn(6 SECONDS) //Despawns after six seconds. They are too weak to be corpse-worthy.
	qdel(R)



// ============================== MERGING LOGIC =============================

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/TryMergeNearby()
	if(pack_size >= max_pack_size)
		return
	var/mob/living/simple_animal/hostile/retaliate/demon/goonpack/other = null //Pick any gangfriend nearby.
	for(var/mob/living/simple_animal/hostile/retaliate/demon/goonpack/G in range(1, src))
		if(G == src || G.stat == DEAD)
			continue
		if(G.pack_size <= 0)
			continue
		other = G
		break
	if(!other)
		return
	DoMergeWith(other)

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/DoMergeWith(mob/living/simple_animal/hostile/retaliate/demon/goonpack/other)
	if(!other || other == src)
		return
	if(pack_size >= max_pack_size || other.pack_size <= 0)
		return

	var/mob/living/simple_animal/hostile/retaliate/demon/goonpack/host = src
	var/mob/living/simple_animal/hostile/retaliate/demon/goonpack/guest = other
	if(other.pack_size > pack_size)
		host = other; guest = src
	if(host == guest)
		return

	if(host != src)
		return //If we are not host, let it absorb us.

	var/free_slots = max_pack_size - host.pack_size
	var/transfer = clamp(guest.pack_size, 0, free_slots)
	if(transfer <= 0)
		return

	host.member_states  = list() //Absorb code.
	host.member_healths = list()
	guest.member_states = list()
	guest.member_healths = list()

	for(var/i = 1, i <= transfer, i++)
		host.member_states  += guest.base_living_state_ref
		host.member_healths += host.member_hp

	host.pack_size += transfer
	host.SyncVitalsToMembers()
	host.RebuildOverlays()
	host.visible_message(span_warning("[host] brings over [guest] into their swarm!"))

	// shrink guest arrays to new size
	guest.pack_size -= transfer
	while(guest.member_states.len > max(0, guest.pack_size - 1))
		guest.member_states.Cut(guest.member_states.len, guest.member_states.len+1)
	while(guest.member_healths.len > guest.pack_size)
		guest.member_healths.Cut(guest.member_healths.len, guest.member_healths.len+1)
	guest.SyncVitalsToMembers()
	guest.RebuildOverlays()

	if(guest.pack_size <= 0)
		qdel(guest)

// ============================== SPECIAL MOVES ==============================

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/NowTime()
	return world.time

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/CanSpecial()
	return (pack_size >= 2) && (NowTime() >= last_special_time + special_cooldown)

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/MarkSpecialUsed()
	last_special_time = NowTime()

// pull target stats safely (defaults if missing)
/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/GetStatSafe(mob/living/L, key, def=6)
	if(!L)
		return def
	if(!(key in L.vars))
		return def
	var/v = L.vars[key]
	return isnum(v) ? v : def

//The system is simple:
// Dogpile: 2 = disarm
// 3 = offbalance.
// The more swarmers, the more abilities they have.

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/proc/TryDogpile(mob/living/L)
	if(!L)
		return FALSE
	if(get_dist(src, L) > 1)
		return FALSE

	var/succeeded = FALSE
	var/list/msg = list()

	var/sSTR = GetStatSafe(L, "STASTR", 6)
	var/sCON = GetStatSafe(L, "STACON", 6)
	if(pack_size >= 2) //Disarm system made to make these creatures hell to battle with. Disarm vs Strength
		var/obj/item/W = L.get_active_held_item()
		if(W && (power_disarm_base + rand(1,6)) > (sSTR + rand(1,6)))
			L.dropItemToGround(W)
			var/turf/t = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
			if(t) W.throw_at(t, 3, 1)
			msg += "[src] rips [W] from [L]'s hands!"
			succeeded = TRUE

	if(pack_size >= 3 && (power_offbalance_base + rand(1,6)) > (sCON + rand(1,6))) //Set people offbalance.
		L.OffBalance(10)
		msg += "[src]'s swarm presses against [L]!"
		succeeded = TRUE
	L.apply_damage(rand(2,3) * clamp(pack_size, 1, max_pack_size), BRUTE, BODY_ZONE_CHEST) //Chip damage from the swarm's weight.
	if(succeeded)
		visible_message(span_danger(jointext(msg, " ")))
	else
		visible_message(span_warning("[L] endures the weight!."))
	return TRUE

// ========================= PLACEABLE SINFUL VARIANTS ========================

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/sinful1
	name = "gaki"
	sinful_index = 1

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/sinful2
	name = "akaname"
	sinful_index = 2

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/sinful3
	name = "the infected"
	sinful_index = 3

// ============================ REMAINS EFFECT ============================

/obj/effect/decal/remains/goon
	name = "remains"
	gender = PLURAL
	anchored = TRUE
	density = FALSE
	layer = MOB_LAYER - 0.1
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER

/mob/living/simple_animal/hostile/retaliate/demon/goonpack/simple_try_crit(bclass, dam, mob/living/user, zone_precise, silent = FALSE, crit_message = FALSE)
	if(!(maxHealth > 0)) //THIS CODE IS AN RUNTIME-KILLER.
		return FALSE
	return ..()

// ======================================================================
//  Succubus — robust melee + charm + organized illusions + vanish/regen
//  - Uses stock melee subtree + Life() fallback → guaranteed attacks
//  - Charm when adjacent (non-blocking to melee)
//  - Illusions: identical look/name/desc, 75 HP, zero damage, no corpses
//      • Spawns exactly three: BEHIND, LEFT, RIGHT (relative to target)
//      • Old illusions are always qdel’d before a new set spawns
//  - Vanish & Regenerate capped (ends early at 75% HP) so she’s not “immortal”
// ======================================================================


// ------------ movement reverse flag read by client/Move (for charm) ------------
/mob/living
	var/tmp/succubus_reverse_controls = FALSE



// ===================== Targeting (non-demon only) =====================
/datum/targetting_datum/demon_succubus_target
/datum/targetting_datum/demon_succubus_target/can_attack(mob/living/self, atom/T)
	if(!T || !ismob(T)) return FALSE
	if(T == self) return FALSE
	var/mob/living/M = T
	if(islist(M.faction))
		if(("demons" in M.faction) || ("cabal" in M.faction) || ("graggar" in M.faction))
			return FALSE
	return TRUE



// ============================== AI: Controller ==============================
/datum/ai_controller/demon_succubus
	movement_delay = 0.5 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/demon_succubus_target()
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/aggro_find_target,                 // stock target finder
		/datum/ai_planning_subtree/demon_succubus_adjacent_charm,     // if adjacent, try charm
		/datum/ai_planning_subtree/basic_melee_attack_subtree/succubus // then melee
	)
	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_planning_subtree/basic_melee_attack_subtree/succubus
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/succubus



// ===================== Adjacent charm planner (simple) =====================
/datum/ai_planning_subtree/demon_succubus_adjacent_charm
/datum/ai_planning_subtree/demon_succubus_adjacent_charm/SelectBehaviors(datum/ai_controller/C, delta_time)
	. = ..()
	var/mob/living/simple_animal/hostile/retaliate/demon/succubus/S = C.pawn
	if(!istype(S) || S.stat == DEAD) return
	if(S.vanishing) return // don’t plan anything while vanished

	var/mob/living/target = C.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target)) return

	if(get_dist(S, target) <= 1 && S.CanAttemptCharm())
		C.queue_behavior(/datum/ai_behavior/demon_succubus_try_charm, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, null)
		return SUBTREE_RETURN_FINISH_PLANNING



// ========================== Charm behavior (1-shot) =========================
/datum/ai_behavior/demon_succubus_try_charm
	action_cooldown = 0.3 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/demon_succubus_try_charm/perform(delta_time, datum/ai_controller/C, target_key, _, __)
	var/mob/living/simple_animal/hostile/retaliate/demon/succubus/S = C.pawn
	if(!istype(S) || S.vanishing) { finish_action(C, FALSE); return }

	var/atom/T = C.blackboard[target_key]
	if(QDELETED(T)) { finish_action(C, FALSE); return }

	if(S.TryCharm(T))
		S.next_click = world.time + (S.special_post_delay || 10)
		finish_action(C, TRUE, target_key)
	else
		finish_action(C, FALSE, target_key)



// ========================= Melee behavior (guaranteed hit) ==================
/datum/ai_behavior/basic_melee_attack/succubus
	action_cooldown = 0.2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/succubus/perform(delta_time, datum/ai_controller/C, target_key, targetting_datum_key, hiding_location_key)
	// Do NOT call ..() — we fully control the swing so it never gets swallowed
	var/mob/living/simple_animal/hostile/retaliate/demon/succubus/S = C.pawn
	if(!istype(S) || S.vanishing) { finish_action(C, FALSE, target_key); return }

	var/atom/target = C.blackboard[target_key]
	var/datum/targetting_datum/TD = C.blackboard[targetting_datum_key]
	if(QDELETED(target) || !TD || !TD.can_attack(S, target)) { finish_action(C, FALSE, target_key); return }
	if(ismob(target) && target:stat == DEAD) { finish_action(C, FALSE, target_key); return }

	// close distance
	if(get_dist(S, target) > 1)
		C.set_movement_target(target)
		return

	S.EnsureCombatIntent()
	S.face_atom(target)

	// Try charm in the SAME window (doesn't block the hit)
	if(S.CanAttemptCharm())
		S.TryCharm(target)

	// swing using the SAME route your base melee uses
	var/hiding_target = (TD ? TD.find_hidden_mobs(S, target) : null)
	if(hiding_target)
		C.ai_interact(hiding_target, TRUE, TRUE)
	else
		C.ai_interact(target, TRUE, TRUE)

	if(S.next_click < world.time)
		S.next_click = world.time + (S.melee_attack_cooldown || 15)
	SEND_SIGNAL(S, COMSIG_MOB_BREAK_SNEAK)

	finish_action(C, TRUE, target_key)



// ============================== The Mob ==============================
/mob/living/simple_animal/hostile/retaliate/demon/succubus
	name = "Succubus"
	desc = "A beguiling predator whose gaze unthreads resolve and turns limbs traitor."

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

	// Charm knobs
	var/special_chance = 30           // % chance to attempt charm when adjacent
	var/special_cd = 80               // ~8s between charms
	var/special_post_delay = 15       // post-charm pause
	var/charm_last_special = 0        // last charm time
	var/charm_duration = 300          // ~30s
	var/power_charm = 18              // attacker baseline vs defender stats

	// Illusions
	var/illusion_chance = 35
	var/illusion_cd = 120
	var/illusion_last = 0
	var/illusion_count = 3            // spawn exactly three
	var/illusion_hp = 75
	var/list/active_illusions = list()

	// Vanish & Regenerate (capped to avoid “immortal” feel)
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


/*********************** Lifecycle ***********************/
//// Safe even if the component doesn’t exist in your codebase.
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
	if(stat == DEAD) return
	if(vanishing) return

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

	// Organized illusions (behind/left/right), with cleanup
	if(target && get_dist(src, target) <= 2)
		if(Now() >= illusion_last + illusion_cd && prob(illusion_chance))
			SpawnIllusions(target)
			illusion_last = Now()

	if(CanVanish() && target)
		if(prob(vanish_chance) && (health <= round(maxHealth * vanish_hp_threshold)))
			TryVanishRegen(target)

	// Guaranteed swing fallback
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
	if(!L) return def
	if(name in L.vars)
		var/v = L.vars[name]
		if(isnum(v)) return v
	return def

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/OpposedRollCharm(mob/living/L)
	var/primary = src.GetStatSafe(L, "STADEX", 6)
	var/second  = src.GetStatSafe(L, "STACON", 6)
	var/atk = src.power_charm + rand(1,6)
	var/def = primary + round(second/2) + rand(1,6)
	return (atk > def)



/********************** Charm attempt **********************/
/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/TryCharm(atom/T)
	if(!isliving(T)) return FALSE
	var/mob/living/L = T

	visible_message(span_warning("[src]'s eyes glimmer with honeyed malice..."))
	if(length(src.whispers))
		playsound(get_turf(src), pick(src.whispers), 70, TRUE)

	if(!src.OpposedRollCharm(L))
		L.visible_message(
			span_notice("[L] blinks hard and shakes off the enchantment!"),
			span_info("You resist the enthralling gaze!")
		)
		return FALSE

	L.apply_status_effect(/datum/status_effect/succubus_charmed, src.charm_duration)

	L.visible_message(
		span_danger("[L] sways as will buckles—bewitched!"),
		span_warning("A velvet fog takes your mind—your limbs betray you!")
	)

	src.charm_last_special = src.Now()
	return TRUE



/********************** Illusions: organized + cleanup **********************/
/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/CleanupIllusions()
	if(!active_illusions) return
	for(var/mob/living/simple_animal/hostile/retaliate/demon/succubus_illusion/I in active_illusions)
		if(I && !QDELETED(I)) qdel(I)
	active_illusions.Cut()

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/SafeSpot(turf/center, dir)
	if(!center) return null
	var/turf/T = get_step(center, dir)
	if(T && !T.density) return T
	// fallback ring search if blocked
	for(var/turf/R in range(1, center))
		if(R && !R.density) return R
	return null

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/SpawnIllusions(mob/living/target)
	var/turf/center = get_turf(src)
	if(!center) return

	// Always clear previous illusions first
	CleanupIllusions()

	// Directions relative to the attacker → behind, left, right
	var/base_dir = get_dir(src, target)
	if(!base_dir) base_dir = SOUTH
	var/list/spawn_dirs = list(
		turn(base_dir, 180),  // behind
		turn(base_dir, 90),   // left
		turn(base_dir, -90)   // right
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

	if(spawned)
		visible_message(span_notice("[src]'s shape fractures—copies lunge from the haze!"))



// ======================= Status Effect (HUD + reverse) =======================
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
	if(!.) return
	var/mob/living/L = owner
	if(!L) return
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
	if(!W) return
	if(L.next_click > world.time) return
	var/mob/living/target = FindAdjacentEnemy(L)
	if(!target) return
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
	desc = "Your will is enthralled; movement is reversed."
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'
	icon_state = "shaken"



// ======================================================================
//               I L L U S I O N   M O B   (identical, harmless)
// ======================================================================

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
	if(!istype(I)) { finish_action(C, FALSE, target_key); return }

	var/atom/target = C.blackboard[target_key]
	var/datum/targetting_datum/TD = C.blackboard[td_key]
	if(QDELETED(target) || !TD || !TD.can_attack(I, target)) { finish_action(C, FALSE, target_key); return }
	if(ismob(target) && target:stat == DEAD) { finish_action(C, FALSE, target_key); return }

	if(get_dist(I, target) > 1)
		C.set_movement_target(target)
		return

	// ensure an offensive intent so resolveAdjacentClick sees used_intent
	I.EnsureCombatIntent_Illusion()
	I.face_atom(target)

	// normal swing path (does 0 damage but triggers normal flow)
	C.ai_interact(target, TRUE, TRUE)

	// force a visible attack line so it *looks* real even if damage is 0
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

	// zero damage; pure deception
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
		// mirror sounds if the real one has them
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
	// spawn a single-tile smoke puff at the death turf
	var/turf/T = get_turf(src)
	if(T)
		var/obj/effect/particle_effect/smoke/S = new /obj/effect/particle_effect/smoke(T)
		// keep it single-tile (only if these vars exist in your smoke)
		if("amount" in S.vars) S.amount = 0
		// optional: shorten how long it lingers (ticks)
		// if("lifetime" in S.vars) S.lifetime = 25

	// illusions shouldn’t leave corpses
	qdel(src)
	return
// ======================= Vanish & Regenerate (real succubus) =======================
/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/CanVanish()
	return Now() >= vanish_last + vanish_cd && !vanishing

/mob/living/simple_animal/hostile/retaliate/demon/succubus/proc/TryVanishRegen(mob/living/target)
	if(!target) return FALSE
	if(!CanVanish()) return FALSE

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
			if(health >= round(maxHealth * 0.75)) break // cap healing to avoid “immortal” feel
			health = min(maxHealth, health + vanish_heal_per_tick)
			sleep(1)

		var/turf/ret = null
		if(target && !QDELETED(target))
			var/backdir = turn(get_dir(target, src), 180)
			var/turf/behind = get_step(target, backdir)
			if(behind && !behind.density) ret = behind
			else
				for(var/turf/T2 in range(1, target))
					if(T2 && !T2.density) { ret = T2; break }

		if(ret) forceMove(ret)
		alpha = 255
		invisibility = 0
		visible_message(span_notice("[src] coalesces from drifting glamour!"))
		vanishing = FALSE
