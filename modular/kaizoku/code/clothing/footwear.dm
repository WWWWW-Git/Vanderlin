/obj/item/clothing/shoes/boots/armor/light/kusaritabi
	name = "chains tabi"
	icon_state = "kusaritabi"
	item_state = "kusaritabi"
	desc = "The riveted chainmail version of the unarmored Tabi footwear."
	icon = 'modular/kaizoku/icons/clothingicon/feet.dmi'
	mob_overlay_icon = 'modular/kaizoku/icons/clothing/feet.dmi'
	sleeved = 'modular/kaizoku/icons/clothing/feet.dmi'

/obj/item/clothing/shoes/boots/armor/suneate
	name = "three-plate greaves"
	desc = "Armored suneate made from steel offering heavy protection against both melee and ranged attacks."
	icon = 'modular/kaizoku/icons/clothingicon/feet.dmi'
	mob_overlay_icon = 'modular/kaizoku/icons/clothing/feet.dmi'
	sleeved = 'modular/kaizoku/icons/clothing/feet.dmi'
	icon_state = "suneate"
	item_state = "suneate"

/obj/item/clothing/shoes/boots/armor/suneate/cursed/Initialize()
	. = ..()
	name = "soulbinded suneate"
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/shoes/boots/jikatabi
	name = "jikatabi"
	desc = "A standard tabi that keeps the toes flexible and healthy, avoiding calluses of long expeditions. However, it looks rather goofy for the non-islanders."
	icon = 'modular/kaizoku/icons/clothingicon/feet.dmi'
	mob_overlay_icon = 'modular/kaizoku/icons/clothing/feet.dmi'
	sleeved = 'modular/kaizoku/icons/clothing/feet.dmi'
	icon_state = "jikatabi"
	item_state = "jikatabi"

/obj/item/clothing/shoes/boots/jikatabi/shinobi
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/shoes/boots/jikatabi/dragontabi
	name = "dragontabi"
	icon_state = "dragontabi"
	item_state = "dragontabi"
	icon = 'modular/kaizoku/icons/clothingicon/feet.dmi'
	mob_overlay_icon = 'modular/kaizoku/icons/clothing/feet.dmi'
	sleeved = 'modular/kaizoku/icons/clothing/feet.dmi'
	desc = "A tabi reinforced in dragon bones and asbestos, making it fire immune. Not very protective against physical damage, but still fairly durable."
	armor = ARMOR_LEATHER_BAD
	max_integrity = INTEGRITY_STRONG
	armor_class = AC_MEDIUM
	body_parts_covered = LEGS|FEET
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/sandals/geta
	name = "geta"
	desc = "A normal wooden geta most suitable for those who need to wander where the mud absorbs pressure."
	icon = 'modular/kaizoku/icons/clothingicon/feet.dmi'
	mob_overlay_icon = 'modular/kaizoku/icons/clothing/feet.dmi'
	sleeved = 'modular/kaizoku/icons/clothing/feet.dmi'
	icon_state = "geta"
	item_state = "geta"

/obj/item/clothing/shoes/shortboots/cloudhead
	name = "cloudhead shoes"
	desc = "A traditional shoes with distinctive upturned toe design that resembles the shape of clouds, to symbolize connection to the skies."
	icon = 'modular/kaizoku/icons/clothingicon/feet.dmi'
	mob_overlay_icon = 'modular/kaizoku/icons/clothing/feet.dmi'
	sleeved = 'modular/kaizoku/icons/clothing/feet.dmi'
	icon_state = "cloudhead_shoes"
	item_state = "cloudhead_shoes"

/obj/item/clothing/shoes/shortboots/cloudhead/kabukimono
	name = "kabuki-maru cloudhead shoes"
	desc = "The same traditional cloudhead shoes of the Abyssariads, but colored in rich yellow tone and with intense implication of being used by a desecrant whom belongs to an armed gang."
	color = "#9b874f"

/obj/item/clothing/shoes/shortboots/cloudhead/toweryakkos
	name = "tower-yakko cloudhead shoes"
	desc = "The same traditional cloudhead shoes of the Abyssariads, but colored in rich purple tone and with intense implication of being used by a desecrant whom belongs to an armed gang."
	color = "#804d97"

/obj/item/clothing/shoes/ridingboots/gutal
	name = "leather gutal"
	desc = "The boots used by Abyssariad cavalry with upturned toes and durable, oil-boiled leather."
	icon_state = "leathergutal"
	item_state = "leathergutal"
	icon = 'modular/kaizoku/icons/clothingicon/feet.dmi'
	mob_overlay_icon = 'modular/kaizoku/icons/clothing/feet.dmi'
	sleeved = 'modular/kaizoku/icons/clothing/feet.dmi'

/obj/item/clothing/shoes/ridingboots/gutal/custodian
	name = "custodian gutal"
	desc = "The very same boots used by the foglanders living on the arid zones of Kaizoku's heart, but branded dark and used for long-term marching rather than cavalry."
	icon_state = "custodiangutal"
	icon_state = "custodiangutal"
