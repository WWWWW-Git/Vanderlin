/datum/action/cooldown/spell/pointed/frog_curse
	name = "Frog Curse"
	desc = "Transform a victim into a helpless frog for a short time."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "frog_curse"
	sound = 'sound/magic/churn.ogg'

	spell_type = SPELL_MANA
	antimagic_flags = MAGIC_RESISTANCE
	associated_skill = /datum/skill/magic/arcane
	required_items = list(/obj/item/clothing/head/wizhat/witch)

	invocation = "You are nothing but a VERMIN!"
	invocation_type = INVOCATION_SHOUT

	cast_range = 7
	charge_required = FALSE
	cooldown_time = 45 SECONDS
	spell_cost = 5

	var/mob/living/simple_animal/hostile/retaliate/frog/frog_type = /mob/living/simple_animal/hostile/retaliate/frog

/datum/action/cooldown/spell/pointed/frog_curse/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return isliving(cast_on)

/datum/action/cooldown/spell/pointed/frog_curse/cast(mob/living/cast_on)
	. = ..()
	if(!cast_on.mind)
		return
	var/mob/living/simple_animal/hostile/retaliate/frog/frog_mob = new frog_type(cast_on.loc)
	frog_mob.faction = list()

	var/datum/status_effect/shapechange_mob/shapechange = frog_mob.apply_status_effect(/datum/status_effect/shapechange_mob, 30 SECONDS, cast_on, FALSE)
	if(!shapechange)
		qdel(frog_mob)
		return

	cast_on.visible_message(span_danger("[cast_on] is cursed by Zizo's magic and transforms into a frog!"), span_userdanger("You feel Zizo's foul magic transform you into a helpless frog!"))
