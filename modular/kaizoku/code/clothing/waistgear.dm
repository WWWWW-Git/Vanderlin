// =================================================================
// ========================	STORAGE	===============================

/obj/item/storage/belt/kaizoku/leather/daisho
	name = "daisho belt"
	desc = "A oil-boiled reinforced silk or leather belt used by Abyssariads for practicing Daisho."
	icon_state = "daisho"
	sellprice = 5
	icon = 'modular/kaizoku/icons/clothingicon/belts.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/belts.dmi'

/obj/item/storage/belt/kaizoku/leather/daisho/random/Initialize()
	color = pick(GLOB.peasant_dyes)
	..()

/obj/item/storage/belt/kaizoku/leather/daisho/ninja/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/fogdart(src)
	new /obj/item/reagent_containers/food/snacks/fogdart(src)
	new /obj/item/weapon/tetsubishi(src)

/obj/item/storage/belt/kaizoku/leather/daisho/tideweaver
	name = "tideweaver daisho belt"
	color = CLOTHING_TIDEWEAVER

/obj/item/storage/belt/kaizoku/leather/daisho/purifier
	name = "purifier daisho belt"
	color = CLOTHING_PURIFIER

/obj/item/storage/belt/kaizoku/leather/daisho/curator
	name = "curator daisho belt"
	color = CLOTHING_CURATOR

/obj/item/storage/backpack/satchel/ninja/PopulateContents()
	new /obj/item/grenade/smoke_bomb(src)
	new /obj/item/grenade/smoke_bomb/poison(src)
	new /obj/item/throwing_star/ninja(src)

/obj/item/storage/belt/kaizoku/leather/pursebelt
	name = "pursebelt"
	desc = "Cloth wrap that curls under the pants with some exposed purses. It is kept hidden for aesthestic sake."
	icon_state = "hiddensash"
	sellprice = 5
	alternate_worn_layer = DAMAGE_LAYER
	icon = 'modular/kaizoku/icons/clothingicon/belts.dmi'
	mob_overlay_icon ='modular/kaizoku/icons/clothing/belts.dmi'
