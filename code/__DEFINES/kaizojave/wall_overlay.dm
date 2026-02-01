GLOBAL_LIST_EMPTY(wall_overlay_objects)

GLOBAL_LIST_INIT(wall_overlay_junctions, list(
	0, 1, 4, 5, 8, 9, 12, 13, 21, 29, 137, 141, 157
))

/proc/get_wall_overlay_object(icon_path, overlay_state, junction, alpha = 255, pixel_x = 0, pixel_y = 0, plane = FRILL_PLANE)
	. = GLOB.wall_overlay_objects["[icon_path]-[overlay_state]-[junction]-[alpha]-[pixel_x]-[pixel_y]-[plane]"]
	if(.)
		return
	var/mutable_appearance/mut_appearance = mutable_appearance(icon_path, overlay_state, ABOVE_MOB_LAYER, plane, alpha)
	mut_appearance.pixel_x = pixel_x
	mut_appearance.pixel_y = pixel_y
	return GLOB.wall_overlay_objects["[icon_path]-[overlay_state]-[junction]-[alpha]-[pixel_x]-[pixel_y]-[plane]"] = mut_appearance
