#define JOB_AVAILABLE 0
#define JOB_UNAVAILABLE_GENERIC 1
#define JOB_UNAVAILABLE_BANNED 2
#define JOB_UNAVAILABLE_PLAYTIME 3
#define JOB_UNAVAILABLE_SLOTFULL 4
#define JOB_UNAVAILABLE_AGE 5
#define JOB_UNAVAILABLE_RACE 6
#define JOB_UNAVAILABLE_SEX 7
#define JOB_UNAVAILABLE_DEITY 8
#define JOB_UNAVAILABLE_QUALITY 9
#define JOB_UNAVAILABLE_PATREON 10
#define JOB_UNAVAILABLE_LASTCLASS 11
#define JOB_UNAVAILABLE_ACCOUNTAGE 12
#define JOB_UNAVAILABLE_JOB_COOLDOWN 13
#define JOB_UNAVAILABLE_RACE_BANNED 14

/* Job datum job_flags */
/// Whether the mob is announced on arrival.
#define JOB_ANNOUNCE_ARRIVAL (1<<0)
/// Whether the mob is added to the crew manifest.
#define JOB_SHOW_IN_CREDITS (1<<1)
/// Whether the mob is equipped through SSjob.EquipRank() on spawn.
#define JOB_EQUIP_RANK (1<<2)
/// Whether this job can be joined through the new_player menu.
#define JOB_NEW_PLAYER_JOINABLE (1<<3)
/// Whether the job can be displayed on the actors list
#define JOB_SHOW_IN_ACTOR_LIST (1<<4)

#define FACTION_NONE		"None"
#define FACTION_NEUTRAL		"Neutral"
#define FACTION_TOWN		"Town"
#define FACTION_FOREIGNERS  "Foreigners"
#define FACTION_MIGRANTS  	"Migrants"
#define FACTION_UNDEAD		"Undead"
#define FACTION_PLANTS		"Plants"
#define FACTION_VINES		"Vines" //Seemingly unused
#define FACTION_CABAL		"Cabal"
#define FACTION_RATS		"Rats"
#define FACTION_ORCS		"Orcs"
#define FACTION_BUMS		"Bums"
#define FACTION_MATTHIOS	"Matthios"

#define FACTION_GOVERNMENT		(1<<0) // Replaces NOBLEMEN
#define FACTION_MILITARY		(1<<1) //Replaces GARRISON
#define FACTION_IMPERIAL		(1<<2) // Replaces COMPANY
#define FACTION_ABYSSANCTUM		(1<<3) //Replaces CHURCHMEN
#define FACTION_MALEFACTORS		(1<<4) ///New addition
#define FACTION_CITIZENS		(1<<5) //Replaces SERFS/PEASANTS/APPRENTICES
#define FACTIONLESS		(1<<6) //Outsiders.
#define FACTION_VILLAIN		(1<<7) //Invaders, antags.
#define UNDEAD			(1<<8) // The same

#define JCOLOR_GOVERNMENT "#e9b117"
#define JCOLOR_MILITARY "#d30808"
#define JCOLOR_IMPERIAL "#851bdb"
#define JCOLOR_ABYSSANCTUM "#4196c7"
#define JCOLOR_MALEFACTORS "#6b6152"
#define JCOLOR_CITIZENS "#529154"
#define JCOLOR_FACTIONLESS "#e6dddd"
#define JCOLOR_VILLAIN "#e785c7"

// job display orders //

#define KZ_DEFAULT 0
#define KZ_THISSUCKS 0.1
//Government start - 1
#define KZ_SOVEREIGN 1
#define KZ_CLANMEMBER 1.1
#define KZ_CLANHEIR 1.2
#define KZ_PERFORMER 1.3
#define KZ_SERVANT 1.4
//Government End - 1

//Military start - 2
#define KZ_DOYEN 2
#define KZ_BACHELOR 2.1
#define KZ_SPECTACLER 2.2
#define KZ_RETAINER 2.3
#define KZ_MILITIA 2.4
//Military End - 2

//Imperial Start - 3
#define KZ_QUARTERMASTER 3
#define KZ_SIEGER 3.1
#define KZ_RAIDER 3.2
#define KZ_SEAMEN 3.3
//Imperial End - 3

//Abyssanctum Start - 4
#define KZ_PROPHET 4
#define KZ_ELDERTIDER 4.1
#define KZ_ONMIOJI 4.2
#define KZ_VOTARY 4.3
#define KZ_TIDER 4.4
#define KZ_SUPPLICANT 4.5
//Abyssanactum End - 4

//Malefactors Start - 5
#define KZ_PANDERER 5
#define KZ_CUTTHROAT 5.1
#define KZ_TOSHER 5.2
#define KZ_MASSAGER 5.3
//Malefactors End - 5

//Citizens Start - 6
#define KZ_CITIZEN 6
#define KZ_SILKRUNNER 6.1
#define KZ_LOWLIFE 6.8


//Citizens End - 6

//Factionless Start - 7
#define KZ_WANDERER 7
#define KZ_MIGRANT 7.1
#define KZ_DRIFTER 7.2
#define KZ_TESTER 7.9
//Factionless End - 7

//Villains Start - 8
#define KZ_BANDIT 8
//Vilains End - 8

#define BITFLAG_CHURCH (1<<0)
#define BITFLAG_ROYALTY (1<<1)
#define BITFLAG_CONSTRUCTOR (1<<2)
#define BITFLAG_GARRISON (1<<3)
