/mob/var/image/frill_mask_overlay = null
/mob/var/image/frill_mask_debug = null
/mob/var/frill_mask_signals_set = FALSE

/mob/Login()
	. = ..()
	if(!client)
		return
	if(!frill_mask_overlay)
		frill_mask_overlay = image('code/__DEFINES/kaizojave/placeholder_icons/effects/directionals.dmi', src, "south")
		frill_mask_overlay.plane = FRILL_MASK_PLANE
		frill_mask_overlay.layer = FLOAT_LAYER
		frill_mask_overlay.appearance_flags = NO_CLIENT_COLOR | RESET_COLOR | PASS_MOUSE
		frill_mask_overlay.pixel_x = -112
		frill_mask_overlay.pixel_y = 16
		// Debug overlaY. Remove the comments but DO NOT remove the fill_mask_overlay above!
		/*
		frill_mask_debug = image('code/__DEFINES/kaizojave/placeholder_icons/effects/directionals.dmi', src, "south")
		frill_mask_debug.plane = GAME_PLANE
		frill_mask_debug.layer = FLOAT_LAYER
		frill_mask_debug.color = "#ff00ff"
		frill_mask_debug.alpha = 128
		frill_mask_debug.appearance_flags = RESET_COLOR
		frill_mask_debug.pixel_x = -112
		frill_mask_debug.pixel_y = 16
		*/

	client.images += frill_mask_overlay
	//client.images += frill_mask_debug //This is the debug version. Replace with the one ontop.

	update_frill_mask_direction(src, dir)

	if(!frill_mask_signals_set)
		RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(update_frill_mask_direction))
		frill_mask_signals_set = TRUE

/mob/proc/update_frill_mask_direction(atom/source, new_dir)
	SIGNAL_HANDLER
	if(!frill_mask_overlay)
		return

	var/target_state = "south"
	var/offset_x = 0
	var/offset_y = 0

	switch(new_dir)
		if(NORTH)
			target_state = "north" //Essentially unused. Also wrong offsets.
			offset_x = -104
			offset_y = 16
		if(SOUTH)
			target_state = "south"
			offset_x = -104
			offset_y = -208
		if(EAST)
			target_state = "east"
			offset_x = 0
			offset_y = -112
		if(WEST)
			target_state = "west"
			offset_x = -192
			offset_y = -112

	frill_mask_overlay.icon_state = target_state
	frill_mask_overlay.pixel_x = offset_x
	frill_mask_overlay.pixel_y = offset_y

	if(frill_mask_debug)
		frill_mask_debug.icon_state = target_state
		frill_mask_debug.pixel_x = offset_x
		frill_mask_debug.pixel_y = offset_y

/mob/living/face_atom(atom/A)
	var/olddir = dir
	. = ..()
	if(dir != olddir)
		update_frill_mask_direction(src, dir)

