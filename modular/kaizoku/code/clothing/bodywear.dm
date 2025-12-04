
/obj/item/clothing/shirt/robe/shrinekeeper
	name = "shrinekeeper robe"
	desc = "Silk-woven and shimmering like tides at dusk, for those who honors the will of the abyss."
	icon_state = "shrinekeeper"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	icon = 'modular/kaizoku/icons/clothingicon/armor.dmi'
	mob_overlay_icon = 'modular/kaizoku/icons/clothing/armor.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_armor.dmi'
	sleevetype = "shirt"

/obj/item/clothing/shirt/tunic/kimono
	name = "traditional kimono"
	desc = "A front-wrapped garment with long sleeves made from a long, narrow bolt of cloth used as a formal garment by the poor and rich alike."
	icon = 'modular/kaizoku/icons/clothingicon/shirt.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/shirt.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_shirts.dmi'
	icon_state = "kimono"
	item_state = "kimono"
	sleevetype = "shirt"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	boobed = TRUE
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL

/obj/item/clothing/shirt/tunic/kimono/random/Initialize()
	color = pick(GLOB.peasant_dyes)
	..()

/obj/item/clothing/shirt/tunic/kimono/ronin
	color = CLOTHING_RONIN

/obj/item/clothing/shirt/tunic/kimono/dark
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/shirt/tunic/kimono/kabukimono
	color = CLOTHING_KABUKIMONO

/obj/item/clothing/shirt/rags/monkgarb
	name = "monk samue"
	desc = "The samue is the clothing used by Abyssanctum monks engaged on the act of Samu, most proper for those performing temple maintenance and mountain hiking."
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	icon = 'modular/kaizoku/icons/clothingicon/shirt.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/shirt.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_shirts.dmi'
	icon_state = "monkgarb"
	item_state = "monkgarb"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|ARMS|VITALS

/obj/item/clothing/shirt/rags/monkgarb/random/Initialize()
	color = pick(GLOB.peasant_dyes)
	..()

/obj/item/clothing/shirt/rags/monkgarb/tideweaver
	color = CLOTHING_TIDEWEAVER

/obj/item/clothing/shirt/tunic/kamishimo //I know this is actually a Kataginu, but it is know more as 'Kamishimo', even if lacking a Hakama. Because HAKAMA is its own thing here.
	name = "shoulder robe"
	desc = "A formal kimono used by men, a short sleeveless garment made of hemp which usually comes together with a hakama, and worn on top of a kosode or kimono. To use one without cloth underneath, conveys a ronin nature."
	icon = 'modular/kaizoku/icons/clothingicon/shirt.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/shirt.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_shirts.dmi'
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK
	icon_state = "kamishimo"
	item_state = "kamishimo"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|VITALS

/obj/item/clothing/shirt/tunic/kamishimo/random/Initialize()
	color = pick(GLOB.peasant_dyes)
	..()

/obj/item/clothing/shirt/tunic/kamishimo/ronin
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/shirt/tunic/kamishimo/eidolon
	color = CLOTHING_EIDOLON

/obj/item/clothing/shirt/looseshirt
	name = "kimono summer shirt"
	desc = "A summer shirt that goes along with a tobi, used during the hot summers on Fog islands."
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	icon = 'modular/kaizoku/icons/clothingicon/shirt.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/shirt.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_shirts.dmi'
	icon_state = "looseshirt"
	item_state = "looseshirt"
	boobed = TRUE
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|ARMS|VITALS

/obj/item/clothing/shirt/looseshirt/Initialize()
	color = pick(GLOB.peasant_dyes)
	..()

/obj/item/clothing/shirt/looseshirt/shinobi
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/shirt/looseshirt/dragonslayer
	resistance_flags = FIRE_PROOF | ACID_PROOF
	color = CLOTHING_WINESTAIN_RED

/obj/item/clothing/shirt/rags/tribal
	name = "tribal garbs"
	desc = "Tribal clothings made from plant fiber commonly used by Undine tribesmen."
	icon = 'modular/kaizoku/icons/clothingicon/shirt.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/shirt.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_shirts.dmi'
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	icon_state = "tribalgarb"
	item_state = "tribalgarb"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|VITALS

/obj/item/clothing/shirt/robe/wizard/guardian
	name = "stormcaller's warfare garb"
	desc = "The garbs used by Abyssariad magicians during times of warfare, holding the marks of Abyssor upon the cloth."
	icon_state = "abyssaltunic"
	icon = 'modular/kaizoku/icons/clothingicon/shirt.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/shirt.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_shirts.dmi'
	boobed = TRUE
	flags_inv = HIDEBOOB
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	allowed_sex = list(MALE, FEMALE)
	allowed_race = list("human", "tiefling", "aasimar", "abyssariad")
	color = null
	sellprice = 100

/obj/item/clothing/shirt/robe/wizard/guardian/black
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/shirt/robe/wizard/guardian/random/Initialize()
	color = pick_assoc(GLOB.noble_dyes)
	..()

/obj/item/clothing/shirt/robe/wizard/guardian/tideweaver
	name = "tideweaver onmyoji's warfare garb"
	desc = "The garbs used by Abyssariad magicians during times of warfare. Marked in yellow for the mountainous magicians and monks who praises Abyssor's thunders."
	color = CLOTHING_TIDEWEAVER

/obj/item/clothing/shirt/robe/wizard/guardian/purifier
	name = "purifier onmyoji's warfare garb"
	desc = "The garbs used by Abyssariad magicians during times of warfare.  Marked in light blue for the expeditionary magicians and monks of Abyssanctum's faith, long married to the seas."
	color = CLOTHING_PURIFIER

/obj/item/clothing/shirt/robe/wizard/guardian/curator
	name = "curator onmyoji's warfare garb"
	desc = "The garbs used by Abyssariad magicians during times of warfare. Marked in red for the soilgazers of Abyssanctum's faith, those bent in ensuring no plague shall reach their blessed islands. "
	color = CLOTHING_CURATOR

/obj/item/clothing/shirt/kaizoku/robe
	slot_flags = ITEM_SLOT_ARMOR
	name = "loose abyssal garb"
	desc = "Casual abyssariad garbs usually used by magicians, or those living on the frigid, treacherous mountains on the edges of the Fog islands."
	icon_state = "loosetunic"
	icon = 'modular/kaizoku/icons/clothingicon/shirt.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/shirt.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_shirts.dmi'
	boobed = TRUE
	flags_inv = HIDEBOOB
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	allowed_sex = list(MALE)
	allowed_race = list("human", "tiefling", "aasimar", "abyssariad")
	color = null

/obj/item/clothing/shirt/kaizoku/robe/Initialize()
	color = pick(GLOB.peasant_dyes)
	..()

/obj/item/clothing/armor/gambeson/heavy/battleshirt
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	name = "custodian battleshirt"
	desc = "Expensive layered silks quilted together. Fashionable and eases identification as part of the custodian retinue."
	icon_state = "battleshirt"
	icon = 'modular/kaizoku/icons/clothingicon/shirt.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/shirt.dmi'
	sleeved = 'modular/kaizoku/icons/helpers/sleeves_shirts.dmi'
