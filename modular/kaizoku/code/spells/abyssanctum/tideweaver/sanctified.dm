// ===================================================================
// TIDEWAVER ESTUARY
// ICE/WATER-BASED SPELLS, FOCUS ON BEING AGGRESSIVE AND DEALING DAMAGE.
// THE BAROTRAUMA BIND IS THE MOST DANGEROUS KIND.
// ===============================================================================================================
// PURIFYING FILTER, PROJECTILE. BAD AGAINST 'NORMALS', WORSE AGAINST 'PURE', EFFICIENT AGAINST IMPURES, TIER 1
// ================================================================================================================

/datum/action/cooldown/spell/purify
	name = "~SANCTIFIED SPIKE~"
	desc = "Spear of the great depth's cold bringing frozen judgement to the impure. Non-functional against pure beings."
	button_icon_state = "spell0"
	background_icon = 'icons/mob/actions/roguespells.dmi'
	background_icon_state = "spell0"
	button_icon = 'modular/kaizoku/icons/misc/spells.dmi'
	button_icon_state = "spell0"
	sound = 'sound/magic/magic_nulled.ogg'
	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy
	required_items = list(/obj/item/clothing/neck/psycross/silver/abyssanctum)
	invocation_type = INVOCATION_NONE
	cast_range = 7
	charge_required = FALSE
	cooldown_time = 10 SECONDS
	spell_cost = 25

/datum/action/cooldown/spell/purify/cast(atom/cast_on)
	. = ..()
	var/turf/aim_turf
	if(isturf(cast_on))
		aim_turf = cast_on
	else if(ismob(cast_on))
		aim_turf = get_turf(cast_on)
	else
		return
	if(get_dist(get_turf(owner), aim_turf) > cast_range)
		return
	var/obj/projectile/magic/purify/P = new(get_turf(owner))
	P.firer = owner
	P.fired_from = src
	var/dir = get_dir(get_turf(owner), aim_turf)
	P.fire(dir2angle(dir))


/obj/projectile/magic/purify
	name = "purification"
	icon_state = "icespikeproj"
	icon = 'modular/kaizoku/icons/misc/spells.dmi'
	paralyze = 50
	damage = 0
	range = 7
	hitsound = 'sound/blank.ogg'
	nondirectional_sprite = TRUE
	impact_effect_type = /obj/effect/temp_visual/icespikeproj_projectile_impact

/obj/effect/temp_visual/icespikeproj_projectile_impact
	name = "purifying spike"
	icon = 'modular/kaizoku/icons/misc/spells.dmi'
	icon_state = "icespikeproj_break"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 3

/obj/projectile/magic/purify/on_hit(atom/target, blocked = FALSE)
	var/ret = ..(target, blocked)
	if(!target)
		return ret
	if(!isliving(target))
		return ret
	if(!iscarbon(target))
		target.visible_message("<span class='danger'>[target]'s body is being crushed!</span>", "<span class='userdanger'>I feel a suffocating pressure building on my body!</span>")
		var/mob/living/L1 = target
		L1.adjustFireLoss(rand(20, 35))
		L1.apply_status_effect(/datum/status_effect/debuff/frostbite)
		L1.flash_fullscreen("whiteflash3")
		return ret
	var/mob/living/carbon/C = target
	if(C.mob_biotypes & MOB_SPIRIT)
		C.visible_message("<span class='info'>An otherworldly divine freeze encircles [target], filtering out their very existence!</span>", "<span class='notice'>My breath shallows- my ears rings, my senses overwhelmed with the crushing grip! I'M GOING TO IMPLODE FROM INSIDE OUT! PLEASE MERCY!</span>")
		C.adjustFireLoss(rand(50, 100))
		C.Knockdown(40)
		C.Paralyze(1)
		C.apply_status_effect(/datum/status_effect/debuff/frostbite)
		C.flash_fullscreen("whiteflash3")
		return ret
	if((islist(C.faction) && (FACTION_ORCS in C.faction)) || (C.dna.species?.id == "tiefling") || (HAS_TRAIT(C, TRAIT_NASTY_EATER)))
		C.visible_message("<span class='danger'>[target]'s body is distorted by the crushing force of the abyssal waters!</span>", "<span class='userdanger'>I feel the suffocating pressure of the deep crushing my lungs!</span>")
		C.adjustFireLoss(rand(30, 50))
		C.Knockdown(20)
		C.Paralyze(1)
		C.apply_status_effect(/datum/status_effect/debuff/frostbite)
		C.flash_fullscreen("whiteflash3")
		return ret
	if(C.dna.species?.id == "abyssariad" || C.dna.species?.id == "aasimar")
		C.visible_message("<span class='danger'>[target]'s body shivers slightly, yet remains sturdy.</span>", "<span class='userdanger'>A cold travel down my spine, yet I feel little to no pain.</span>")
		C.adjustBruteLoss(rand(5, 15))
		return ret
	C.visible_message("<span class='danger'>[target]'s body is being crushed!</span>", "<span class='userdanger'>I feel a suffocating pressure building on my body!</span>")
	C.adjustFireLoss(rand(20, 35))
	C.flash_fullscreen("whiteflash3")
	return ret
