/obj/structure/fluff/kaizoku/statue //Removal of stash
	name = "statue"
	desc = "Statue despicting an Zamurai warrior without portraying its race, the protector of the realm."
	icon = 'modular/kaizoku/icons/monostructures/statues_64x64.dmi'
	icon_state = "zamurai_1"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	blade_dulling = DULLING_BASH
	max_integrity = 300
	dir = SOUTH

/obj/structure/fluff/kaizoku/statue/Initialize()
	. = ..()
	var/static/list/loc_connections = list(COMSIG_ATOM_EXIT = PROC_REF(on_exit))
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/fluff/kaizoku/statue/bullet_act(obj/projectile/P)
	. = ..()
	if(. != BULLET_ACT_FORCE_PIERCE)
		P.handle_drop()
		return BULLET_ACT_HIT

/obj/structure/fluff/kaizoku/statue/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(get_dir(loc, target) == dir)
		return
	return TRUE

/obj/structure/fluff/kaizoku/statue/proc/on_exit(datum/source, atom/movable/leaving, atom/new_location)
	SIGNAL_HANDLER
	if(get_dir(leaving.loc, new_location) == dir)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/fluff/kaizoku/statue/tidy
	icon_state = "zamurai_1_tidy"

/obj/structure/fluff/kaizoku/statue/sword
	icon_state = "zamurai_2"

/obj/structure/fluff/kaizoku/statue/sword/tidy
	icon_state = "zamurai_2_tidy"

/obj/structure/fluff/kaizoku/statue/swordleft
	icon_state = "zamurai_3"

/obj/structure/fluff/kaizoku/statue/swordleft/tidy
	icon_state = "zamurai_3_tidy"

/obj/structure/fluff/kaizoku/statue/ashigaru
	desc = "Statue despicting an Skylancer Shuhen warrior, subordinate of the Zamurai."
	icon_state = "ashigaru_1"

/obj/structure/fluff/kaizoku/statue/retainer
	desc = "Statue despicting an Changeling Muqian Custodian retainer. One beyond the skies, warrior of mazes."
	icon_state = "ashigaru_3"

/obj/structure/fluff/kaizoku/statue/kappa
	desc = "Statue despicting an Undine Linyou retainer, lethal ambusher of the wilds."
	icon_state = "ashigaru_5"

/obj/structure/fluff/kaizoku/statue/jizamurai
	desc = "Statue despicting an Oni Jizamurai, comemoration to those keeping the civilization safe."
	icon_state = "jizamurai_1"

/obj/structure/fluff/kaizoku/statue/warningoni
	desc = "Statue despicting an Oni with an papersheet, something seems to be written."
	icon_state = "oni_warning"

/obj/structure/fluff/kaizoku/statue/ancient
	desc = "Statue despicting an male ancient."
	icon_state = "champion_1"

/obj/structure/fluff/kaizoku/statue/ancient/female
	desc = "Statue despicting an female ancient."
	icon_state = "champion_3"

/obj/structure/fluff/kaizoku/statue/lion //32x32 versions on-forward.
	desc = "Despiction of minor manifestation of balance, guardians that wards off evil spirits, often comes in pairs."
	icon_state = "lion"
	icon = 'modular/kaizoku/icons/monostructures/statues_32x32.dmi'

/obj/structure/fluff/kaizoku/statue/lion/cursed
	desc = "Statue despicting the bottomless curse. The outcome of sinful souls, turned into snakes of infinity."
	icon_state = "thecursed"

/obj/structure/fluff/kaizoku/statue/lion/hooman
	desc = "Despiction of an Human monk, the travelers of the land in search of enlightenment."
	icon_state = "hooman"

/obj/structure/fluff/kaizoku/statue/OnCrafted(dirin, mob/user)
	. = ..()
	for(var/obj/structure/fluff/statue/carving_block in contents)
		dir = carving_block.dir
		qdel(carving_block)
	update_appearance(UPDATE_ICON_STATE)
