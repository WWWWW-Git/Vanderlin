// ===================================================================
// CURATOR ESTUARY
// LIGHTENING-BASED SPELLS, FOCUS ON SUPPORTIVE BUT NOT HEALING.
// CAN PRACTICE REVIVALS, DOES NOT DEAL DAMAGE ON THE UNDEAD.
// ===================================================================
// CHAIN OF TORMENT - ATTACK SPELL, TIER 1. YOU'RE LIKELY TO SPARK YOURSELF.
// ===================================================================
/datum/action/cooldown/spell/chain_of_torment
	name = "~CHAIN OF TORMENT~"
	desc = "Abyssor's lash that leaps soul to soul. The pure and impure will join the same suffering."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "chain"
	sound = 'sound/magic/lightning.ogg'

	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy
	required_items = list(/obj/item/clothing/neck/psycross/silver/abyssanctum)

	invocation = "By Abyssor, the winds shall tear skies asunder!"
	invocation_type = INVOCATION_SHOUT

	cast_range = 8
	charge_required = FALSE
	cooldown_time = 20 SECONDS
	spell_cost = 25

/datum/action/cooldown/spell/chain_of_torment/cast(atom/cast_on)
	. = ..()
	if(!owner || !cast_on)
		return FALSE

	var/turf/T = isopenturf(cast_on) ? cast_on : get_turf(cast_on)
	if(!isturf(T))
		return FALSE
	if(get_dist(get_turf(owner), T) > cast_range)
		return FALSE

	var/mob/living/primary
	for(var/mob/living/M in view(1, T))
		primary = M
		break

	if(!primary)
		to_chat(owner, span_warning("No enemy nearby for the bolt!"))
		return FALSE

	chain_lightning(owner, primary, 2)
	to_chat(owner, span_info("A surge of abyssal lightning leaps forward!"))
	return TRUE

/datum/action/cooldown/spell/chain_of_torment/proc/chain_lightning(mob/living/true_caster, mob/living/first_target, max_jumps = 2)
	var/list/affected = list()
	var/mob/living/current = first_target

	for(var/i = 1 to max_jumps + 1)
		if(!current || !isliving(current))
			break

		affected += current
		current.visible_message(span_danger("[current] is struck by surging lightning!"))
		current.adjustFireLoss(rand(15, 30))
		current.Knockdown(10)

		var/turf/start_turf = get_turf(true_caster)
		var/turf/end_turf = get_turf(current)
		if(start_turf && end_turf)
			create_lightning_arc(start_turf, end_turf)
			playsound(end_turf, 'sound/magic/lightning.ogg', 80, TRUE)

		var/mob/living/next
		var/lowest_dist = 999
		for(var/mob/living/N in view(4, current))
			if(N == true_caster || (N in affected))
				continue
			var/d = get_dist(current, N)
			if(d < lowest_dist)
				lowest_dist = d
				next = N

		true_caster = current
		current = next

	if(!current && first_target == true_caster)
		true_caster.visible_message(span_warning("[true_caster] is caught in their own lightning surge!"))
		true_caster.adjustFireLoss(rand(10, 20))
		create_lightning_arc(get_turf(true_caster), get_turf(true_caster))

/datum/action/cooldown/spell/chain_of_torment/proc/create_lightning_arc(turf/start, turf/end)
	if(!start || !end)
		return

	var/dx = end.x - start.x
	var/dy = end.y - start.y
	var/distance = max(abs(dx), abs(dy))
	var/steps = max(1, distance)

	for(var/i = 1 to steps)
		var/step_x = start.x + round((dx * i) / steps)
		var/step_y = start.y + round((dy * i) / steps)
		var/turf/T = locate(step_x, step_y, start.z)
		if(!T)
			continue

		var/obj/effect/temp_visual/lightning/L = new(T)
		L.icon = 'icons/obj/projectiles_tracer.dmi'
		L.icon_state = "stun"
		L.layer = FLY_LAYER
		L.plane = GAME_PLANE_UPPER
		L.duration = 7

		var/angle = arctan(dy, dx)
		L.transform = matrix(angle, MATRIX_ROTATE)
