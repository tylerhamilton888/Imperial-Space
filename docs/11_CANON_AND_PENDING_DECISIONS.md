# Canon and Working Decisions

## Settled direction

The working title is **Imperial Space**. The player begins as a recently ascended, already competent Crusader. The fantasy is personal heroic power in service to a capable, expanding, human-only Empire led by a distant exceptional Sovereign. Other human societies exist. The Empire should visibly improve the worlds it wins; commanders and methods still vary.

Crusaders are extremely rare, physically massive enhanced men, independent in operations and extraordinary in authority. Equipment determines fighting style. Light, Medium and Heavy exist; visual tradition is separate. Helmets stay on in combat and a worn cloak remains visible. Masculine handsome men, feminine attractive adult women, healthy physiques and flattering uniforms are the character direction.

Combat has no stamina system and no spendable momentum meter. Melee, ranged, blocking, parrying, dodging, special abilities and conditional rewards for good play all belong. Threat is meaningful, but ordinary enemies must not automatically match every power increase. Builds should be enjoyable without punishing preferred play styles.

The campaign mixes a main narrative, side plots and later emergent crusades. Worlds are represented by selected playable regions. Major galaxy changes generally occur between operations; the player is not personally obliged to respond to every attack. The cruiser starts with a small explorable bridge/quarters hub. Dialogue is text first. Ordinary military forces are competent but cannot do what the Crusader does.

The opening responds to a brutal alien invasion, demonstrates battlefield superiority, maims the warlord, and offers a choice between finishing him and saving threatened people. It introduces both the Khorgoth warhost thread and a Harvester infiltration clue.

Alien equipment is generally prohibited, but Crusaders have unusual practical leeway while delivering victories. Later choices may affect access to elite Imperial equipment versus alien technology; this reputation and unlock system is deferred from the opening slice. The Sovereign can tolerate conduct he dislikes when it advances his larger ambitions.

## Recommended implementation defaults

Godot 4 and native 2D three-quarter presentation; one player rig; one permanent Developer Arena; three guns and two melee weapons; three armor profiles; one small mission kit; two functional crew contacts; 20–35 minute integrated opening. These are scoped recommendations for execution, not previously shipped features.

All numerical combat values are starting tuning values. Character names, planet names, exact insignia, commander titles and equipment names are proposals. Use them consistently until changed; do not require another naming interview to start implementation.

## Matters that do not block the foundation

- Exact engine release and renderer: inspect the environment and pin a tested choice.
- Exact camera scale, movement speed, defense timings, damage and loot rates: tune in the arena.
- Final appearance preset and preferred crew alternatives: use the default concepts while keeping data replaceable.
- Heavy has an approved squared collar and readable faceplate. Verify helmet turning clearance at gameplay scale. Additional visual traditions remain open.
- Full galaxy rules, economy, factions, romances, orders, children and immortality benefits: retain the lore direction and defer gameplay systems.
- Optional loyalty-failsafe narrative: preserve the premise, implement none of the branch in this slice.

## Change control

If a new proposal contradicts settled direction, flag the contradiction plainly. If it merely chooses an unfilled production detail, record the reversible default in `DECISION_LOG.md` and continue. The prose specifications and actual implemented state are separate: `PROGRESS.md` and `TEST_REPORT.md` must say what truly exists.
