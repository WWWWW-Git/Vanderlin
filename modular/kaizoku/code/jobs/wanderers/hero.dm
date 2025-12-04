/datum/advclass/combat/sk/abyss/hero //Ashigaru/Civilian role.
	name = "Heroic Spirit"
	tutorial = "Young, rootless and unseen by lords, an unlikely hero, yet marked pure by Abyssor's gaze. \
	They stand upon graves too vast to count, the smallest soul weighing heaviest on the Tide of Fate. \
	Clad as peasants, they perceive corruption where others are blind, calling the world to account where villains hide."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(
	"Humen",
	"Changeling",
	"Skylancer",
	"Ogrun",
	"Undine")
	outfit = /datum/outfit/job/sk/adventurer/abyss/hero
	category_tags = list(CTAG_ADVENTURER)
	pickprob = 100

// The idea for the "Hero class" is actually quite simple.
// The Little hero is an archetype of adventurers whom starts with unique, 'weaker' equipments and no skills
// they do NOT have any degree of political presence, and are essentially civilians,
// Young and VERY poor, but capable nonetheless due to sheer determination alone. This will allow them to train 3x faster.
// but they fill the gap with special perk unique for the archetype, together with array of options.
// They do not have the powerful perks of rare adventurers, or the capacity to be villains.
// But they have an array of unique perks that fits on the 'heroic trope', such as "Second Wind" and "True Hero"
// They are supposed to be all tied to one single wanderer type.
// Certain abyssanctum rituals will perceive them as pure souls.
// Antags may target them specifically, since they are genuine threats that can identify enemies even under disguise.
//
// TL:DR; Protagonist role that starts from the rock bottom.

// Hemosteel (Kaizoku) or Bog Iron (Foreigner): Shingane & Kawagane for the Islanders, made of Kaizoku's congulated blood.
// Found on the island. Bog Iron can be found by panning, like it is on Vintage Story.

// Crucible steel, or 'Bulat Steel', is a popular foglander steel alloy used to replace the impure hemosteel or bog iron.
// You can only find these steel by raiding or expedition outside of Fog islands. This include the 'Colony' map, that is the safest
// and proper for miners, non-combat roles. Raiders will go somewhere else that is richer, but dangerous (Zybantine coastline)

// Ferrophage > "Mythril"; Parasite with crystal-like structure. Strong as Crucible steel, but way lighter.
// Only found on dungeons, risky, requires defeating one of the demonic deep dwellers.
// The metal is actually a 'pus-like' substance, a reward from Kaizoku to whoever killed the cancer harming the island.

// Adamantine VS Black Steel - Kaizoku people use the Magatama, Adamantine, Kaizoku's kidney stones for its religious and resistance values.
// The smell of 'Kaizoku urine', from the kidney stones, repels enemies, proper for a demon-eating animal to bring fear to demons like so.
