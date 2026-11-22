# Developer Arena

## Purpose

This is a permanent development feature and the first substantial playable deliverable. The owner must be able to launch the game, enter a fight, change equipment, break a wall and reset without playing a campaign introduction. Every later combat feature receives an Arena scenario before it is relied upon in a mission.

The Arena is a small menu-driven test space. It is not a separate game, an elaborate editor or an endgame mode. Reuse production player, enemy, damage, loot and destruction scenes; only setup, diagnostics and reset belong to the developer layer.

## Entry and isolation

Put **Developer Arena** directly on the development build's main menu. Support a documented launch argument that selects it immediately. Target a usable empty arena within 15 seconds on the agreed test machine after startup, then measure the result; this is a usability goal, not a current performance claim.

Use an explicit `ARENA` session mode, a separate random seed and separate developer preferences. The Arena must never read or write campaign progression, mastery, achievements, mission outcomes, inventory or autosaves. It may load shared immutable definitions. Arena equipment instances are temporary copies. Leaving it clears debug damage, invulnerability, time scale and spawned entities before another mode starts.

Show a persistent **DEVELOPER ARENA** label. Active cheats must be obvious. Entering the Arena does not require a campaign save. A player's normal game remains available and untouched on exit.

## The first room

Use a flat, bounded floor with a visible scale grid toggle, clear walls, a shooting lane, a melee lane and a small breach lane. Include a few human-scale reference props and one ordinary soldier silhouette to judge Crusader size. The floor must be visually readable before decoration is added.

Provide marked spawn positions and enough open space to test dodges and approaches. Add a cover corner, a narrow passage, a breakable wall and a two-support gantry as capabilities mature. Spawn placement rejects occupied or invalid positions instead of stacking enemies inside the player.

## Controls that remove friction

Keep the default panel compact. Expose advanced diagnostics behind a foldout. Keyboard shortcuts are convenience bindings and remain remappable.

| Control | Required result |
| --- | --- |
| Scenario selector | Loads a named scenario with its visible seed and intended test. |
| Start / restart | Builds that scenario from a clean initial state in one action. |
| Clear enemies | Removes enemies and their attacks without damaging the player. |
| Refill player | Restores health, medical charges, magazine, reserve ammunition and ability availability. |
| Loadout selector | Applies any of the three weight presets without leaving the Arena. |
| Individual gear selector | Swaps weapons, armor and traits; shows the active setup. |
| Spawn controls | Choose enemy type, count, formation and passive or active behavior. |
| Reset destruction | Restores the test fixtures and their collision/navigation state. |
| Pause / step | Freezes simulation; advances one simulation tick for diagnostics. |
| Diagnostics | Toggle collision shapes, hit regions, sight lines, navigation and simple timing information. |
| Exit | Returns to the main menu and resets developer overrides. |

Do not bury spawning beneath multiple confirmation windows. Destructive reset only affects an isolated test session. Changing a scenario can reset it directly because there is no campaign progress to lose.

## Scenario library

| Preset | Main question | Stage |
| --- | --- | --- |
| Empty floor | Do movement, aiming, camera, pause and facing work? | First runnable foundation |
| Dummy range | Do shots and swings register once, at the right place and time? | Core combat |
| Raider duel | Can a player read, guard, parry and dodge a single enemy? | Core combat |
| Mixed squad | Are melee pressure, gunner fire and cover readable together? | Enemy expansion |
| Destruction lane | Do wall breaches and support collapse update every affected system? | Destruction |
| Light approach | Does detection reward route choice without omniscience? | Limited stealth |
| Warlord duel | Are boss attacks, arm loss and state transitions robust? | Mission preparation |
| Crisis resolution | Do both branch objectives, committed checkpoints, outcomes and one-time rewards work? | Mission integration |
| Stress formation | What is the practical enemy and effect budget on the target machine? | Performance review |

The Crisis resolution fixture starts immediately before the rescue/pursuit choice and uses the production mission controller and short branch objectives. It can exercise either ending without replaying the campaign. Rewards and world outcomes remain inside the isolated Arena session.

The stress preset uses explicit counts such as 5, 10, 20 and 40 actors; these are measurement points, not promised production encounter sizes. Keep count caps configurable and report the machine and settings with results.

## Reset and reproducibility

Store a scenario definition containing stable IDs for the selected map, actors, equipment, player start, fixture states and seed. **Restart** reconstructs this baseline. It clears projectiles, delayed attacks, particles, damage-over-time effects, corpses, temporary loot, AI targets, pending callbacks and runtime path caches. It restores time scale and health. Do not achieve reset by merely teleporting actors to their start positions.

The same scenario and seed should reproduce the initial setup and random choices. Do not promise bit-perfect replay across engine versions or hardware. A bug report should contain scenario ID, seed, build revision, loadout, actions taken and expected versus observed behavior. A small bounded event log can report attack start, contact, damage, guard/parry result and death. Keep it off by default and never flood normal output with per-frame messages.

Expose invulnerability, passive enemies, frozen AI, unlimited ammunition and immediate cooldowns individually. Defaults use real game rules. Tuning fields may override session values, but changing a resource in the Arena must not silently edit the game's shipped balance data. Provide a deliberate export of selected tuning values for review if needed later.

## Delivery sequence

1. Build empty-floor movement, direct entry, pause, exit and reliable reset.
2. Add the service rifle, sword, dummy and raider; prove hit detection and basic defense.
3. Add loadout switching, remaining weapons, weight representations, traits and mixed enemies.
4. Add destruction fixtures and a limited detection encounter.
5. Add the lieutenant and warlord presets, then integrate their proven behaviors into the opening mission.

Do not postpone basic access and reset until the campaign exists. Conversely, do not delay a useful first playable while building every diagnostic listed here. Grow the Arena alongside the production systems, keeping its controls useful at every stage.
