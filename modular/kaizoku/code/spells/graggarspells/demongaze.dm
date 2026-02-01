/datum/status_effect/buff/demongaze
	duration = 30 SECONDS
	alert_type = null
	var/mob/living/target

/datum/status_effect/buff/demongaze/New(list/arguments)
	if(arguments && arguments.len >= 3)
		src.target = arguments[3]
	. = ..()

/datum/status_effect/buff/demongaze/on_apply()
	. = ..()
	if(!target)
		if(owner)
			to_chat(owner, "This one... hehe... is invalid...")
		return FALSE
	return TRUE

/datum/status_effect/buff/demongaze/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.remoteviewer = FALSE
	H.set_remoteview(null)
	to_chat(owner, "Your eye... stop seeing through [src.target]...")
	owner.visible_message(span_warning("[owner]'s forehead closes."))

/datum/action/cooldown/spell/undirected/demongaze
	name = "Demonic Gaze"
	desc = "Put your eye into someone else's forehead."
	button_icon_state = "infernaleye"

	associated_skill = /datum/skill/magic/arcane // Or appropriate
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "placeholder"
	spell_type = SPELL_MANA
	charge_required = FALSE
	cooldown_time = 30 SECONDS
	spell_cost = 50
	associated_skill = /datum/skill/magic/arcane //Might take 'demonic' or 'holy' here, whatever fits.

/datum/action/cooldown/spell/undirected/demongaze/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/living_owner = owner
	var/mob/living/target = cast_on //First, ensure we have a valid living target.
	if(!isliving(target))
		living_owner.balloon_alert(living_owner, "This is not an target, stupid one.")
		return
	if(target == living_owner)
		living_owner.visible_message(span_warning("You cannot target yourself with Demonic Gaze."))
		return
	if(target.patron?.type == /datum/patron/abyssanctum/tideweaver)
		living_owner.visible_message(span_danger("A searing force recoils into your skull as the gaze is repelled!"))
		living_owner.apply_damage(rand(10, 30), BRUTE, BODY_ZONE_HEAD)
		var/obj/item/bodypart/head_bp = living_owner.get_bodypart(BODY_ZONE_HEAD)
		if(head_bp)
			var/datum/wound/W = new /datum/wound/slash()
			if(W)
				W.apply_to_bodypart(head_bp, FALSE, TRUE)
		living_owner.overlay_fullscreen("painflash", /atom/movable/screen/fullscreen/painflash)
		addtimer(CALLBACK(living_owner, TYPE_PROC_REF(/mob, clear_fullscreen), "painflash"), 3 SECONDS)
		living_owner.apply_status_effect(/datum/status_effect/debuff/frostbite)
		target.visible_message(span_notice("... Demonic influence attempted to take over you, yet, you stand pure."))
		return
	if(!living_owner.do_blood_sacrifice())
		return
	var/mob/living/carbon/human/H = living_owner
	H.remoteview_grace_until = world.time + 1
	H.remoteviewer = TRUE
	H.set_remoteview(target) // Avoids race condition by forcing client perspective
	if(living_owner.client)
		living_owner.client.eye = target
		living_owner.client.perspective = EYE_PERSPECTIVE
	living_owner.visible_message(span_warning("One of your eyes disappears... and appears on the forehead of someone else!"))
	if(isliving(target))
		to_chat(target, span_warning("IT PAINS! An open wound appears on your forehead - AN EYE?!"))
		target.apply_damage(rand(5, 20), BRUTE, BODY_ZONE_HEAD)
		var/obj/item/bodypart/target_head = target.get_bodypart(BODY_ZONE_HEAD)
		if(target_head)
			var/datum/wound/W2
			if(prob(15))
				W2 = new /datum/wound/slash/large()
			else
				W2 = new /datum/wound/slash()
			if(W2)
				W2.apply_to_bodypart(target_head, FALSE, TRUE)
	. = ..()
	var/datum/status_effect/eff = living_owner.apply_status_effect(/datum/status_effect/buff/demongaze, 30 SECONDS, target)
	if(!eff)
		living_owner.visible_message(span_warning("The creature resisted your sight."))
	else
		living_owner.visible_message(span_notice("Your sight pierces through [target]'s skin."))
		call_later(CALLBACK(living_owner, /mob/living/carbon/human/proc/check_demongaze_active), 1)


/datum/action/cooldown/spell/undirected/demongaze/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/recipient_name = browser_input_text(owner, "In need of sight, huh?", "Graggar")
	if(!recipient_name)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(!istext(recipient_name))
		recipient_name = "" + recipient_name
	var/mob/living/target_resolved //Determine the caster mob
	var/mob/living/caster = owner

	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(QDELETED(H))
			continue
		if(caster && H == caster)
			continue
		if(lowertext(H.real_name) == lowertext(recipient_name))
			target_resolved = H
			break
	if(!target_resolved)
		for(var/client/C as anything in GLOB.clients)
			var/mob/living/M = C.mob
			if(QDELETED(M))
				continue
			// don't match the caster
			if(caster && M == caster)
				continue
			if(lowertext(M.real_name) == lowertext(recipient_name))
				target_resolved = M
				break
	if(!target_resolved)
		to_chat(owner, span_warning("I seek a connection, but can't find [recipient_name]."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(target_resolved == caster)
		to_chat(owner, span_warning("You cannot target yourself with this spell."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	src.cast(target_resolved)
	return . | SPELL_CANCEL_CAST
