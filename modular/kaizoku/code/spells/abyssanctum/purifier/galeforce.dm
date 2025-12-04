// ===================================================================
// PURIFIER ESTUARY
// WIND-BASED SPELLS, FOCUS ON HAVING MORE UTILITY.
// HIGHER SYNERGY WITH WEAPONS AND UNARMED.
// ===================================================================
// GALEFORCE - THROW PEOPLE AROUND - TIER 1
// ===================================================================

/datum/action/cooldown/spell/gale_palm
	name = "~GALEFORCE~"
	desc = "Sacred wind from Abyssor's breath to rebuke the wicked and scatter weapons."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "demonslaying"
	sound = 'sound/magic/magic_nulled.ogg'

	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy
	required_items = list(/obj/item/clothing/neck/psycross/silver/abyssanctum)

	invocation = "By Abyssor, the winds shall tear skies asunder!"
	invocation_type = INVOCATION_SHOUT

	cast_range = 8
	charge_time = 3 SECONDS
	charge_slowdown = 2
	cooldown_time = 15 SECONDS
	spell_cost = 25

/datum/action/cooldown/spell/gale_palm/cast(atom/cast_on)
	. = ..()
	if(!owner || !cast_on)
		return FALSE

	var/turf/T
	if(isopenturf(cast_on))
		T = cast_on
	else
		T = get_turf(cast_on)
	if(!isturf(T))
		to_chat(owner, span_warning("Yeah, that one is not a valid tile."))
		return FALSE
	if(get_dist(get_turf(owner), T) > cast_range)
		to_chat(owner, span_warning("Too far away!"))
		return FALSE

	for(var/mob/living/L in T.contents)
		if(L == owner)
			continue

		var/turf/start = get_turf(owner)
		var/turf/end = get_turf(L)
		if(start && end)
			spawn()
				var/turf/current = start
				while(current != end)
					var/obj/effect/windgust/gust = new(current)
					gust.layer = ABOVE_MOB_LAYER
					QDEL_IN(gust, 2)
					current = get_step_towards(current, end)
					sleep(1)

		var/special = FALSE
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if((islist(H.faction) && (FACTION_ORCS in H.faction)) || (H.mob_biotypes & MOB_UNDEAD))
				special = TRUE

		L.visible_message(span_danger("[L] is struck by the forceful wind!"))

		if(!special)
			var/obj/item/W = L.get_active_held_item()
			if(W)
				var/turf/item_target = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
				L.dropItemToGround(W)
				if(item_target)
					W.throw_at(item_target, 6, 1)
				L.visible_message(span_danger("[W] is ripped from [L]'s hand by the wind!"))

		var/distance = rand(2, 4)
		var/turf/throw_to = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
		if(throw_to)
			L.throw_at(throw_to, distance, 2, owner)

		if(L.cmode)
			if(prob(40))
				L.AdjustKnockdown(rand(1, 2))
				L.visible_message(span_warning("The wind forces [L] to stumble."))
		else
			L.AdjustKnockdown(rand(5, 8))
			L.visible_message(span_danger("[L] is knocked flat!"))

	return TRUE

/obj/effect/windgust
	name = ""
	desc = ""
	icon = 'modular/kaizoku/icons/misc/spells.dmi'
	icon_state = "winds"
	anchored = TRUE
	mouse_opacity = 0
	layer = ABOVE_MOB_LAYER
	blend_mode = BLEND_DEFAULT
	pixel_x = 0
	pixel_y = 0

/obj/effect/windgust/Initialize()
	. = ..()
	animate(src, alpha = 0, time = 5)
	QDEL_IN(src, 6)
