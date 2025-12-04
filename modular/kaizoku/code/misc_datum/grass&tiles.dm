// This is Zion's plants. If used on another server, request/credit Zion362.

#define ZION_FRONT SOUTH
#define ZION_BACK  NORTH
#define ZION_BASE_LAYER (BELOW_MOB_LAYER - 0.05) //This remains below mobs.

/obj/effect/ziongrass_cover //This is a self-cleaning cover effect.
	name = ""
	desc = ""
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	var/overlay_icon = null
	var/overlay_state_front = "overlay_state_front"
	var/overlay_state_back  = "overlay_state_back"
	var/has_back_overlay = FALSE
	var/cover_jitter = 1
	var/linger = 6
	var/occupants = 0 //Runtime fixin'
	var/last_frontmost = null

/obj/effect/ziongrass_cover/proc/arm_poll()
	if(QDELETED(src))
		return
	addtimer(CALLBACK(src, PROC_REF(poll)), 3)

/obj/effect/ziongrass_cover/Destroy()
	. = ..()

/obj/effect/ziongrass_cover/proc/on_enter()
	occupants ++
	UpdateAppearance()
	Jiggle()

/obj/effect/ziongrass_cover/proc/on_exit()
	if(occupants > 0)
		occupants --
	if(occupants <= 0)
		addtimer(CALLBACK(src, PROC_REF(try_clear)), linger)

/obj/effect/ziongrass_cover/proc/try_clear()
	if(occupants <= 0)
		qdel(src)

/obj/effect/ziongrass_cover/proc/poll()
	if(occupants > 0)
		UpdateAppearance()
	arm_poll() //It will rearm regardless.

/obj/effect/ziongrass_cover/Initialize()
	. = ..()
	arm_poll()

/obj/structure/flora/ziongrass/Destroy()
	var/list/neighbors = list()
	for(var/d in list(ZION_FRONT, ZION_BACK))
		var/obj/structure/flora/ziongrass/Z = GetZionInDir(d)
		if(Z)
			neighbors += Z
	var/obj/effect/ziongrass_cover/C = FindCover() //Remove any active cover on this turf.
	if(C)
		qdel(C)

	var/turf/T = get_turf(src) //Unregister tile as exit signals.
	if(T)
		UnregisterSignal(T, COMSIG_TURF_ENTERED)
		UnregisterSignal(T, COMSIG_TURF_EXITED)

	for(var/obj/structure/flora/ziongrass/N in neighbors) //Refresh
		if(!QDELETED(N))
			N.RefreshSeam()
	for(var/obj/structure/flora/ziongrass/N in neighbors)
		if(!QDELETED(N))
			addtimer(CALLBACK(N, PROC_REF(RefreshSeam)), 1)
	return ..()

/obj/effect/ziongrass_cover/proc/Frontmostboy() //Refreshing local tiles. Check if there is any ziongrass the south.
	var/turf/T = loc
	if(!T)
		return TRUE
	var/turf/front = get_step(T, ZION_FRONT)
	if(!front)
		return TRUE
	return (locate(/obj/structure/flora/ziongrass) in front) ? FALSE : TRUE

/obj/effect/ziongrass_cover/proc/UpdateAppearance()
	var/is_front = Frontmostboy()
	if(last_frontmost == is_front && icon)
		return
	last_frontmost = is_front

	icon = overlay_icon
	if(is_front)
		icon_state = overlay_state_front
	else
		icon_state = has_back_overlay ? overlay_state_back : overlay_state_front

/obj/effect/ziongrass_cover/proc/Jiggle() //hehe jiggle my obols
	var/ox = pixel_x
	animate(src, pixel_x = ox + cover_jitter, time = 0.5)
	animate(pixel_x = ox - cover_jitter, time = 0.5)
	animate(pixel_x = ox, time = 0.5)

/obj/structure/flora/ziongrass
	name = "Zion grass" //Direct reference to zion362; Credits to the spriter.
	desc = "One of the 362 species of tall grass from Fog Islands. Used by ambushers." //Reference to the '362' from Zion's username.
	icon = 'modular/kaizoku/icons/zionwork/tileset.dmi'
	icon_state = "ziongrass"
	anchored = TRUE
	density = FALSE
	max_integrity = 25 //Tougher to slice.
	attacked_sound = "plantcross"
	destroy_sound = "plantcross"
	debris = list(/obj/item/natural/fibers = 2)

	var/overlay_icon = 'modular/kaizoku/icons/zionwork/tileset.dmi'
	var/overlay_state_front = "overlay_state_front"
	var/overlay_state_back  = "overlay_state_back"
	var/cover_linger = 6
	var/cover_jitter = 1

/obj/structure/flora/ziongrass/Initialize()
	. = ..()
	layer = ZION_BASE_LAYER + (y * 0.0001)
	AddComponent(/datum/component/stepping_on_zion)
	var/turf/T = get_turf(src) //This registers the existing or entering of a player on te turf.
	if(T)
		RegisterSignal(T, COMSIG_TURF_ENTERED, PROC_REF(entered))
		RegisterSignal(T, COMSIG_TURF_EXITED, PROC_REF(exited))

	RefreshSeam()
	NotifyNeighbors()

/obj/structure/flora/ziongrass/Destroy()
	// Just unregister; cover effect cleans itself when occupants drop to 0
	var/turf/T = get_turf(src)
	if(T)
		UnregisterSignal(T, COMSIG_TURF_ENTERED)
		UnregisterSignal(T, COMSIG_TURF_EXITED)
	NotifyNeighbors()
	return ..()

// -------- Seam picking (drives the base icon only) --------
/obj/structure/flora/ziongrass/proc/RefreshSeam()
	var/has_front = HasZionInDir(ZION_FRONT)
	var/has_back  = HasZionInDir(ZION_BACK)
	if(has_front)
		icon_state = has_back ? "ziongrass_seamlesshead" : "ziongrass_seamlessend"
	else
		icon_state = has_back ? "ziongrass_seamless" : "ziongrass"

	// If there is an active cover on this turf, make it refresh now
	var/obj/effect/ziongrass_cover/C = FindCover()
	if(C) C.UpdateAppearance()

/obj/structure/flora/ziongrass/proc/NotifyNeighbors()
	for(var/d in list(ZION_FRONT, ZION_BACK))
		var/obj/structure/flora/ziongrass/Z = GetZionInDir(d)
		if(Z) Z.RefreshSeam()

/obj/structure/flora/ziongrass/proc/GetZionInDir(d)
	var/turf/T = get_step(src, d)
	if(!T)
		return null
	return locate(/obj/structure/flora/ziongrass) in T

/obj/structure/flora/ziongrass/proc/HasZionInDir(d)
	return !!GetZionInDir(d)

// -------- Cover effect helpers --------
/obj/structure/flora/ziongrass/proc/FindCover()
	var/turf/T = get_turf(src)
	if(!T)
		return null
	return locate(/obj/effect/ziongrass_cover) in T

/obj/structure/flora/ziongrass/proc/GetOrCreateCover()
	var/obj/effect/ziongrass_cover/C = FindCover()
	if(C)
		return C

	var/turf/T = get_turf(src)
	if(!T)
		return null
	C = new /obj/effect/ziongrass_cover(T)
	C.overlay_icon = overlay_icon
	C.overlay_state_front = overlay_state_front
	C.overlay_state_back = overlay_state_back
	C.cover_jitter = cover_jitter
	C.linger = cover_linger //First, validates if the BACK OVERLAY exists before trying to use it.
	var/list/ov = icon_states(C.overlay_icon)
	C.has_back_overlay = (C.overlay_state_back in ov)
	C.UpdateAppearance()
	return C

/obj/structure/flora/ziongrass/proc/entered(turf/T, atom/movable/AM)
	SIGNAL_HANDLER
	if(!isliving(AM))
		return
	if(get_turf(AM) != get_turf(src))
		return
	var/obj/effect/ziongrass_cover/C = GetOrCreateCover()
	if(C)
		C.on_enter()

/obj/structure/flora/ziongrass/proc/exited(turf/T, atom/movable/AM)
	SIGNAL_HANDLER
	if(!isliving(AM))
		return
	var/obj/effect/ziongrass_cover/C = FindCover()
	if(C)
		C.on_exit()

/datum/component/stepping_on_zion //This rustles my jimmies. Haha. Sorry Zion, but I had to.
/datum/component/stepping_on_zion/Initialize()
	. = ..()
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED), PROC_REF(Crossed))

/datum/component/stepping_on_zion/proc/Crossed(datum/source, atom/movable/AM)
	var/obj/structure/flora/ziongrass/G = source
	if(!G || QDELETED(G))
		return
	if(!isliving(AM))
		return
	playsound(G.loc, "plantcross", 90, FALSE, -1)
	var/ox = G.pixel_x
	animate(G, pixel_x = ox+1, time = 0.5)
	animate(pixel_x = ox-1, time = 0.5)
	animate(pixel_x = ox,   time = 0.5)

	// If there’s an active cover, give it a little jiggle
	var/obj/effect/ziongrass_cover/C = G.FindCover()
	if(C)
		C.Jiggle()

// Fleshrippers - originals from Kaizoku.
// The idea is, essentially, a persistent brute damage dealer that won't cause bleeding.
// In the future, we will be able to use it to stitch wounds with a better "Less medicine skill-to-effectiveness ratio."
// Won't make a huge different if you have the skill, so in these cases, stick to the standard ways.
// however, may bring infections (when we code these) and it is more difficult to get.
// The tamed version should aid in pest control for plants, without biting people.
// This might have greater importance for 'Divine seeds' systems I've been thinking about.

/obj/item/natural/worms/ant
	name = "Wild fleshripper"
	desc = "Native little creacher that aids in suturing wounds and killing pests. \
	This wild crawler is wild and aggressive."
	icon = 'modular/kaizoku/icons/mapset/florafauna.dmi'
	icon_state = "ant"
	baitpenalty = 0
	isbait = FALSE
	fishloot = null
	embedding = list(
		"embed_chance" = 100,
		"embedded_unsafe_removal_time" = 0,
		"embedded_pain_chance" = 0,
		"embedded_fall_chance" = 0,
		"embedded_bloodloss" = 0,
	)
	var/bite_damage = 5
	var/itch_cooldown = 5 SECONDS
	var/next_msg_time = 0

/obj/item/natural/worms/ant/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/natural/worms/ant/on_embed_life(mob/living/user, obj/item/bodypart/bodypart) //Later on, add "Allergy" perk reaction.
	if(!user || !bodypart)
		return FALSE
	if(world.time >= next_msg_time) //Perhaps later, we will make 'insect sensitive' perk.
		if(bite_damage)
			bodypart.receive_damage(bite_damage, 5) //Small ouchie. Ants ain't well know for killing people.
		var/list/pain_messages = list(
			"ARGH! Something has stung me!",
			"OW! Something bit me!?",
			"GAH! I feel a sharp pain!",
			"ACK! Something's biting into my flesh!",
			"UGH! There's something crawling under my clothes!",
			"OUCH! Sharp teeth digs into my skin!" //Yes. I know it's mandibles, fck off.
		)
		to_chat(user, "<span class='warning'>[pick(pain_messages)]</span>")
		next_msg_time = world.time + itch_cooldown //Exists only to prevent spamming messages
	return FALSE

/obj/structure/anthill
	name = "wild crawler hive"
	desc = "A busy dirt mound filled of wild fleshrippers."
	icon = 'modular/kaizoku/icons/mapset/florafauna.dmi'
	icon_state = "anthill"
	anchored = TRUE
	density = TRUE
	max_integrity = 300 //Make them struggle to break these. Might just make the crawler hive respawn after a day, on the same spot.
	var/ant_radius = 6
	var/ant_chance = 12
	var/ant_cooldown = 40
	var/next_infest_time = 0

/obj/structure/anthill/Initialize()
	. = ..()
	for(var/turf/T in range(ant_radius, src))
		RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(antwalking))

/obj/structure/anthill/Destroy()
	for(var/turf/T in range(ant_radius, src))
		UnregisterSignal(T, COMSIG_ATOM_ENTERED) //When destroyed, unregister this. Otherwise ants will keep on biting.
	return ..()

/obj/structure/anthill/proc/antwalking(turf/source, atom/movable/arrived, atom/old_loc)
	if(world.time < next_infest_time)
		return
	if(!isliving(arrived))
		return

	var/mob/living/carbon/C = arrived
	if(!iscarbon(C))
		return
	//if(C.stat == DEAD || C.blood_volume <= 0) // To:do; Corpses will be EATEN. But "Turf-entered' ain't it."
		//return
	if(C.throwing)
		return
	if(!prob(ant_chance))
		return

	var/list/valid_parts = list()
	for(var/obj/item/bodypart/BP in C.bodyparts)
		if(!BP.skeletonized)
			valid_parts += BP

	if(!length(valid_parts))
		return

	var/obj/item/bodypart/target_part = pick(valid_parts)
	var/obj/item/natural/worms/ant/new_ant = new(C)
	target_part.add_embedded_object(new_ant, silent = TRUE, crit_message = FALSE)

	next_infest_time = world.time + ant_cooldown


// Kaizoku Original; A blood-drainer.
// Similar to the leech, but does not heal at all.
// All it does, is just drains player's blood.
// Found in every grass with low chance - the description gives the idea of it being a invasive species.
// It will just 'disappear' when dropped.
// Cannot be used as bait. Should HOPEFULLY cause diseases in the future.

/obj/item/natural/worms/tick
	name = "tick"
	desc = "Bothersome disease-bringer not native to Fog Islands, perceived as the symbol of the first invasion done by grenzelhoft."
	icon = 'modular/kaizoku/icons/mapset/florafauna.dmi'
	icon_state = "tick"
	baitpenalty = 0
	isbait = FALSE
	fishloot = null
	color = null
	embedding = list(
		"embed_chance" = 100,
		"embedded_unsafe_removal_time" = 0,
		"embedded_pain_chance" = 0,
		"embedded_fall_chance" = 0,
		"embedded_bloodloss" = 0,
	)
	var/blood_succ = 1
	var/itch_chance = 10
	var/itch_cooldown = 25
	var/next_msg_time = 0

/obj/item/natural/worms/tick/on_embed_life(mob/living/user, obj/item/bodypart/bodypart)
	if(!user || !bodypart)
		return FALSE

	var/drain = blood_succ
	if(HAS_TRAIT(user, TRAIT_LEECHIMMUNE))
		drain *= 0.05

	user.blood_volume = max(user.blood_volume - drain, 0)

	if(world.time >= next_msg_time)
		if(prob(itch_chance))
			var/list/itch_messages = list(
				"Your [bodypart.name] itches...",
				"You feel something crawling on your [bodypart.name]...",
				"Your [bodypart.name] feels irritated...",
				"There's an annoying itch on your [bodypart.name]...",
				"Your [bodypart.name] tingles uncomfortably..."
			)
			to_chat(user, "<span class='notice'>[pick(itch_messages)]</span>")
		next_msg_time = world.time + itch_cooldown

	if(user.blood_volume <= 0)
		bodypart.remove_embedded_object(src)
		return TRUE

	return FALSE

/obj/item/natural/worms/tick/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/datum/component/tick_infested
	var/tick_chance = 7
	var/tick_cooldown = 50
	var/next_infest_time = 0

/datum/component/tick_infested/Initialize(chance = 7, cooldown = 50)
	tick_chance = clamp(chance, 0, 100)
	tick_cooldown = max(0, cooldown)
	RegisterSignal(get_turf(parent), COMSIG_ATOM_ENTERED, PROC_REF(antwalking))
	return ..()

/datum/component/tick_infested/Destroy()
	UnregisterSignal(get_turf(parent), COMSIG_ATOM_ENTERED)
	return ..()

/datum/component/tick_infested/proc/antwalking(turf/source, atom/movable/arrived, atom/old_loc)
	if(world.time < next_infest_time)
		return
	if(!isliving(arrived))
		return

	var/mob/living/carbon/C = arrived
	if(!iscarbon(C))
		return
	if(C.stat == DEAD || C.blood_volume <= 0)
		return
	if(C.throwing)
		return

	var/chance_modifier = tick_chance
	switch(C.m_intent)
		if(MOVE_INTENT_RUN)
			chance_modifier = tick_chance * 0.5
		if(MOVE_INTENT_SNEAK)
			chance_modifier = tick_chance * 3.0
		else
			chance_modifier = tick_chance

	if(!prob(chance_modifier))
		return

	var/list/valid_parts = list()
	for(var/obj/item/bodypart/BP in C.bodyparts)
		if(!BP.skeletonized)
			valid_parts += BP

	if(!length(valid_parts))
		return

	var/obj/item/bodypart/target_part = pick(valid_parts)
	var/obj/item/natural/worms/tick/new_tick = new(C)
	target_part.add_embedded_object(new_tick, silent = TRUE, crit_message = FALSE)

	next_infest_time = world.time + tick_cooldown

/obj/structure/flora/grass/plagued/heavy/Initialize() //only used for testing.
	. = ..()
	AddComponent(/datum/component/tick_infested, 12, 45)
