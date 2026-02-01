//Cursed version of Mojave's frills. Improve at your own risk.

GLOBAL_LIST_EMPTY(frill_objects)

/proc/get_frill_object(icon_path, junction, alpha = 255, pixel_x = 0, pixel_y = 0, plane = FRILL_PLANE, is_modular = FALSE)
	var/icon_state = is_modular ? "frill-[junction]_front" : "frill-[junction]"
	var/cache_key = "[icon_path]-[icon_state]-[junction]-[alpha]-[pixel_x]-[pixel_y]-[plane]"
	. = GLOB.frill_objects[cache_key]
	if(.)
		return
	var/mutable_appearance/mut_appearance = mutable_appearance(icon_path, icon_state, ABOVE_MOB_LAYER, plane, alpha)
	mut_appearance.pixel_x = pixel_x
	mut_appearance.pixel_y = pixel_y
	return GLOB.frill_objects[cache_key] = mut_appearance

/datum/element/frill
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	var/icon_path
	var/last_modular_frill = null

/datum/element/frill/Attach(datum/target, icon_path)
	if(!isturf(target) && !ismovable(target)) // Turfs and movables have vis_contents. Atoms don't. Pain.
		return ELEMENT_INCOMPATIBLE
	. = ..()
	src.icon_path = icon_path

	var/atom/atom_target = target

	on_junction_change(atom_target, atom_target.smoothing_junction)
	RegisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, PROC_REF(on_junction_change))

/datum/element/frill/Detach(turf/target)

	target.cut_overlay(get_frill_object(icon_path, target.smoothing_junction, pixel_y = 32, is_modular = FALSE))
	if(last_modular_frill)
		target.cut_overlay(last_modular_frill)
		last_modular_frill = null
	UnregisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE)
	return ..()


/datum/element/frill/proc/on_junction_change(atom/source, new_junction)
	SIGNAL_HANDLER
	var/turf/turf_or_movable = source
	turf_or_movable.cut_overlay(get_frill_object(icon_path, source.smoothing_junction, pixel_y = 32, is_modular = FALSE)) //cleans up old cached overlays
	if(last_modular_frill)
		turf_or_movable.cut_overlay(last_modular_frill)
		last_modular_frill = null

	turf_or_movable.add_overlay(get_frill_object(icon_path, new_junction, pixel_y = 32, is_modular = FALSE))

	var/turf/south_turf = get_step(turf_or_movable, SOUTH) //This checks if there is the most southmost wall. If there isn't, then we are that wall.
	var/is_frontmost = !south_turf || !istype(south_turf, /turf/closed/wall) //This is used for the 'visible frontmost' frill, which may or may not be filtered out by sight.

	if(is_frontmost)
		// Yes! We are frontmost, now determine the plane based on stacking
		var/modular_plane
		if(new_junction & NORTH)
			modular_plane = FLOAT_LAYER //We have walls behind us? So we're in a stack. Use unfiltered plane.
		else
			modular_plane = FRILL_PLANE //We don't have walls behind us? So we are singular. The frontmost frill will be filtered for sight.
		var/mutable_appearance/mod_app = mutable_appearance(icon_path, "frill-[new_junction]_front", ABOVE_MOB_LAYER, modular_plane, 255)
		mod_app.pixel_y = 32
		last_modular_frill = mod_app
		turf_or_movable.add_overlay(mod_app)


