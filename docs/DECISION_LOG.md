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
