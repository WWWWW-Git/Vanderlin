//Merge this with kaizojave wall.dm file later.
/obj/structure/table/kaizojave/low_wall
	name = "base class low wall"
	plane = WALL_PLANE
	desc = "Abandon Psydon RIGHT NOW"
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/compatibility/table.dmi'
	icon_state = "low-0"
	base_icon_state = "low"
	max_integrity = 1000
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ
	smoothing_groups = list(SMOOTH_GROUP_kaizojave_LOW_WALL)
	canSmoothWith = list(SMOOTH_GROUP_kaizojave_LOW_WALL)
	anchored = TRUE
	climbable = TRUE
	climb_offset = 10

/obj/structure/table/kaizojave/low_wall/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_SMOOTHING)
	QUEUE_SMOOTH_NEIGHBORS(src)
	return INITIALIZE_HINT_NORMAL

/obj/structure/table/kaizojave/low_wall/update_icon()
	. = ..()
	if(smoothing_flags & SMOOTH_BITMASK)
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/table/kaizojave/low_wall/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if(mover.throwing)
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE

/obj/structure/table/kaizojave/low_wall/CanAStarPass(ID, dir, requester)
	. = !density
	if(ismovableatom(requester))
		var/atom/movable/mover = requester
		. = . || (mover.pass_flags & PASSTABLE)

/obj/structure/table/kaizojave/low_wall/attackby(obj/item/I, mob/user, params)
	if(user.cmode)
		return ..()
	return TRUE

/obj/structure/table/kaizojave/low_wall/metal
	name = "low metal wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/metal.dmi'

/obj/structure/table/kaizojave/low_wall/metal/rust
	name = "low rusted metal wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rustmetal.dmi'

/obj/structure/table/kaizojave/low_wall/wood
	name = "low wood wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/wood.dmi'

/obj/structure/table/kaizojave/low_wall/wood/fresh
	name = "low fresh log wall"
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/woodfresh.dmi'

/obj/structure/table/kaizojave/low_wall/scrap
	name = "low scrap wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrap.dmi'

/obj/structure/table/kaizojave/low_wall/scrap/white
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapwhite.dmi'

/obj/structure/table/kaizojave/low_wall/scrap/red
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapred.dmi'

/obj/structure/table/kaizojave/low_wall/scrap/blue
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/scrapblue.dmi'

/obj/structure/table/kaizojave/low_wall/concrete
	name = "low concrete wall"
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/concrete.dmi'

/obj/structure/table/kaizojave/low_wall/adobe
	name = "low adobe wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/adobe.dmi'

/obj/structure/table/kaizojave/low_wall/siding
	name = "low sided wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding.dmi'

/obj/structure/table/kaizojave/low_wall/siding/blue
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_blue.dmi'

/obj/structure/table/kaizojave/low_wall/siding/blue/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_SMOOTHING)

/obj/structure/table/kaizojave/low_wall/siding/red
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_red.dmi'

/obj/structure/table/kaizojave/low_wall/siding/red/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_SMOOTHING)

/obj/structure/table/kaizojave/low_wall/siding/green
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/siding_green.dmi'

/obj/structure/table/kaizojave/low_wall/siding/green/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_SMOOTHING)

/obj/structure/table/kaizojave/low_wall/prison
	name = "low sided wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/drought/prison.dmi'

/obj/structure/table/kaizojave/low_wall/brick
	name = "low brick wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brick.dmi'

/obj/structure/table/kaizojave/low_wall/brick/alt
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brickalt.dmi'

/obj/structure/table/kaizojave/low_wall/brick/gray
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/brickgray.dmi'

/obj/structure/table/kaizojave/low_wall/reinforced
	name = "base class low reinforced wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/compatibility/table.dmi'

/obj/structure/table/kaizojave/low_wall/reinforced/metal
	name = "low reinforced metal wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rmetal.dmi'

/obj/structure/table/kaizojave/low_wall/reinforced/metal/rust
	name = "rusted low reinforced metal wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/rrustmetal.dmi'
	base_icon_state = "reinforced_rust_low"

/obj/structure/table/kaizojave/low_wall/reinforced/bunker
	name = "low bunker wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/bunker.dmi'

/obj/structure/table/kaizojave/low_wall/sewer
	name = "low sewer wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/sewer.dmi'

/obj/structure/table/kaizojave/low_wall/vault
	name = "low vault wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_wall.dmi'

/obj/structure/table/kaizojave/low_wall/vault/rust
	name = "low vault wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/vault_wall_rust.dmi'

/obj/structure/table/kaizojave/low_wall/dungeon
	name = "low reinforced bunker wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_1.dmi'

/obj/structure/table/kaizojave/low_wall/dungeon/rust
	name = "low reinforced bunker wall"
	desc = ""
	icon = 'code/__DEFINES/kaizojave/placeholder_icons/turf/walls/dungeon_rust_1.dmi'

