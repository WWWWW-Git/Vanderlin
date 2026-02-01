/atom/movable/screen/plane_master/openspace_backdrop
	name = "open space backdrop plane master"
	plane = OPENSPACE_BACKDROP_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	alpha = 255

/atom/movable/screen/plane_master/openspace
	name = "open space plane master"
	plane = OPENSPACE_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	alpha = 255

/atom/movable/screen/plane_master/openspace/Initialize(mapload)
	. = ..()
	add_filter("z_level_blur", 1, list(type = "blur", size = 0.75))
	add_filter("first_stage_openspace", 2, drop_shadow_filter(color = "#04080FAA", size = -10))
	add_filter("second_stage_openspace", 3, drop_shadow_filter(color = "#04080FAA", size = -15))
	add_filter("third_stage_openspace", 4, drop_shadow_filter(color = "#04080FAA", size = -20))
	add_filter("fourth_stage_openspace", 5, drop_shadow_filter(color = "#04080FAA", size = -25))
	add_filter("fifth_stage_openspace", 6, drop_shadow_filter(color = "#04080FAA", size = -30))
	add_filter("sixth_stage_openspace", 7, drop_shadow_filter(color = "#04080FAA", size = -35))
	add_filter("seventh_stage_openspace", 8, drop_shadow_filter(color = "#04080FAA", size = -40))

/atom/movable/screen/plane_master/transparent
	name = "transparent plane master"
	plane = TRANSPARENT_FLOOR_PLANE
	appearance_flags = PLANE_MASTER

/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/over_tile
	name = "over tile world plane master"
	plane = OVER_TILE_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/wall
	name = "wall plane master"
	plane = WALL_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/wall/backdrop(mob/mymob)
	. = ..()
	if(!mymob)
		CRASH("Plane master backdrop called without a mob attached.")

/atom/movable/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world/backdrop(mob/mymob)
	. = ..()
	remove_filter("AO")

/atom/movable/screen/plane_master/game_world_fov_hidden
	name = "game world fov hidden plane master"
	plane = GAME_PLANE_FOV_HIDDEN
	render_relay_plane = GAME_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world_fov_hidden/Initialize()
	. = ..()
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = FIELD_OF_VISION_BLOCKER_RENDER_TARGET, flags = MASK_INVERSE))

/atom/movable/screen/plane_master/game_world_upper
	name = "upper game world plane master"
	plane = GAME_PLANE_UPPER
	render_relay_plane = GAME_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world_upper_fov_hidden
	name = "upper game world fov hidden plane master"
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	render_relay_plane = GAME_PLANE_FOV_HIDDEN
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world_above
	name = "above game world plane master"
	plane = ABOVE_GAME_PLANE
	render_relay_plane = GAME_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/field_of_vision_blocker
	name = "field of vision blocker plane master"
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	render_target = FIELD_OF_VISION_BLOCKER_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = null
