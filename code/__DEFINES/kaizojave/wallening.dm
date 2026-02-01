#ifndef is_type_in_typecache
#define is_type_in_typecache(A, L) (A && length(L) && L[(ispath(A) ? A : A:type)])
#endif

/datum/keybinding/client/toggle_frills_over_floors
	hotkey_keys = list("Ctrl+Alt+F")
	name = "toggle_frills_over_floors"
	full_name = "Toggle Frills over Floors"
	description = "Toggles the Frill-over-Floors preference"
	keybind_signal = COMSIG_KB_CLIENT_MINIMALHUD_DOWN

/datum/keybinding/client/toggle_frills_over_floors/down(client/user)
	. = ..()
	if(. || !user.prefs)
		return
	if(length(user?.screen))
		var/atom/movable/screen/plane_master/frill/frill = locate(/atom/movable/screen/plane_master/frill) in user.screen
		frill.backdrop(user.mob)
	return TRUE

GLOBAL_LIST_INIT(default_connectables, typecacheof(list(
	)))

GLOBAL_LIST_INIT(lower_priority_connectables, typecacheof(list(
	)))

/atom/proc/auto_align(connectables_typecache, lower_priority_typecache)
	if(manual_align)
		return
	if(!connectables_typecache)
		connectables_typecache = GLOB.default_connectables
	if(!lower_priority_typecache)
		lower_priority_typecache = GLOB.lower_priority_connectables

	var/list/dirs_usable = GLOB.cardinals.Copy()
	var/list/dirs_secondary_priority = GLOB.cardinals.Copy()
	for(var/dir_to_check in GLOB.cardinals)
		var/turf/turf_to_check = get_step(src, dir_to_check)
		if(turf_to_check.density)
			dirs_usable -= dir_to_check
			continue
		for(var/atom/movable/thing_to_check in turf_to_check)
			if(is_type_in_typecache(thing_to_check, connectables_typecache))
				dirs_usable -= dir_to_check
				break
			if(is_type_in_typecache(thing_to_check, lower_priority_typecache))
				dirs_secondary_priority -= dir_to_check

	var/dirs_avalible = length(dirs_usable)
	if(dirs_avalible <= 2 && dirs_avalible != 0)
		dir = dirs_usable[1] //Just take the first dir avalible
		return
	dirs_usable &= dirs_secondary_priority
	dirs_avalible = length(dirs_usable)
	if(dirs_avalible <= 2 && dirs_avalible != 0)
		dir = dirs_usable[1]
		return
