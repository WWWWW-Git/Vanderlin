/datum/status_effect/debuff/shaken
	id = "shaken"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/shaken
	effectedstats = list("perception" = -3, "intelligence" = -2, "speed" = -2)
	duration = 45 SECONDS

/atom/movable/screen/alert/status_effect/debuff/shaken
	name = "shaken"
	desc = "By the divines! What the hell was that?!"
	icon_state = "shaken"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'

/datum/status_effect/debuff/withdrawal
	id = "withdrawal"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/withdrawal
	effectedstats = list("strength" = -2, "constitution" = -3, "endurance" = -3) //Don't use this during battle. You will weaken yourself.
	duration = 6 MINUTES

/atom/movable/screen/alert/status_effect/debuff/withdrawal
	name = "withdrawal"
	desc = "My body needs time to call my Orcish Heritage."
	icon_state = "withdrawal"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'

/datum/status_effect/buff/recovery
	id = "recovery"
	alert_type = /atom/movable/screen/alert/status_effect/buff/recovery
	effectedstats = null
	duration = 45 SECONDS

/atom/movable/screen/alert/status_effect/buff/recovery
	name = "Recovery"
	desc = "My body weakens to recover from foul wounds."
	icon_state = "recovery"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'

/datum/status_effect/buff/recovery/on_apply()
	. = ..()
	var/mob/living/carbon/H = owner
	if(!H)
		return

	START_PROCESSING(SSfastprocess, src)

/datum/status_effect/buff/recovery/tick()
	var/mob/living/carbon/H = owner

	H.blood_volume = min(H.blood_volume + 10, BLOOD_VOLUME_MAXIMUM)
	H.adjustBruteLoss(-0.5)
	H.adjustFireLoss(-0.5)
	H.adjustOxyLoss(-1)
	H.adjustOrganLoss(ORGAN_SLOT_BRAIN, -5)
	H.adjustCloneLoss(-1)
	H.adjustToxLoss(-1)

/datum/status_effect/buff/recovery/on_remove()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
