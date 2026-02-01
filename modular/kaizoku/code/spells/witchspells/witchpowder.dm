/datum/action/cooldown/spell/pointed/witch_powder
	name = "Witch Powder"
	desc = "Restore mana by using a corpse for mana rapture."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "placeholder"
	sound = 'sound/magic/churn.ogg'

	spell_type = SPELL_MANA
	antimagic_flags = MAGIC_RESISTANCE
	associated_skill = /datum/skill/magic/arcane
	required_items = list(/obj/item/clothing/head/wizhat/witch)

	invocation = "SOUL'S ESSENCE, RELEASE!"
	invocation_type = INVOCATION_SHOUT

	cast_range = 7
	charge_required = FALSE
	cooldown_time = 60 SECONDS
	spell_cost = 30

/datum/action/cooldown/spell/pointed/witch_powder/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(istype(cast_on, /mob/living))
		var/mob/living/L = cast_on
		if(L.stat == DEAD)
			return TRUE
	return FALSE

/datum/action/cooldown/spell/pointed/witch_powder/cast(atom/cast_on)
	. = ..()
	if(istype(cast_on, /mob/living))
		var/mob/living/L = cast_on
		if(L.stat == DEAD)
			var/mob/living/target = cast_on
			// Create the rupture
			new /obj/effect/temp_visual/mana_rupture(target.loc)
			// Perhaps consume the body or something
			target.visible_message(span_danger("The body of [target] ruptures, releasing a cloud of ethereal energy!"))
			// qdel(target) // Removed to keep corpse

/obj/effect/temp_visual/mana_rupture
	name = "mana rupture"
	desc = "A swirling cloud of magical energy that restores mana."
	icon = 'icons/effects/effects.dmi' // Assume
	icon_state = "magicm"
	duration = 30 SECONDS
	var/heal_amount = 5 // Per tick
	var/heal_delay = 2 SECONDS

/obj/effect/temp_visual/mana_rupture/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, PROC_REF(delete_self)), duration)

/obj/effect/temp_visual/mana_rupture/process()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.mana_pool)
			H.mana_pool.adjust_mana(heal_amount)
			to_chat(H, span_notice("You feel your magical energies replenished."))

/obj/effect/temp_visual/mana_rupture/proc/delete_self()
	qdel(src)
