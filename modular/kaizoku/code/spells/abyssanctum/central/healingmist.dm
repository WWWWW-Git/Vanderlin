/datum/action/cooldown/spell/abyssal_heal
	name = "~HEALING MIST~"
	desc = "Releases a mist that heals allies — stronger near water."
	button_icon_state = "purification"
	background_icon = 'icons/mob/actions/roguespells.dmi'
	background_icon_state = "spell0"
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "purification"
	sound = 'sound/magic/heal.ogg'
	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy
	required_items = list(/obj/item/clothing/neck/psycross/silver/abyssanctum)
	invocation_type = INVOCATION_NONE
	cast_range = 7
	charge_required = FALSE
	cooldown_time = 10 SECONDS
	spell_cost = 10

/datum/action/cooldown/spell/abyssal_heal/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return
	var/mob/living/L = cast_on

	if(HAS_TRAIT(L, TRAIT_ATHEISM_CURSE))
		L.visible_message(span_danger("[L] recoils in disgust!"), span_userdanger("These fools are trying to cure me with religion!"))
		L.cursed_freak_out()
		return

	if(L.mob_biotypes & MOB_UNDEAD)
		L.visible_message(span_danger("[L] is lit asunder!"), span_userdanger("I've been lit from a divine source!"))
		L.adjustFireLoss(30)
		L.adjust_divine_fire_stacks(1)
		L.IgniteMob()
		return

	var/healing = 25
	var/bonus = 15

	L.visible_message(span_info("A mist of salt-scented vapour settles on [L]!"), span_notice("I'm invigorated by healing vapours!"))

	var/turf/T = get_turf(L)
	if(istype(T, /turf/open/water) || istype(get_turf(owner), /turf/open/water))
		to_chat(owner, span_notice("Channeling my patron's power is easier in these conditions!"))
		healing += bonus

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		var/obj/item/bodypart/BP = C.get_bodypart(check_zone(owner.zone_selected))
		if(BP)
			BP.heal_damage(healing, healing)
			BP.heal_wounds(healing / 4)
			C.update_damage_overlays()
	else
		L.adjustBruteLoss(-healing)
		L.adjustFireLoss(-healing)

	L.adjustToxLoss(-healing)
	L.adjustOxyLoss(-healing)
