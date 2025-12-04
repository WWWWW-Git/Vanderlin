/datum/action/cooldown/spell/barotrauma
	name = "~BAROTRAUMA~"
	desc = "Encases a target in a pocket dimension similar to the abyss. For Abyssor's faithful, it is an shield."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "spell0"
	sound = 'sound/magic/magic_nulled.ogg'

	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy
	required_items = list(/obj/item/clothing/neck/psycross/silver/abyssanctum)

	invocation_type = INVOCATION_NONE

	cast_range = 8
	charge_time = 5 SECONDS
	cooldown_time = 2 MINUTES
	spell_cost = 100

/datum/action/cooldown/spell/barotrauma/cast(atom/cast_on)
	. = ..()
	if(!cast_on)
		to_chat(owner, span_warning("<span class='userdanger'>Your spell fails to take hold, victimless.</span>"))
		return FALSE

	if(isliving(cast_on))
		var/mob/living/L = cast_on
		if(!L.has_status_effect(/datum/status_effect/abyssaltomb))
			L.apply_status_effect(/datum/status_effect/abyssaltomb)
			L.visible_message("<span class='warning'>[L] is sealed within a pocket dimension!</span>")
		else
			to_chat(owner, span_warning("<span class='userdanger'>Your target is already immobilized within the pocket dimension!</span>"))
		return TRUE

	if(isturf(cast_on))
		var/turf/open/T = cast_on
		if(!isclosedturf(T))
			T.apply_ice_turf()
			to_chat(owner, "<span class='warning'>Without a target, the ground becomes victim of the abyssal oppression.</span>")
			return TRUE
		to_chat(owner, "<span class='warning'>There is no space for a proper icespyre or cold to be settled.</span>")
		return FALSE

	to_chat(owner, span_warning("<span class='userdanger'>Your spell fails to take hold, victimless.</span>"))
	return FALSE

/turf/open/proc/apply_ice_turf()
	var/prev_icon_state = icon_state
	icon_state = "ice"
	density = FALSE
	MakeSlippery(TURF_WET_PERMAFROST, min_wet_time = 100, wet_time_to_add = 5)
	spawn(100)
		if(icon_state == "ice")
			icon_state = prev_icon_state
			density = initial(density)
