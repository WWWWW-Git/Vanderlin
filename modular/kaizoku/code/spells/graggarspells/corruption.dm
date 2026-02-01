/datum/action/cooldown/spell/pointed/corruption
	name = "Graggar Corruption"
	desc = "Create Graggarious entity, spawning demonic entities."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "placeholder"
	sound = 'sound/magic/churn.ogg'

	spell_type = SPELL_MANA
	antimagic_flags = MAGIC_RESISTANCE
	associated_skill = /datum/skill/magic/arcane
	required_items = list(/obj/item/clothing/head/wizhat/witch)

	invocation = "GRAGGAR, WATCH ME!"
	invocation_type = INVOCATION_SHOUT

	cast_range = 7
	charge_required = FALSE
	cooldown_time = 30 SECONDS
	spell_cost = 20

	var/list/spawned_tendrils = list()
	var/list/spawned_tentacles = list()

/datum/action/cooldown/spell/pointed/corruption/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(istype(cast_on, /obj/structure/flora/newbranch))
		return TRUE
	if(isturf(cast_on))
		return TRUE
	if(istype(cast_on, /mob/living))
		var/mob/living/L = cast_on
		if(L.stat == DEAD)
			return TRUE
	return FALSE

/datum/action/cooldown/spell/pointed/corruption/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/living_owner = owner
	if(!living_owner.do_blood_sacrifice())
		return
	if(istype(cast_on, /obj/structure/flora/newbranch))
		new /obj/structure/fauna/mindsmiter(cast_on.loc) //Spawn Mindsmiter
		return
	if(isturf(cast_on))
		if(length(spawned_tendrils) < 2) //Check Tendrils before spawning it
			var/obj/structure/demon/tendril/T = new /obj/structure/demon/tendril(cast_on)
			spawned_tendrils += T
			RegisterSignal(T, COMSIG_PARENT_QDELETING, PROC_REF(on_tendril_destroyed))
		else if(length(spawned_tentacles) < 5)
			var/obj/structure/demon/tentacle/T = new /obj/structure/demon/tentacle(cast_on)
			spawned_tentacles += T
			RegisterSignal(T, COMSIG_PARENT_QDELETING, PROC_REF(on_tentacle_destroyed))
		return
	if(istype(cast_on, /mob/living))
		var/mob/living/L = cast_on
		if(L.stat == DEAD)
			new /mob/living/simple_animal/hostile/demon/goonpack/sinful2(cast_on.loc)
			return

/datum/action/cooldown/spell/pointed/corruption/proc/on_tendril_destroyed(obj/structure/demon/tendril/T)
	spawned_tendrils -= T

/datum/action/cooldown/spell/pointed/corruption/proc/on_tentacle_destroyed(obj/structure/demon/tentacle/T)
	spawned_tentacles -= T
