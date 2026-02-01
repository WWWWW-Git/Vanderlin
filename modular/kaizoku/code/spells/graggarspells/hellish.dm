
/datum/action/cooldown/spell/undirected/hellfire
	name = "Hellfire"
	desc = "Unleash... a little portion of the hells..."
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "placeholder"

	spell_type = SPELL_MANA
	// antimagic_flags = MAGIC_RESISTANCE_HOLY

	charge_required = TRUE
	charge_time = 3 SECONDS
	cooldown_time = 30 SECONDS
	spell_cost = 50
	associated_skill = /datum/skill/magic/arcane //Might take 'demonic' or 'holy' here, whatever fits.
	invocation = "BRING THE HELLS! BRING THE ASHES! BRING THE PAIN!"
	invocation_type = INVOCATION_SHOUT

	var/aoe_radius = 2

/datum/action/cooldown/spell/undirected/hellfire/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/living_owner = owner
	if(!living_owner.do_blood_sacrifice())
		return

	var/list/things = list()
	for(var/atom/nearby_thing in range(aoe_radius, owner))
		if(nearby_thing == owner || nearby_thing == owner)
			continue
		if(get_dist(owner, nearby_thing) > aoe_radius)
			continue
		if(!is_valid_target(nearby_thing))
			continue
		things += nearby_thing

	for(var/thing_to_target in things)
		if(isturf(thing_to_target))
			var/turf/T = thing_to_target
			if(T == get_turf(owner))
				continue
			new /obj/effect/oilspill(T)
			T.hotspot_expose(500, 30, 1)
		else if(isliving(thing_to_target))
			var/mob/living/L = thing_to_target
			if(L == owner)
				continue
			L.adjustFireLoss(50)
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			L.visible_message(span_danger("[L] is engulfed in hellfire!"))
