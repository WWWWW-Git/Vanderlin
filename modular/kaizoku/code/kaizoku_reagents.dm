/datum/reagent/fogblight
	name = "fogblight"
	description = "liquid concentrate from fog island's frogs. Used by shinobis."
	taste_description = ""
	reagent_state = LIQUID
	color = "#1f434d"
	metabolization_rate = 0.2

/datum/reagent/fogblight/on_mob_life(mob/living/carbon/M)
	switch(current_cycle)
		if(1 to 20)
			M.confused += 2
			M.drowsyness += 2
		if(30 to 50)
			M.Sleeping(40, 0)
			. = 1
		if(51 to INFINITY)
			M.Sleeping(40, 0)
			M.adjustToxLoss((current_cycle - 50)*REM, 0)
			. = 1
	..()

// Enhanced fogblight corruption with better progression and warnings
/datum/reagent/fogblight/corruption
	name = "devilblight"
	description = "A corrupted mimicry of the fogblight. Some demons started to produce it after exposure."
	taste_description = "earthy"
	reagent_state = LIQUID
	color = "#3a5f66"
	metabolization_rate = 0.3 // Reduced from 0.5 for weaker effect
	var/crash_started = FALSE
	var/warning_stage = 0

/datum/reagent/fogblight/corruption/on_mob_life(mob/living/carbon/M)
	if(M.stat != UNCONSCIOUS)
		// Early warning stages with flavor text
		if(current_cycle <= 50)
			if(current_cycle % 15 == 0)
				switch(warning_stage)
					if(0)
						to_chat(M, "<span class='notice'>You feel slightly drowsy...</span>")
						warning_stage++
					if(1)
						to_chat(M, "<span class='notice'>You stifle a small yawn.</span>")
						M.emote("yawn")
						warning_stage++
					if(2)
						to_chat(M, "<span class='warning'>Your eyelids feel heavy.</span>")
						warning_stage++
				M.drowsyness += 1

		// Medium exposure - more warnings
		else if(current_cycle <= 100)
			if(current_cycle % 20 == 0)
				var/list/sleepy_messages = list(
					"You feel an overwhelming urge to rest.",
					"The world seems to sway gently around you.",
					"Your thoughts feel sluggish and distant.",
					"You catch yourself nodding off.",
					"Everything seems so peaceful and quiet..."
				)
				to_chat(M, "<span class='warning'>[pick(sleepy_messages)]</span>")
				if(prob(30))
					M.emote("yawn")
			M.drowsyness += 2
			M.confused += 1

		// Heavy exposure - chance to fall asleep
		else if(current_cycle <= 200)
			M.drowsyness += 3
			M.confused += 2
			if(current_cycle % 25 == 0 && prob(40)) // Only 40% chance to fall asleep
				to_chat(M, "<span class='danger'>You can't keep your eyes open any longer...</span>")
				M.Sleeping(50, 0)

		// Critical exposure
		else
			if(!crash_started && prob(60)) // 60% chance to enter crash phase
				crash_started = TRUE
				to_chat(M, "<span class='userdanger'>The toxic fog overwhelms your system!</span>")
				M.Sleeping(100, 0)
			else if(crash_started)
				M.adjustToxLoss(0.05, 0) // Reduced damage
	else
		if(crash_started)
			M.adjustToxLoss(0.05, 0) // Reduced damage

	. = ..()

/*
// ===================================================
// Holy Water — Consecrated Ground + Cone Splash + Blessed Edge
// (drop-in replacement for your previous holywater block)
// ===================================================

// ---------- Tunables ----------
#define HOLY_GROUND_LIFETIME   (10 MINUTES)
#define HOLY_GROUND_TICK_DELAY 20       // deciseconds between damage ticks to the same mob
#define HOLY_GROUND_DAMAGE     20       // damage applied to CABAL only

// ---------- Helpers ----------
/proc/is_unholy_creature(mob/living/target)
	if(!target) return FALSE
	if(target.mob_biotypes & MOB_UNDEAD) return TRUE
	if(target.mob_biotypes & MOB_SPIRIT) return TRUE
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(islist(C.faction) && (FACTION_ORCS in C.faction)) return TRUE
		if(HAS_TRAIT(C, TRAIT_NASTY_EATER)) return TRUE
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.dna?.species?.id == "tiefling") return TRUE
	return FALSE

/proc/is_demon_mob(mob/living/M)
	return istype(M) && islist(M.faction) && (FACTION_CABAL in M.faction)

/// Optional: call this from your damage pipeline if you want global demon 50% resistance.
/// If the weapon is blessed (see enchantment below), resistance is ignored.
/proc/holy_adjust_vs_demon(amount, obj/item/weapon/W, mob/living/target)
	if(!istype(target) || !is_demon_mob(target))
		return amount
	// Blessed weapons ignore demon resistance:
	if(SSenchantment && SSenchantment.has_enchantment(W, /datum/enchantment/abyss_blessed_edge))
		return amount
	return round(amount * 0.5)

// ---------- Mob cool-down var for holy ground ticks ----------
/mob/living/var/holy_ground_next_tick = 0

// ---------- Consecrated Ground tile effect ----------
/obj/effect/holy_ground
	name = "consecrated ground"
	icon = 'modular/kaizoku/icons/misc/spells.dmi'
	icon_state = "holywater"
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/holy_ground/Initialize()
	. = ..()
	// Auto-delete after lifetime
	QDEL_IN(src, HOLY_GROUND_LIFETIME)
	return .

/turf/open
	var/holy = FALSE

/// If demon corruption tries to appear later on this turf, kill it instantly.
/obj/effect/holy_ground/Entered(atom/movable/AM)
	. = ..()
	if(istype(AM, /obj/effect/demon/corruption))
		qdel(AM)
		return
	return .

/// Tick damage to CABAL only when they cross/step on it.
/obj/effect/holy_ground/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(!isliving(AM)) return
	var/mob/living/L = AM
	if(!(FACTION_CABAL in (L.faction || list()))) return
	if(world.time < (L.holy_ground_next_tick || 0)) return

	// Holy damage feel: use fire/“burning” style
	L.adjustFireLoss(HOLY_GROUND_DAMAGE)
	to_chat(L, "<span class='userdanger'>Sanctified ground sears your profane flesh!</span>")
	L.holy_ground_next_tick = world.time + HOLY_GROUND_TICK_DELAY

// ---------- Hyōtan helper on reagent holders ----------
/datum/reagents/proc/splash_at_cone_if_holy(turf/open/T, mob/living/user)
	var/datum/reagent/water/holywater/HW = get_reagent(/datum/reagent/water/holywater)
	if(!HW) return 0

	var/amt = get_reagent_amount(/datum/reagent/water/holywater)
	if(amt <= 0) return 0

	var/used = HW.handle_cone_splash(user, T, amt)
	if(used > 0)
		remove_reagent(/datum/reagent/water/holywater, used)
		return used
	return 0

// ---------- Holy Water reagent ----------
/datum/reagent/water/holywater
	name = "Holy Water"
	description = "Blessed water, bane to corruption."
	color = "#a8c5c4c6"
	taste_description = "water"
	glass_icon_state = "glass_clear"
	glass_name = "glass of holy water"
	glass_desc = "It sprinkles slightly under the light."
	shot_glass_icon_state = "shotglassclear"
	hydration = 15
	alpha = 100
	taste_mult = 0.15
	var/blessing_strength = 1.0

/// Core: bless a tile (sets flag, creates persistent consecrated ground, purges demons on that tile)
/datum/reagent/water/holywater/proc/apply_holy_to_tile(turf/open/U, reac_volume)
	if(!istype(U, /turf/open)) return

	// Flag for other systems if you want to read it:
	U.holy = TRUE

	// Place/refresh the consecrated ground overlay
	if(!(locate(/obj/effect/holy_ground) in U))
		new /obj/effect/holy_ground(U)

	// Purge existing corruption immediately
	for(var/obj/effect/demon/corruption/C in U)
		qdel(C)

	// Ping demon structures on this turf (gateways/cores resist via reagent_act)
	for(var/obj/structure/demon/D in U)
		D.reagent_act(src, reac_volume)

	// Smite obviously unholy things standing here right now (minor immediate ping)
	for(var/mob/living/M in U)
		if(is_unholy_creature(M))
			M.take_overall_damage(0, max(2, round(reac_volume * 0.5)))

/// Clean up mostly-holy puddles (prevents leftover water lakes)
/datum/reagent/water/holywater/proc/cleanup_puddle_at(turf/open/U, tries = 3)
	if(QDELETED(U)) return
	if(QDELETED(U.liquids) || QDELETED(U.liquids.liquid_group)) return
	var/datum/liquid_group/G = U.liquids.liquid_group
	var/only_holyish = TRUE
	for(var/datum/reagent/R as anything in G.reagents.reagent_list)
		if(!istype(R, /datum/reagent/water/holywater) && !istype(R, /datum/reagent/water))
			only_holyish = FALSE
			break
	if(only_holyish)
		G.remove_from_group(U, TRUE)
		QDEL_NULL(U.liquids)
		return
	if(tries > 1)
		addtimer(CALLBACK(src, .proc/cleanup_puddle_at, U, tries - 1), 4)

/// Compact widening cone (0,1,2,3...) — no duplicate widths
/datum/reagent/water/holywater/proc/cone_spread_from(mob/living/user, turf/open/start, facing, total_amt)
	if(!start || total_amt <= 0) return

	var/range = clamp(1 + round(total_amt / 10), 2, 8)
	var/per_tile_volume = 3
	var/tiles_touched = 0

	var/dx = 0, dy = 0
	switch(facing)
		if(NORTH) dy = 1
		if(EAST)  dx = 1
		if(SOUTH) dy = -1
		if(WEST)  dx = -1

	for(var/distance in 1 to range)
		var/width = max(0, distance - 1)
		for(var/offset in -width to width)
			var/turf/open/T = null
			if(dx)
				T = locate(start.x + (dx * distance), start.y + offset, start.z)
			else if(dy)
				T = locate(start.x + offset, start.y + (dy * distance), start.z)
			if(!istype(T, /turf/open)) continue

			apply_holy_to_tile(T, per_tile_volume)
			addtimer(CALLBACK(src, .proc/cleanup_puddle_at, T, 3), 2)
			tiles_touched++

	var/cost = tiles_touched * per_tile_volume * 0.5
	return min(total_amt, cost)

/// Aim the cone by user facing; bless impact tile too
/datum/reagent/water/holywater/proc/handle_cone_splash(mob/living/user, turf/open/impact_turf, total_amt)
	var/facing = user ? user.dir : NORTH
	if(!user)
		// If no user, try to infer a facing from nearby living (fallback)
		var/mob/living/closest = null
		var/closest_dist = 999
		for(var/mob/living/L in range(3, impact_turf))
			var/di = get_dist(impact_turf, L)
			if(di < closest_dist)
				closest = L; closest_dist = di
		if(closest) facing = get_dir(closest, impact_turf)

	// Always bless the impact tile
	apply_holy_to_tile(impact_turf, min(6, total_amt))
	addtimer(CALLBACK(src, .proc/cleanup_puddle_at, impact_turf, 3), 2)

	// Fan forward
	var/amt_to_consume = cone_spread_from(user, impact_turf, facing, total_amt)
	return amt_to_consume

/// Chem system turf reactions: bless + cleanup
/datum/reagent/water/holywater/reaction_turf(turf/open/T, reac_volume)
	..()
	if(!istype(T)) return
	apply_holy_to_tile(T, reac_volume)
	addtimer(CALLBACK(src, .proc/cleanup_puddle_at, T, 3), 2)
	return

/// Mobs: still harms the “unholy”; otherwise light blessing if splashed
/datum/reagent/water/holywater/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	if(!istype(M)) return
	..()
	if(is_unholy_creature(M))
		handle_unholy_reaction(M, method, reac_volume)
	else
		handle_default_blessing(M, method, reac_volume)

/// Unholy suffering
/datum/reagent/water/holywater/proc/handle_unholy_reaction(mob/living/M, method, reac_volume)
	var/damage_mult = 1.0
	switch(method)
		if(TOUCH)  damage_mult = 0.5
		if(INGEST) damage_mult = 2.0
		if(INJECT) damage_mult = 3.0
	var/dmg = reac_volume * damage_mult * blessing_strength
	M.take_overall_damage(0, dmg)
	if(dmg > 5) M.emote("scream")
	if(prob(30 + reac_volume))
		M.apply_status_effect(/datum/status_effect/holy_weakness)

/// Mild comfort to the clean (kept minimal)
/datum/reagent/water/holywater/proc/handle_default_blessing(mob/living/M, method, reac_volume)
	if(method == TOUCH)
		var/effective = max(40, reac_volume)
		var/heal_amt = round(effective * 0.3 * blessing_strength)
		M.heal_overall_damage(heal_amt, heal_amt)
		if(prob(10 + effective))
			M.apply_status_effect(/datum/status_effect/holy_protection)
		M.apply_status_effect(/datum/status_effect/holy_resistance)

/// Small hydration bump stays
/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NOHUNGER))
			H.adjust_hydration(hydration + 3)

// ---------- Hyōtan (ritual gourd) – SPLASH uses cone ----------
/obj/item/reagent_containers/glass/ritual/hyotan_holywater
	name = "consecrated hyōtan"
	desc = "A lacquered gourd flask bound with braided cord. It sloshes with sanctified water."
	icon = 'modular/kaizoku/icons/mapset/frontierjustice32.dmi'
	icon_state = "shiitake"
	spillable = TRUE
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/water/holywater = 70)

/obj/item/reagent_containers/glass/ritual/hyotan_holywater/attack_obj(obj/target, mob/living/user)
	if(user && user.used_intent && user.used_intent.type == INTENT_SPLASH && reagents && reagents.total_volume)
		var/turf/hit_turf = get_turf(target)
		var/used = reagents.splash_at_cone_if_holy(hit_turf, user)
		if(used > 0)
			user.visible_message(
				span_danger("[user] fans consecrated water from [src] across [target]!"),
				span_notice("I fan consecrated water from [src] across [target].")
			)
			playsound(hit_turf, pick('sound/foley/water_land1.ogg','sound/foley/water_land2.ogg','sound/foley/water_land3.ogg'), 100, FALSE)
			return
	return ..()

/obj/item/reagent_containers/glass/ritual/hyotan_holywater/attack_turf(turf/T, mob/living/user)
	if(spillable && reagents && reagents.total_volume && user && user.used_intent && user.used_intent.type == INTENT_SPLASH)
		var/turf/newT = T
		while(istype(T, /turf/closed) && newT != user.loc)
			newT = get_step(newT, get_dir(newT, user.loc))
		var/used = reagents.splash_at_cone_if_holy(newT, user)
		if(used > 0)
			user.visible_message(
				span_notice("[user] splashes a cone of holy water from [src] onto \the [newT]!"),
				span_notice("I splash a cone of holy water from [src] onto \the [newT].")
			)
			playsound(newT, pick('sound/foley/water_land1.ogg','sound/foley/water_land2.ogg','sound/foley/water_land3.ogg'), 100, FALSE)
			return
	return ..()

// ---------- Optional statuses (unchanged from your prior block) ----------
/atom/movable/screen/alert/status_effect/buff/holy_protection
	name = "Holy Protection"
	desc = "A gentle radiance wards you."
	icon_state = "holy_protection"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'

/datum/status_effect/holy_protection
	id = "holy_protection"
	alert_type = /atom/movable/screen/alert/status_effect/buff/holy_protection
	effectedstats = null
	duration = 45 SECONDS

/atom/movable/screen/alert/status_effect/buff/holy_resistance
	name = "Holy Resistance"
	desc = "Consecrated vigor flows through you."
	icon_state = "holy_resistance"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'

/datum/status_effect/holy_resistance
	id = "holy_resistance"
	alert_type = /atom/movable/screen/alert/status_effect/buff/holy_resistance
	effectedstats = null
	duration = 120 SECONDS

/atom/movable/screen/alert/status_effect/debuff/holy_weakness
	name = "Holy Weakness"
	desc = "Sanctity sears your profane form."
	icon_state = "holy_weakness"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'

/datum/status_effect/holy_weakness
	id = "holy_weakness"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/holy_weakness
	effectedstats = list("strength" = -2, "endurance" = -2, "speed" = -1)
	duration = 30 SECONDS

// ---------- Blessed Edge (enchantment scaffold) ----------
/datum/enchantment/abyss_blessed_edge
	enchantment_name = "Blessed Edge"
	examine_text = span_info("This weapon is washed in thalassic rites; it bites deep into demons.")
	random_enchantment_weight = 0  // not random; apply via ritual
	var/list/last_proc = list()

/datum/enchantment/abyss_blessed_edge/on_hit(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!isliving(target)) return
	var/mob/living/L = target
	if(!is_demon_mob(L)) return

	// 'Ignore resistance' effect: add a kicker and control effects.
	// (This supplements your normal damage pipeline.)
	L.adjustBruteLoss(rand(6, 10))
	if(prob(25))
		L.Stun(20)
	if(prob(40))
		if(istype(L, /mob/living/carbon))
			var/mob/living/carbon/C = L
			C.IgniteMob()
	L.visible_message("<span class='danger'>Blessed steel bites into [L]!</span>", "<span class='userdanger'>Consecrated metal scorches within me!</span>")
	return
*/
