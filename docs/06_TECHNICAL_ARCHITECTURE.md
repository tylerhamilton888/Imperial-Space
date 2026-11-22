# Technical Architecture

## Starting stack and repository

Recommended stack: Godot 4, typed GDScript, native 2D gameplay and a fixed three-quarter presentation. Start with the Compatibility renderer unless a measured feature need justifies another renderer. Use mouse and keyboard first; action-based input keeps later controller support possible. Target Windows desktop; verify exports on available hardware and label other platforms untested.

Discover the installed engine, export templates and existing project before deciding the exact version. Pin the tested minor and patch in the repository README and progress file. Use documentation for that version after pinning. Do not silently upgrade the engine mid-milestone.

Keep `game/project.godot` and runtime content under `game/`. Keep `docs/`, `reference_art/`, `tools/`, source art and full test captures outside that runtime root. Suggested runtime areas are `scenes/player`, `scenes/enemies`, `scenes/arena`, `scenes/missions`, `scenes/hub`, `scenes/ui`, `scripts/components`, `data`, `art`, and `audio`. Create folders as content requires them. Do not generate an empty framework of hundreds of files.

## Scene responsibilities

| Component | Responsibility and boundary |
| --- | --- |
| Main menu and session router | Enter arena, campaign or settings; create explicit session mode; restore time scale and debug state on exit. |
| Player scene | Movement, action requests, animation presentation, and references to combat/equipment components. |
| Action controller | One authoritative attack/defense state, timing, cancel rules, input buffering, and animation events. |
| Combat resolver | Validate one hit, determine mitigation/guard/parry/stagger, apply consequences, emit a result. |
| Enemy scene and role profile | Sensors, finite-state decisions, movement, combat requests and reactions; no mission progression ownership. |
| Destructible scene | Stable ID, health/state, collision and navigation changes, optional authored structural dependency. |
| Mission controller | Explicit objectives and outcome state; listens to combat/world events; cannot invent combat hits. |
| Save service | Validated versioned snapshots and safe writes; unaware of presentation widgets. |
| Arena controller | Scenario setup, reset and debug tools using the same production actors and definitions. |
| UI | Presents state and sends action requests; never changes inventory or damage by editing labels. |

Use scene-local references and a few typed signals. Keep autoloads small: settings, save coordination and session routing if useful. A broad global event bus or dependency-injection framework is unnecessary for the slice.

## Coordinates and collision

Use `CharacterBody2D` for scripted actor motion; its movement API is designed for user-controlled bodies with collision handling. Use the floating motion mode appropriate to top-down movement rather than platformer gravity behavior. [T1]

Maintain a consistent world ground coordinate separate from the sprite's visible height. Feet determine actor sorting and body collision. Weapons, tall walls and hit effects may have visual elevation, but they do not alter the player's ground position. Set a few collision layers explicitly: world solids, player bodies, enemies, friendlies, combat detection and interactions. Document masks next to the definitions.

Move in the physics tick with normalized diagonal input. Begin with a 60 Hz physics target and measure performance before changing it. Avoid using sprite rectangles as body collisions. Test doors, narrow routes and diagonal cover contacts with all three weights. Ordinary decorative debris has no permanent navigation obstacle unless the encounter requires one.

## Combat contracts

An action request includes actor ID, action ID and aim direction. The action controller accepts or rejects it once. A hit request includes attack instance ID, source, target, raw damage, damage/impact category, contact position and direction. The resolver returns applied damage, guard/parry/stagger outcome and death once. Deduplicate melee contacts by attack instance plus target; one sword swing must not hit once per overlapping physics frame.

Separate anticipation, active frames and recovery. Animation and collision windows refer to the same action timing data. Brief buffering prevents swallowed input, while explicit cancel windows prevent animation-cancel exploits. There is no stamina resource. Do not allow shooting, melee, reload and guard to run conflicting independent timers that all resolve simultaneously.

Use hitscan queries for fast firearm rounds, with visible tracers as presentation. Use swept collision for slower physical projectiles. Resolve from a valid muzzle origin and check obstruction; clicking through a wall must not let the ray originate on the far side of it. Camera shake and hit pause are presentation and must not multiply damage or produce save timing bugs.

## Data and content definitions

Use small typed Resource definitions for weapons, armor, abilities, enemy profiles, loot tables and scenarios. Godot shares loaded Resource objects, so treating loaded definitions as immutable avoids accidentally changing every actor that references one. [T2]

Maintain runtime instance data separately:

- `WeaponDefinition`: stable ID, family, fire/action behavior, base stats, animation profile and loot category.
- `ItemInstance`: unique instance ID, definition ID, rolled modifiers, upgrade state and binding owner. A definition is not an inventory item.
- `ArmorDefinition`: weight, mitigation profile, allowed component slots, movement/action modifiers and visual set reference.
- `LoadoutState`: equipped item instance IDs, selected traits, ability choices, ammunition and deployment weight.
- `EnemyProfile`: role, sensors, preferred distance, action selection, morale response and loot table ID.
- `MissionState`: mission ID, checkpoint, objective states, persistent actor/object state, outcome and reward-claim ledger.
- `ArenaScenario`: seed, loadout, spawn groups, destructible fixtures and explicitly enabled debug overrides.

All numeric balance values belong in data, not scattered in enemy scripts. Keep a small validated registry mapping IDs to allowed definitions; do not deserialize arbitrary script or resource paths from saves.

## AI and navigation

Start with clear finite states: idle/patrol, investigate, engage, reposition, attack/recover, flee/rally, defeated. A role profile selects behavior. A gunner seeks a firing lane; a raider closes; a veteran coordinates pressure; the warlord uses authored phases. Perception stores last-known position and uncertainty. Enemies do not track the player through every wall.

For the bounded grid-authored slice, use an `AStarGrid2D` navigation service with authored walkability. It supports solid cells and grid paths; build agent-clearance rules and corner-cutting restrictions on top of that representation. [T3] This is a project recommendation, not a claim that grid navigation automatically handles a moving crowd.

Build navigation once for a loaded zone; toggle affected cells for a destroyed wall rather than rebuilding the entire level every frame. Keep navigation state and physics collision changes in the same destruction transaction. Repath affected actors after the update. Separate visual debris from gameplay blockers. Test radius clearance, trapped actors and simultaneous actor movement. Use local avoidance/short steering if needed; do not build a crowd simulator first.

Stagger perception updates and path requests. Start with roughly 12–20 active combat enemies in the stress scenario, then measure; this is a test target, not a promise of a hardware-independent limit. Reserve larger hordes for after profiling.

## Destruction as authored gameplay

A destructible has a stable ID and a state such as intact, damaged or destroyed. One state transition updates visible art, collision, navigation, objective effects and save data. Use pre-authored rubble and bounded temporary fragments. A two-support structure can trigger a particular collapse region, with clear warning and deterministic damage rules. Do not simulate arbitrary structural engineering.

Infrastructure state belongs in mission outcomes. Hitting one prop should not immediately rewrite a whole planet economy. The debrief can derive a small supply-quality result from preserved assets, saved civilians and the chosen ending; later world systems consume those results.

## Saves and recovery

Godot's saving guide demonstrates explicit persistent-object data and JSON serialization, and identifies `ConfigFile` for configuration. It is a starting point, not the complete save system required here. [T4]

Keep settings separate from campaign state. Use a versioned JSON schema with stable IDs, primitive values and explicit vector encoding. Store selected appearance/palette and crew candidate IDs once those choices are implemented, plus the loadout and inventory instances, health, magazine and reserve ammunition, cooldowns, traits/mastery, mission/objective states, branch decision, claimed rewards, significant enemy state, destroyed objects, RNG state and spawn counters. An active suspend also stores attack/projectile/hazard state and timers needed to resume fairly. Never reconstruct a save by replaying reward or destruction events.

Distinguish three functions:

1. **Checkpoint retry:** a recoverable restart from an authored checkpoint, with an explicit UI label. Failure between checkpoints is not a new alternate campaign timeline.
2. **Suspend and quit:** resume the same current encounter without replenishing health, ammunition, enemies or pending hazards. Capture at the next coherent end-of-physics-tick boundary, not only when every enemy is dead. Freeze simulation while assembling that snapshot.
3. **Completed mission save:** commit outcome and reward claims together, so a crash or reload cannot produce both branch rewards.

Use a temporary file in the same save directory, validate a complete snapshot, preserve a known-good backup, then replace the main slot. Verify failure handling on the target OS; do not assume every filesystem provides identical crash guarantees. Reject unsupported future schema versions gracefully and retain the original file. Define migrations when the schema changes; never silently reset the player's campaign.

Seed procedural/scenario randomness for reproduction and store RNG state when resuming. Do not promise bitwise deterministic physics across hardware. A saved actor needs a stable persisted ID; scene names and current child indexes are not reliable identity.

Arena state uses a separate directory and profile. Opening the arena must not write campaign progression or unlocks. Clear debug overrides, spawned actors, damage multipliers and time scale before a campaign session. Test the boundary explicitly.

## UI and performance practices

Use action names in InputMap and a central rebinding map. Menus consume input before combat; closing inventory must not fire a shot. Pause works in the single-player campaign and arena, with UI still responsive. Keep world simulation clock separate from UI and event scheduling. Display mission length and complexity before deployment.

Profile the real arena and the exported game before optimizing. Log frame time, active actors, projectile/effect counts and texture usage where available. Cap transient effects and object lifetimes; pool only measured hotspots. Preload the small current encounter's assets where that improves hitching; do not preload the eventual galaxy.

Target a responsive 60 fps presentation at 1080p on the first recorded test machine. Record CPU, GPU, resolution and measured frame-time behavior; do not advertise a minimum hardware specification before testing it. Give camera shake, flash intensity, text size and combat effects practical options.

## Technical references

Primary Godot documentation checked 22 November 2026. These sources support the engine concepts above; architecture, budgets and acceptance rules are project recommendations. Replace stable documentation links with the pinned version during implementation when necessary.

- **T1:** [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html).
- **T2:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html).
- **T3:** [AStarGrid2D](https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html).
- **T4:** [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html).
