////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/// Note: When adding food items with dummy parents, make sure to add
/// the parent to the exclusion list in code/__HELPERS/unsorted.dm's
/// get_random_food proc.
////////////////////////////////////////////////////////////////////////////////
#define STOP_SERVING_BREAKFAST (15 MINUTES)

/obj/item/reagent_containers/food
	possible_transfer_amounts = list()
	volume = 50	//Sets the default container amount for all food items.
	reagent_flags = INJECTABLE
	resistance_flags = FLAMMABLE
	grid_width = 32
	grid_height = 32
	var/do_random_pixel_offset = TRUE
	var/foodtype = NONE
	var/last_check_time
	var/in_container = FALSE //currently just stops "was bitten X times!" messages on canned food

	/// How palatable is this food for a given social class?
	var/faretype = FARE_NEUTRAL
	/// If false, this will inflict mood debuffs on nobles who eat it without being near a table.
	var/portable = TRUE

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(!mapload && do_random_pixel_offset)
		pixel_x = base_pixel_x + rand(-4, 4)
		pixel_y = base_pixel_y + rand(-4, 4)


/obj/item/reagent_containers/food/proc/checkLiked(fraction, mob/M)
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(foodtype & H.dna.species.toxic_food)
				to_chat(H,"<span class='warning'>Argh! This clearly tastes like poison!</span>")
				H.adjust_disgust(25 + 30 * fraction)
				H.add_stress(/datum/stress_event/disgusting_food, 15 SECONDS)
			// STONEKEEP EDIT
			if(HAS_TRAIT(H, TRAIT_CHANGELING_METABOLISM))
				if(foodtype & MEAT) //If: Meat, short-circuits the rest.
					to_chat(H, "<span class='notice'>The flavor of prey... exquisite.</span>")
					H.adjust_disgust(-5 + -2.5 * fraction)
				else if(foodtype & (GRAIN | VEGETABLES)) //If plant, bad.
					to_chat(H, "<span class='warning'>What is this plant-ridden filth?</span>")
					H.adjust_disgust(25 + 30 * fraction)
				else //Anything else means free game.
					to_chat(H, "<span class='notice'>Edible... but not satisfying.</span>")
				last_check_time = world.time
				return
			last_check_time = world.time


#undef STOP_SERVING_BREAKFAST
