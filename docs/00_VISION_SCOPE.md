# Vision and Scope

## The game we are making

Imperial Space is a single-player, loot-driven action RPG about being the extraordinary man sent where ordinary forces cannot yet prevail. A Crusader arrives on a burning world, breaks an enemy formation, saves a position that was about to fall, and earns the equipment and influence to undertake greater campaigns. His strength is personal. Armor augments an already exceptional human being.

Between operations, he returns to his cruiser, speaks with recurring crewmates, prepares equipment with his artificer, and chooses the next request worthy of his attention. Eventually he fights across worlds and sectors in a galaxy that reacts to his victories. The player serves an expanding Empire; maintaining the Empire is not his administrative job.

The tone is confident, martial and emotionally sincere. Victories should offer pride, affection, brotherhood, intimidating physical power, and visible benefits to the people protected. Difficult enemies and meaningful decisions give that power something substantial to overcome. Threat comes from readable situations and capable adversaries, not exhausting the player with a stamina system or erasing every upgrade through automatic scaling.

## Pillars and their observable proof

| Pillar | Proof in the first integrated slice |
| --- | --- |
| Physical superiority with real danger | Basic raiders stagger and break; veterans and a warlord require spacing, defense and timing. |
| Freedom of approach | Choose equipment weight before deployment; use a direct route, a flank or a destructible breach. |
| A world worth winning | Defenders recover ground, civilians move to safety, a district visibly stabilizes, and preservation changes the debrief. |
| Desirable equipment | Distinct weapon behavior, a small number of legible upgrades, a meaningful reward, and loadout comparison. |
| A personal Imperial life | Two functional crew contacts, short authored dialogue, and an explorable bridge with adjacent quarters. |
| A foundation that can grow | The arena and mission share combat systems; content and persistent outcomes use stable data identifiers. |

## Scope in three layers

**First runnable foundation:** main menu, settings/pause shell, direct Developer Arena entry, one baseline Crusader representation, movement and aiming, dummy, service rifle, sword, one enemy and rapid reset. Placeholder art is acceptable here if clearly identified. This is the first development deliverable.

**First major integrated slice:** permanent arena plus one compact cruiser hub and one authored opening operation, targeting 20–35 minutes for a first run after tuning. Three connected battlefield zones demonstrate a larger world without pretending to simulate a planet. Shipboard briefing, landing, defenders, Khorgoth combat, a breach, one structural destruction set piece, a lieutenant, a warlord, a consequential ending choice, loot, extraction and debrief all work. Both endings can be exercised directly in the arena fixtures.

**Later game:** multiple campaigns per world, typically two or three playable regions and occasionally larger campaigns; a modest player-facing galactic state; authored main and side plots; procedural operation templates; world-driven production; faction variety, orders, romances and deeper build progression. These are design directions, not features promised for the opening build.

## Content budget for the integrated slice

| Area | Initial commitment |
| --- | --- |
| Player | One production body/rig; three cosmetic character concepts for selection; Light, Medium and Heavy armor profiles with readable silhouettes. |
| Weapons | Three complete firearms: service rifle, precision rifle, heavy cannon. Two melee weapons: sword and hammer. |
| Build expression | One signature special per starter loadout; a small freely respecable set of traits; a mastery data hook with a high baseline. |
| Armor art | One coherent Imperial Standard family in three weights; a small helmet/palette selection after the base animation works. Other traditions remain concept options. |
| Enemies | Khorgoth raider, gunner and veteran; lieutenant variation; one warlord. One static emplacement reuses projectile/damage logic. |
| Allies and civilians | Small authored defender groups and civilian clusters with simple states and purposeful behavior. |
| Environment | Arena; bridge and adjacent quarters; one city/industrial environment kit reused across three mission zones. |
| Destruction | Breakable cover, one breach wall, two readable supports controlling one authored collapse; no arbitrary building simulation. |
| Presentation | Text dialogue, portraits, gameplay camera accents, short animation beats, modest sound and effects. No voiced cinematic pipeline. |
| Persistence | Settings, equipment, progression, mission/checkpoint state, suspend/resume, destruction and an exclusive ending outcome. |

All quantities above are production caps for this slice, not instructions to make every asset in the first session. Armor or crew alternatives must not multiply the animation workload before the base production path is proven.

## Firm exclusions from this build

No multiplayer, spaceship piloting, full cruiser interior, whole-planet traversal, universal destruction, fully simulated alien empires, deep diplomacy, settlement administration, full stealth-assassination boss ecosystem, generative dialogue, voiced cinematics, child-rearing mechanics, loyalty-failsafe storyline, or complete immortality economy. There is no need for microservices, accounts, cloud saves or a procedural universe backend.

Do not implement the Harvesters as a second enemy faction yet. One specific clue introduces them. Do not make future mission cards look playable if those missions do not exist.

## What makes the opening functional

A player can start a new session, select a working loadout, deploy, move and fight without broken inputs, understand objectives, obtain and equip a compatible upgrade, use destruction as an approach, complete the boss and either ending, extract, see accurate rewards and consequences, save, quit and resume. The arena can test these systems without replaying the campaign. The final integrated milestone includes coherent native-scale visuals and readable attack animations; graybox functionality alone is an earlier gate.

This package does not prescribe a calendar promise. Estimate production after measuring the cost of one finished character animation set, one enemy role, one environment module and one complete arena test loop. Protect combat feel and readable art first; reduce content breadth before polishing an unproven campaign.
