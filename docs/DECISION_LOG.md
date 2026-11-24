# Decision Log

## 24 November 2026 — Bring the Knight closer to infantry scale

The previously proposed Knight-to-trooper height ratio of 1.67 looked excessive in play. Try approximately 1.37 in the Armory, preserving the trooper and camera as references. Keep the lowered follow-through as its own strike key and author a separate rested guard for both weapons. [Side-by-side capture](evidence/knight-guard-scale.png).

## 24 November 2026 — Share motions across compatible equipment

Use a socket on each authored pose and a small foreground hand layer to register interchangeable weapons. The shoulder plate has a separate attachment point. Reserve new body animations for different grip or weight families. Validate one-handed fittings in the optional arena trial before expanding the runtime art library. [Equipment art](03_ART_DIRECTION.md#equipment-at-gameplay-scale)

## 23 November 2026 — Register the weapon to the fist and paint the aftermath

The previous lower-body warp also bent the blade in the raider’s hand. Register a single solid cleaver after the legs are posed. Use the final hand coordinate at release. Give the body and each detached part its own painted volume, impact response and grounded silhouette. [Art direction](03_ART_DIRECTION.md#weapon-contact-and-separation)

## 23 November 2026 — Paint the shift in body mass

Use separate posed drawings for the supported changes in posture. Physics still selects travel, collision and the separately propelled weapon arm. Register each pose to the feet or ground contact. The owner’s style references favor simple, legible shape changes and distinct material faces at game scale. [Art direction](03_ART_DIRECTION.md#mass-and-contact-at-gameplay-scale).

## 23 November 2026 — Author the break and simulate the aftermath

Give structural fixtures four registered painted plates and one solid footprint. Use health thresholds to select the plate, then release the footprint on collapse. Give the first severable enemy a painted body and weapon arm in each displayed heading. A shared ground sweep and short vertical arc give the remains direction and weight. This controls the final silhouette and lets the artist add another material or enemy family without drawing every fragment in flight. [Arena acceptance](12_DEVELOPER_ARENA.md#destruction-review)

## 23 November 2026 — Pair the duel review with the armor proof

Adopt the supplied combat and armor briefs for the [next arena review](08_PRODUCTION_ROADMAP.md#next-playable-review-after-030). Medium and Heavy have approved outlines. The art review tests those outlines at equal height while the combat pass repairs one decisive exchange. Preserve responsive ordinary actions, independent aim, active defense and the existing equipment rules.

## 22 November 2026 — Reward one opening in two ways

Give a successful frontal parry a short opportunity against that specific raider. The player chooses a sword finish or a high-damage rifle shot. The next attack spends the chance, including a miss. Put the second ordinary sword stroke behind confirmed contact and a fresh press. These decisions reuse familiar controls and leave guard, dodge and aim responsive. The Crossfire drill gives positioning a comparable payoff in mixed combat.

## 22 November 2026 — Prove one breach in live play

Use the illustrated proving ground for a short, repeatable destruction test before equipment expansion. Only the center shutter is breakable. The masonry jambs persist and only a crossing through the aperture advances the objective. Keep the forecourt presets reachable from Range controls.

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
