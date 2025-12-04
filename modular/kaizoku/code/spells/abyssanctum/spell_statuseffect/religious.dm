/datum/status_effect/abyssaltomb //Abyssor-followers should instantly break away from this coffin.
	id = "abyssor_frozen"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	examine_text = "You've been frozen within an abyssal tomb."
	alert_type = /atom/movable/screen/alert/status_effect/frozen
	var/obj/structure/abyssaltomb/tomb
	var/attempts = 0 // special feature that increases difficulty with each failed struggle attempt against the ice coffin. Or that's what I intended for it to be.

/atom/movable/screen/alert/status_effect/frozen
	name = "Abyssal Submission"
	desc = "Imprisoned by frozen tides, beneath the deep blue."
	icon_state = "intomb"
	icon = 'modular/kaizoku/icons/misc/screen_alert.dmi'
