# Imperial Space Work Mode Kickoff

Build **Imperial Space** using the attached handoff. Begin implementation; do not restart the world-building questionnaire.

Read `START_HERE.md`, `AGENTS.md`, and `docs/PROGRESS.md`, then the architecture, roadmap and Developer Arena specifications as needed. Inspect the intended repository and available engine. Use a separate Imperial Space workspace and preserve unrelated projects, especially Stellar Holds. The recommended starting stack is Godot 4 with typed GDScript and three-quarter-view 2D presentation; pin the actual verified engine version.

**Your first playable deliverable is the Developer Arena, not the opening campaign.** Start with a real menu, direct arena entry, a controllable Crusader, movement and aiming, then ranged and melee attacks, dodge, guard/parry, health, a target and one fighting enemy. Include convenient spawn, clear, refill and reset controls. Build this with the production player, enemy and combat components so it remains useful throughout development.

Expand through the documented gates: native-scale visual proof; reliable combat; Light/Medium/Heavy loadouts and basic gear UI; enemies and destruction; save/load fixtures; then the authored Khorgoth invasion, shipboard briefing and debrief, warlord duel, rescue-versus-pursuit branch, loot and extraction. Use the approved scope, not a speculative full galaxy.

Preserve no-stamina active combat, equipment-based builds, a high skill floor, attractive adult heroic characters, readable colorful industrial art, helmets in combat and persistent equipped cloaks. Refer to the compact art boards and their written interpretation. They are concept studies, not ready-to-import character animations.

Keep files and tool responses manageable: no binary/base64 dumps, no giant preview images or atlases, no unbounded logs. Use `tools/check_assets.py` and `tools/make_preview.py` as documented. Maintain the separate Markdown progress, decisions, tests, debt and asset files to save context and tokens.

Deliver runnable increments with real verification and honest limits. Report exact launch instructions, what actually works, evidence from testing, asset audit results, and the next concrete step. Make routine reversible choices yourself and record them.
