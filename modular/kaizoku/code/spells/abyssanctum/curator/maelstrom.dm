// ====================================================================================================
// The Maelstrom, VERY dangerous bastard. You better cast that one and RUN the HELL away. - TIER 3
// ====================================================================================================

/datum/action/cooldown/spell/maelstrom
	name = "~MAELSTROM RAGE~"
	desc = "Leave to the spirits to rage, bring your enemies to their depths."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "waterspirit"
	sound = 'sound/magic/whiteflame.ogg'

	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy

	invocation = "THE WINDS OF JUDGMENT DEVOUR THE WICKED!!!"
	invocation_type = INVOCATION_SHOUT

	cast_range = 6
	charge_time = 5 SECONDS
	charge_slowdown = 3
	cooldown_time = 2 MINUTES
	spell_cost = 100

/datum/action/cooldown/spell/maelstrom/cast(atom/cast_on)
	. = ..()
	if(!owner || !cast_on)
		return FALSE

	var/turf/T
	if(isopenturf(cast_on))
		T = cast_on
	else
		T = get_turf(cast_on)
	if(!isturf(T))
		to_chat(owner, span_warning("Choose a location first."))
		return FALSE
	if(isclosedturf(T))
		to_chat(owner, span_warning("The maelstrom needs open ground."))
		return FALSE
	if(get_dist(get_turf(owner), T) > cast_range)
		to_chat(owner, span_warning("Too far away!"))
		return FALSE

	var/obj/structure/maelstrom_warning/GhostMaelstrom = new(T)
	GhostMaelstrom.caster = owner

	spawn(40)
		if(QDELETED(GhostMaelstrom))
			return
		var/turf/center = GhostMaelstrom.loc
		qdel(GhostMaelstrom)

		var/obj/structure/maelstrom/Cyclone = new(center)
		Cyclone.caster = owner
		to_chat(owner, span_info("You summon a raging abyssal maelstrom!"))

	return TRUE

/obj/structure/maelstrom
	name = "Abyssal Maelstrom"
	desc = "... it churns, they said, pulled into the depths under the winds of the Maelstrom. They emerged whole and pure, their corruption gone, one god to another, no more blood fiends .."
	icon = 'modular/kaizoku/icons/misc/spells.dmi'
	icon_state = "whirl"
	density = FALSE
	anchored = TRUE
	max_integrity = 500
	var/mob/living/caster
	var/duration = 80
	var/list/affected_mobs = list()

/obj/structure/maelstrom/Initialize()
	. = ..()
	spawn(1)
		while(duration-- > 0)
			apply_maelstrom_effect()
			sleep(5)

		clean_up()
		qdel(src)

/obj/structure/maelstrom/proc/apply_maelstrom_effect()
	var/turf/center = get_turf(src)

	for(var/mob/living/M in view(5, center))
		if(M.z != center.z || !M.loc)
			continue

		var/dx = center.x - M.x
		var/dy = center.y - M.y
		var/distance = max(abs(dx), abs(dy))

		if(distance > 0)
			var/step_amount = (distance >= 4) ? 2 : 1
			for(var/i in 1 to step_amount)
				step_towards(M, center)

		if(M.loc == center)
			if(!(M in affected_mobs))
				M.adjustBruteLoss(rand(5, 8))
				M.Knockdown(5)
				M.visible_message(span_danger("[M] is battered by the core of the maelstrom and knocked off balance!"))
				affected_mobs |= M
			else
				M.adjustBruteLoss(rand(2, 5))
		else if(get_dist(M, center) <= 1)
			M.adjustBruteLoss(rand(1, 3))

/obj/structure/maelstrom/Destroy()
	clean_up()
	return ..()

/obj/structure/maelstrom/proc/clean_up()
	caster = null
	affected_mobs.Cut()
	affected_mobs = null

/obj/structure/maelstrom_warning
	name = "Condensing Winds"
	desc = "... All that scatter must return as winds does not spiral in wonder. The enkindled will be stripped of impurity, the soul beyond matter.."
	icon = 'modular/kaizoku/icons/misc/spells.dmi'
	icon_state = "whirl"
	density = FALSE
	anchored = TRUE
	alpha = 100
	layer = ABOVE_MOB_LAYER + 1
	var/mob/living/caster
