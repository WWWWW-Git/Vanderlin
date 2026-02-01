/datum/action/cooldown/spell/pointed/hex_of_withering
	name = "Hex of Withering"
	desc = "Hex the target with a curse that weakens the enemy progressively."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "placeholder"
	sound = 'sound/magic/churn.ogg'

	spell_type = SPELL_MANA
	antimagic_flags = MAGIC_RESISTANCE
	associated_skill = /datum/skill/magic/arcane
	required_items = list(/obj/item/clothing/head/wizhat/witch)

	invocation = "ZIZO'S WITHERING HEX!"
	invocation_type = INVOCATION_SHOUT

	cast_range = 7
	charge_required = FALSE
	cooldown_time = 30 SECONDS
	spell_cost = 10

/datum/action/cooldown/spell/pointed/hex_of_withering/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return isliving(cast_on)

/datum/action/cooldown/spell/pointed/hex_of_withering/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/hex_of_withering, 30 SECONDS)
	cast_on.visible_message(span_danger("[cast_on] is afflicted by Zizo's withering hex!"), span_userdanger("You feel Zizo's curse sapping your vitality!"))

/datum/status_effect/hex_of_withering
	id = "hex_of_withering"
	alert_type = /atom/movable/screen/alert/status_effect/hex_of_withering
	status_type = STATUS_EFFECT_MULTIPLE
	var/stacks = 1

/datum/status_effect/hex_of_withering/on_creation(mob/living/new_owner, duration_override)
	. = ..()
	if(.)
		RegisterSignal(owner, COMSIG_HUMAN_LIFE, PROC_REF(on_life))

/datum/status_effect/hex_of_withering/on_apply()
	. = ..()
	owner.adjust_stat_modifier("[REF(src)]", STATKEY_STR, -stacks)
	owner.adjust_stat_modifier("[REF(src)]", STATKEY_CON, -stacks)
	owner.adjust_stat_modifier("[REF(src)]", STATKEY_END, -stacks)

/datum/status_effect/hex_of_withering/on_remove()
	. = ..()
	owner.remove_stat_modifier("[REF(src)]", STATKEY_STR)
	owner.remove_stat_modifier("[REF(src)]", STATKEY_CON)
	owner.remove_stat_modifier("[REF(src)]", STATKEY_END)
	UnregisterSignal(owner, COMSIG_HUMAN_LIFE)

/datum/status_effect/hex_of_withering/proc/on_life()
	if(stacks < 5) // Max 5 stacks
		stacks++
		owner.adjust_stat_modifier("[REF(src)]", STATKEY_STR, -1)
		owner.adjust_stat_modifier("[REF(src)]", STATKEY_CON, -1)
		owner.adjust_stat_modifier("[REF(src)]", STATKEY_END, -1)

/datum/status_effect/hex_of_withering/refresh(duration_override)
	stacks = min(stacks + 1, 5)
	owner.adjust_stat_modifier("[REF(src)]", STATKEY_STR, -1)
	owner.adjust_stat_modifier("[REF(src)]", STATKEY_CON, -1)
	owner.adjust_stat_modifier("[REF(src)]", STATKEY_END, -1)

/datum/status_effect/diseased_hand
	id = "diseased_hand"
	alert_type = /atom/movable/screen/alert/status_effect/diseased_hand
	status_type = STATUS_EFFECT_MULTIPLE
	var/stacks = 1

/datum/status_effect/diseased_hand/on_creation(mob/living/new_owner, duration_override)
	. = ..()
	if(.)
		RegisterSignal(owner, COMSIG_HUMAN_LIFE, PROC_REF(on_life))

/datum/status_effect/diseased_hand/on_apply()
	. = ..()
	owner.adjust_stat_modifier("[REF(src)]", STATKEY_SPD, -stacks)
	owner.adjustBruteLoss(5 * stacks) // Initial damage

/datum/status_effect/diseased_hand/on_remove()
	. = ..()
	owner.remove_stat_modifier("[REF(src)]", STATKEY_SPD)
	UnregisterSignal(owner, COMSIG_HUMAN_LIFE)

/datum/status_effect/diseased_hand/proc/on_life()
	if(stacks < 5) // Max 5 stacks
		stacks++
		owner.adjust_stat_modifier("[REF(src)]", STATKEY_SPD, -1)
		owner.adjustBruteLoss(3) // Ongoing damage

/datum/status_effect/diseased_hand/refresh(duration_override)
	stacks = min(stacks + 1, 5)
	owner.adjust_stat_modifier("[REF(src)]", STATKEY_SPD, -1)
	owner.adjustBruteLoss(5)

/atom/movable/screen/alert/status_effect/hex_of_withering
	name = "Hex of Withering"
	desc = "Zizo's curse saps your vitality!"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'
	icon_state = "shaken"

/atom/movable/screen/alert/status_effect/diseased_hand //Make this have a chance to drop the weapon later
	name = "Diseased Hand"
	desc = "Your hand is diseased!"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'
	icon_state = "shaken"
