//KAIZOJAVE EDIT

/datum/frill_mask_click_interceptor
	var/is_frill_mask_interceptor = TRUE

/datum/frill_mask_click_interceptor/proc/InterceptClickOn(mob/clicker, params, atom/target)
	if(!target || !isliving(target))
		return FALSE
	if(!ismob(target))
		return FALSE
	var/distance = get_dist(clicker, target)
	if(distance <= 1)
		return TRUE

	return FALSE
