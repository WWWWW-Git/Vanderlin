/datum/action/cooldown/spell/aoe/diseased_hand
	name = "Diseased Hand"
	desc = "Unleash Zizo's diseased curse in an area, poisoning and slowing all enemies while sparing fellow Zizo followers."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "diseased_hand"
	sound = 'sound/magic/churn.ogg'

	spell_type = SPELL_MANA
	antimagic_flags = MAGIC_RESISTANCE
	associated_skill = /datum/skill/magic/arcane
	required_items = list(/obj/item/clothing/head/wizhat/witch)

	invocation = "ZIZO'S DISEASED HAND!"
	invocation_type = INVOCATION_SHOUT

	click_to_activate = FALSE
	charge_required = FALSE
	cooldown_time = 35 SECONDS
	spell_cost = 15

	aoe_radius = 4
	max_targets = 0

/datum/action/cooldown/spell/aoe/diseased_hand/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isliving(victim))
		return
	var/mob/living/living_victim = victim
	if(istype(living_victim.patron, /datum/patron/inhumen/zizo)) //Other followers are not cursed.
		return

	living_victim.apply_status_effect(/datum/status_effect/diseased_hand, 45 SECONDS)
	living_victim.visible_message(span_danger("[living_victim] is afflicted by Zizo's curse!"), span_userdanger("You feel Zizo's foul disease spreading through your body!"))
