/turf/closed/wall/kaizojave
	uses_integrity = TRUE
	name = "base class wall"
	desc = "Abyssor is with us"
	icon_state = "wall-0"
	base_icon_state = "wall"
	baseturfs = /turf/open/floor/dirt/road
	wallclimb = TRUE
	explosion_block = 10
	hardness = 7
	blade_dulling = DULLING_BASHCHOP
	max_integrity = 700
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_KAIZOJAVE_WALL)
	canSmoothWith = list(SMOOTH_GROUP_KAIZOJAVE_WALL)
	smoothing_list = null
	above_floor = /turf/open/floor/blocks
	var/last_event = 0
	var/active = null
	var/low_wall_type = null
	var/wall_variety = null
	var/door_height = 0
	var/window_height = 0

/turf/closed/wall/kaizojave/examine()
	. += ..()
	if(uses_integrity)
		var/healthpercent = (atom_integrity / max_integrity) * 100
		switch(healthpercent)
			if(75 to 99)
				. += "It shows only minor wear on the surface."
			if(50 to 74)
				. += "Its structure looks moderately damaged."
			if(25 to 49)
				. += "It appears severely damaged."
			if(1 to 24)
				. += "<span class='warning'>It's on the verge of collapse!</span>"

/turf/closed/wall/kaizojave/Initialize(mapload)
	. = ..()
	if(uses_integrity && max_integrity)
		atom_integrity = max_integrity

	if(frill_icon)
		if(!check_suppress_frill_for_doors_windows())
			AddElement(/datum/element/frill, frill_icon)
		QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src) //Queues to neighboors.

	var/turf/north_turf = get_step(src, NORTH)
	if(north_turf && istype(north_turf, /turf/closed/wall/kaizojave))
		var/turf/closed/wall/kaizojave/north_wall = north_turf
		if(north_wall.frill_icon)
			north_wall.RemoveElement(/datum/element/frill, north_wall.frill_icon)
		QUEUE_SMOOTH(north_wall)
	if(low_wall_type) //IF SUITABLE, spawns a low_wall on the floor above.
		var/turf/above_turf = get_step_multiz(src, UP)
		if(above_turf && !istype(above_turf, /turf/open/transparent/openspace))
			var/has_low_wall = FALSE
			for(var/obj/structure/table/kaizojave/low_wall/existing in above_turf)
				has_low_wall = TRUE
				break
			if(!has_low_wall)
				new low_wall_type(above_turf)
	return INITIALIZE_HINT_NORMAL

/turf/closed/wall/kaizojave/proc/check_suppress_frill_for_doors_windows()
	var/turf/south_turf = get_step(src, SOUTH)
	if(!south_turf)
		return FALSE
	if(istype(south_turf, /turf/closed/wall/kaizojave)) //Supress walls south if it exists.
		return TRUE
	for(var/obj/structure/door/kaizojave/door in south_turf) //Same for doors and windows.
		return TRUE
	for(var/obj/structure/window/kaizojave/window in south_turf)
		return TRUE

	return FALSE

/turf/closed/wall/kaizojave/bitmask_smooth()
	var/new_junction = NONE

	for(var/direction in GLOB.cardinals)
		SET_ADJ_IN_DIR(src, new_junction, direction, direction)

	var/found_ns_bridge = FALSE
	for(var/ns_direction in list(NORTH, SOUTH))
		var/turf/adjacent_turf = get_step(src, ns_direction)
		if(!adjacent_turf)
			continue
		var/has_ns_door_window = FALSE
		for(var/obj/structure/door/kaizojave/door in adjacent_turf)
			if(door.door_orientation in list(NORTH, SOUTH))
				has_ns_door_window = TRUE
				break
		if(!has_ns_door_window)
			for(var/obj/structure/window/kaizojave/window in adjacent_turf)
				if(window.window_orientation in list(NORTH, SOUTH))
					has_ns_door_window = TRUE
					break

		if(has_ns_door_window)
			var/turf/beyond = get_step(adjacent_turf, ns_direction)
			if(istype(beyond, /turf/closed/wall/kaizojave))
				found_ns_bridge = TRUE
				break

	if(found_ns_bridge)
		new_junction |= (NORTH | SOUTH)

	if(new_junction & NORTH)
		if(new_junction & WEST)
			SET_ADJ_IN_DIR(src, new_junction, NORTHWEST, NORTHWEST_JUNCTION)
		if(new_junction & EAST)
			SET_ADJ_IN_DIR(src, new_junction, NORTHEAST, NORTHEAST_JUNCTION)

	if(new_junction & SOUTH)
		if(new_junction & WEST)
			SET_ADJ_IN_DIR(src, new_junction, SOUTHWEST, SOUTHWEST_JUNCTION)
		if(new_junction & EAST)
			SET_ADJ_IN_DIR(src, new_junction, SOUTHEAST, SOUTHEAST_JUNCTION)

	set_smoothed_icon_state(new_junction)

/turf/closed/wall/kaizojave/proc/apply_frill_cover_overlay()
	if(!frill_icon)
		return
	var/mutable_appearance/cover = mutable_appearance(frill_icon, "frill_coverup", ABOVE_MOB_LAYER, FRILL_PLANE)
	cover.appearance_flags = RESET_COLOR | RESET_ALPHA
	cover.pixel_x = 0
	cover.pixel_y = 16
	cut_overlay(cover)
	add_overlay(cover)

/turf/closed/wall/kaizojave/proc/remove_frill_cover_overlay()
	if(!frill_icon)
		return
	var/mutable_appearance/cover = mutable_appearance(frill_icon, "frill_coverup", ABOVE_MOB_LAYER, FRILL_PLANE)
	cover.appearance_flags = RESET_COLOR | RESET_ALPHA
	cut_overlay(cover)

/turf/closed/wall/kaizojave/kaizoku
	name = "kaizoku wall"
	desc = ""
	icon = 'modular/kaizoku/icons/tileset/newwallset/shoji.dmi'
	frill_icon = 'modular/kaizoku/icons/tileset/newwallset/shoji_frill.dmi'
	wall_variety = "wood"
	low_wall_type = /obj/structure/table/kaizojave/low_wall/kaizoku
	climbdiff = 3
	explosion_block = 4
	hardness = 7
	burn_power = 100
	spread_chance = 1.8
	blade_dulling = DULLING_BASHCHOP
	max_integrity = 1100
	break_sound = 'sound/combat/hits/onwood/destroywalldoor.ogg'
	attacked_sound = list('sound/combat/hits/onwood/woodimpact (1).ogg','sound/combat/hits/onwood/woodimpact (2).ogg')
	above_floor = /turf/open/floor/ruinedwood
	baseturfs = /turf/open/floor/ruinedwood
	door_height = 0
	window_height = 0

/obj/structure/table/kaizojave/low_wall/kaizoku
	name = "kaizoku ceiling"
	desc = ""
	icon = 'modular/kaizoku/icons/tileset/newwallset/shoji.dmi'

// WARNING!!! THESE WALLS BELOW ARE TEMPORARY, ONLY!!! THEY WILL BE REMOVED
// AT A LATER STAGE OF DEVELOPMENT!!!

/turf/closed/wall/kaizojave/metal
	name = "metal wall"
	desc = "A sturdy metal wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/metal.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/metal_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/metal

/turf/closed/wall/kaizojave/metal/rust
	name = "rusted metal wall"
	desc = "A metal wall rusted with age."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rustmetal.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rustmetal_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/metal/rust

/turf/closed/wall/kaizojave/wood
	name = "log wall"
	desc = "A rustic log wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/wood.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/wood_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/wood

/turf/closed/wall/kaizojave/wood/fresh
	name = "fresh log wall"
	desc = "A somewhat freshly made log wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/woodfresh.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/woodfresh_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/wood/fresh

/turf/closed/wall/kaizojave/scrap
	name = "scrap wall"
	desc = "A wall made of scrap metal."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrap.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrap_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/scrap

/turf/closed/wall/kaizojave/scrap/white
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapwhite.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapwhite_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/scrap/white

/turf/closed/wall/kaizojave/scrap/red
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapred.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapred_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/scrap/red

/turf/closed/wall/kaizojave/scrap/blue
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapblue.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapblue_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/scrap/blue

/turf/closed/wall/kaizojave/siding
	name = "sided wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/siding

/turf/closed/wall/kaizojave/siding/Initialize()
	var/state = rand(1,3)
	switch(state)
		if(1)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_1.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_1_frill.dmi'
		if(2)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_2.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_2_frill.dmi'
		if(3)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_3.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_3_frill.dmi'
	. = ..()

/turf/closed/wall/kaizojave/siding/blue
	name = "sided wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/siding/blue

/turf/closed/wall/kaizojave/siding/blue/Initialize()
	var/state = rand(1,4)
	switch(state)
		if(1)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue_1.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue_1_frill.dmi'
		if(2)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue_2.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue_2_frill.dmi'
		if(3)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue_3.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue_3_frill.dmi'
		if(4)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue_frill.dmi'
	. = ..()

/turf/closed/wall/kaizojave/siding/green
	name = "sided wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/siding/green

/turf/closed/wall/kaizojave/siding/green/Initialize()
	var/state = rand(1,4)
	switch(state)
		if(1)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green_1.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green_1_frill.dmi'
		if(2)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green_2.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green_2_frill.dmi'
		if(3)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green_3.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green_3_frill.dmi'
		if(4)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green_frill.dmi'
	. = ..()

/turf/closed/wall/kaizojave/siding/red
	name = "sided wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/siding/red

/turf/closed/wall/kaizojave/siding/red/Initialize()
	var/state = rand(1,4)
	switch(state)
		if(1)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red_1.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red_1_frill.dmi'
		if(2)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red_2.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red_2_frill.dmi'
		if(3)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red_3.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red_3_frill.dmi'
		if(4)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red_frill.dmi'
	. = ..()

/turf/closed/wall/kaizojave/prison
	name = "prison wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/prison

/turf/closed/wall/kaizojave/prison/Initialize()
	var/state = rand(1,3)
	switch(state)
		if(1)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison_1.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison_1_frill.dmi'
		if(2)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison_2.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison_2_frill.dmi'
		if(3)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison_3.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison_3_frill.dmi'
	. = ..()

/turf/closed/wall/kaizojave/brick
	name = "brick wall"
	desc = "A brick wall. Try banging your head against this."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brick.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brick_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/brick

/turf/closed/wall/kaizojave/brick/alt
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brickalt.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brickalt_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/brick/alt

/turf/closed/wall/kaizojave/brick/gray
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brickgray.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brickgray_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/brick/gray

/turf/closed/wall/kaizojave/metal/reinforced
	name = "reinforced metal wall"
	desc = "A heavy duty, reinforced metal wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rmetal.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rmetal_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/reinforced/metal

/turf/closed/wall/kaizojave/metal/reinforced/industrial
	desc = "A reinforced metal wall with some patches of rust."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rusty_industrial.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rusty_industrial_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/reinforced/metal

/turf/closed/wall/kaizojave/metal/reinforced/rust
	name = "rusted reinforced metal wall"
	desc = "A rusty but still quite sturdy reinforced metal wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rrustmetal.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rrustmetal_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/reinforced/metal/rust

/turf/closed/wall/kaizojave/concrete
	name = "concrete wall"
	desc = "A tough concrete wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/concrete.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/concrete_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/concrete

/turf/closed/wall/kaizojave/concrete/alt
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/concretealt.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/concretealt_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/concrete

/turf/closed/wall/kaizojave/sewer
	name = "sewer wall"
	desc = "A sewer wall. Gross."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/sewer.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/sewer_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/sewer

/turf/closed/wall/kaizojave/bunker
	name = "bunker wall"
	desc = "A bunker wall. Serious business."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/bunker.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/bunker_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/reinforced/bunker

/turf/closed/indestructible/kaizojave/metal
	name = "metal wall"
	desc = "A sturdy metal wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/metal.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/metal_frill.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_KAIZOJAVE_WALL)
	smoothing_list = list(SMOOTH_GROUP_KAIZOJAVE_WALL)

/turf/closed/indestructible/kaizojave/comb
	name = "comb wall"
	desc = "Honeybeast comb, lining the walls. They subtly drip a substance."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/comb.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/comb_frill.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_KAIZOJAVE_WALL)
	smoothing_list = list(SMOOTH_GROUP_KAIZOJAVE_WALL)

/turf/closed/wall/kaizojave/vault
	name = "vault wall"
	desc = "A secure vault wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_wall.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_wall_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/vault

/turf/closed/wall/kaizojave/vault/vent
	name = "vent section"
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_vent.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_vent_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/vault

/turf/closed/wall/kaizojave/vault/rust
	name = "rusted vault wall"
	desc = "A rusted vault wall."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_wall_rust.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_wall_rust_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/vault/rust

/turf/closed/wall/kaizojave/vault/rust/vent
	name = "rusted vent section"
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_vent_rust.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_vent_rust_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/vault/rust

/turf/closed/wall/kaizojave/dungeon
	name = "reinforced bunker wall"
	desc = "A reinforced bunker wall. The pinnacle of pre-war engineering."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_1.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_1_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/dungeon

/turf/closed/wall/kaizojave/dungeon/Initialize()
	var/state = rand(1,4)
	switch(state)
		if(1)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_1.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_1_frill.dmi'
		if(2)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_2.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_2_frill.dmi'
		if(3)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_3.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_3_frill.dmi'
		if(4)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_4.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_4_frill.dmi'
	. = ..()

/turf/closed/wall/kaizojave/dungeon/rust
	name = "rusted reinforced bunker wall"
	desc = "A rusted reinforced bunker wall. Still stands strong."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_1.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_1_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/dungeon/rust

/turf/closed/wall/kaizojave/dungeon/rust/Initialize()
	var/state = rand(1,4)
	switch(state)
		if(1)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_1.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_1_frill.dmi'
		if(2)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_2.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_2_frill.dmi'
		if(3)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_3.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_3_frill.dmi'
		if(4)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_4.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_4_frill.dmi'
	. = ..()

/turf/closed/wall/kaizojave/craftable/scrap
	name = "crude scrap wall"
	desc = "A crude wall made of scrap metal. This looks very recently constructed."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/roughscrap.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/roughscrap_1_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/scrap

/turf/closed/wall/kaizojave/craftable/scrap/Initialize()
	var/state = rand(1,3)
	switch(state)
		if(1)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/roughscrap_2.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/roughscrap_2_frill.dmi'
		if(2)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/roughscrap_3.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/roughscrap_3_frill.dmi'
		if(3)
			icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/roughscrap.dmi'
			frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/roughscrap_1_frill.dmi'
	. = ..()

/turf/closed/wall/kaizojave/craftable/wood
	name = "crude log wall"
	desc = "A freshly made, crude log wall. This looks very recently constructed."
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/woodfresh.dmi'
	frill_icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/woodfresh_frill.dmi'
	low_wall_type = /obj/structure/table/kaizojave/low_wall/wood/fresh

/obj/structure/girder/kaizojave
	name = "base class wall support"
	desc = "No more girder spam, circa mojave sun - 2021"
	can_displace = FALSE
	girderpasschance = 100
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/girder.dmi'
