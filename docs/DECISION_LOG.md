# Decision Log

## 22 November 2026 — Arena before mission

Build the permanent Developer Arena and shared fundamentals first. The user explicitly requested direct combat, weapon and destruction testing without campaign traversal. The opening invasion is the first integrated milestone, not the first implementation task. See `08_PRODUCTION_ROADMAP.md` and `12_DEVELOPER_ARENA.md`.

## 22 November 2026 — Bounded content for the opening

Use three armor weight profiles, three firearms, two melee weapons, one environment kit, one authored operation and two functional ship contacts. Alternate physiques, crew and visual traditions remain designed options. This preserves variety while avoiding a multiplicative animation workload.

## 22 November 2026 — Native 2D starting recommendation

Recommend Godot 4 and a fixed three-quarter native 2D presentation because the user is concerned about achievable model quality. Prove a small layered animation pipeline at gameplay scale before expanding. This is a technical recommendation; a working existing implementation is not automatically discarded.

## 22 November 2026 — Small assets and selective context

Use project-specific image budgets, preserved originals, compressed derivatives, bounded output and separate Markdown memory files. The reported prior image/response problem has not been diagnosed from incident logs; the safeguards reduce avoidable payload and import risks without claiming a universal platform limit.

## 22 November 2026 — First playable runtime

- Pin Godot 4.7.2 official and matched desktop templates. The project starts on the title menu and supports `-- --arena` for direct review. [Architecture](06_TECHNICAL_ARCHITECTURE.md)
- Ship one medium kit and four named presets now. Keep the isolated scenario controller as the only code responsible for spawning and reconstructing drills. [Developer Arena](12_DEVELOPER_ARENA.md)
- Use original rendered directional plates for the first actor. Native captures show the relative human scale, a visible cloak and two distinct boot positions. Preserve source rigs and hold broader cosmetic production until strafing has been reviewed. [Art direction](03_ART_DIRECTION.md)
- Keep 1280 × 720 as the native review size and embed data in each desktop executable so the playtest needs one launch target. Window/fullscreen and bindings persist independently of any campaign.

## 22 November 2026 — Correct the arena’s visual target

The owner rejected the 0.1.0 presentation. Use option B’s illustrated color and value separation, with the original angular medium armor and crimson cloak from the later design studies. Rework the playable kit, its opponents, the hall and HUD before producing more equipment families. Keep floor collisions and attack timing on their existing ground coordinates. The first visual review uses an actual mixed-squad capture and a movement clip. See [art direction](03_ART_DIRECTION.md).

## 22 November 2026 — Karth Vale as the scene reference

The owner selected the supplied Karth Vale concept as the acceptance target for the game's overall look, with flexibility on viewpoint and composition. Use the earlier armor studies for kit details and compare the next playable encounter against the [scene criteria](03_ART_DIRECTION.md#karth-vale-gameplay-art-target).

## 22 November 2026 — Prove one environment before expanding equipment

The owner wants environment production tested early given the campaign scope. Use the first mixed-squad encounter to prove actor scale, material separation, prop collisions, depth sorting and assembly cost. Keep moving actors and solid fixtures independent of the painted perimeter. The [roadmap](08_PRODUCTION_ROADMAP.md#early-environment-and-art-pass) places this work before the equipment expansion.

## 22 November 2026 — Scene targets and a reusable art kit

Use all four supplied concepts as acceptance targets alongside the original Karth Vale close view. The arena pair shares architecture, fixtures, scale and panel treatment. Heavy adds a distinct silhouette. Stage the new art in its own small Godot project so the team can place props and compare alternatives before binding campaign, movement or destruction systems. [Scene acceptance](03_ART_DIRECTION.md#scene-specific-acceptance-targets)
