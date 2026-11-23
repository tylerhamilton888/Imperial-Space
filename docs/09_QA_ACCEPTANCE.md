# Acceptance and Verification

## Reporting rule

This document defines future checks. It does not assert that a game, build or any gameplay test already exists. Record actual build revision, engine version, platform, commands, results and known limitations in `TEST_REPORT.md`. A successful script parse is not evidence that combat feels good or a playable export works.

Use focused checks for the current change. Automate important invariants such as item identity, damage deduplication and save migration when their implementation exists. Do not build a large test suite that simply repeats every data value. Visual feel, animation readability and player control require direct play and observation.

## Gate 1 Foundation

- Project launches through the documented command and exported development build.
- Main menu reaches the empty Developer Arena directly; pause, resume and exit work.
- Movement, camera and aiming behave at the intended aspect ratio. Diagonal movement is not faster. Facing changes do not move collision unexpectedly.
- UI input does not leak into attacks. Remapping persists, with a working reset to defaults.
- One Crusader and one enemy read correctly at actual gameplay scale; the equipped cloak stays visible. Clearly label temporary visuals.

## Gate 2 Combat Arena

- A rifle shot and sword swing damage each intended target once. Shots respect nearby walls and cover. Cancelled attacks cannot apply late damage.
- The raider has understandable anticipation, contact and recovery. At normal speed a tester can distinguish a correct guard, parry, dodge and a mistake.
- No stamina or equivalent action exhaustion has been introduced. Ordinary combat works while abilities recharge.
- Repeated guard taps and chained dodges do not create continuous invulnerability. Holding a button through a menu transition does not generate an unintended attack.
- Clear, refill and restart work without reloading a campaign. A restart restores the same scenario setup and removes delayed attacks or leftover hazards.
- Arena runs leave campaign save bytes and progression unchanged. Exit resets time scale and all cheats.

## Gate 3 Equipment and Destruction

- All three armor presets can move, fight and complete representative mixed encounters. Every firearm and both melee weapons receive at least one practical test.
- Equipment instances remain independent. Equipping, dropping, saving or loading an item never duplicates it or mutates the shared definition.
- Field swapping honors the deployed armor weight; Arena swapping deliberately overrides this restriction only inside its isolated mode.
- A ranged build has enough practical ammunition access to finish the encounter; melee is not a mandatory emergency punishment for normal ranged play.
- Breaking a wall changes collision, visibility and navigation. An enemy can use the new opening without walking through intact walls. Reset restores all three.
- Support collapse triggers once. Enemies, the player and objectives cannot become permanently trapped by purely cosmetic debris.

## Gate 4 Integrated Opening

- The default ship captain and artificer work through text interactions; loadout and mission selection are accessible without a fully explorable cruiser.
- A fresh campaign reaches the distress response, battlefield rescue, industrial approach, lieutenant, warlord duel, arm-loss event and final choice in the intended order.
- Both pursuit and civilian rescue can be completed. The game explains the immediate stakes before commitment, then records only the chosen outcome.
- Optional earlier rescues use different flags from the final mass-rescue outcome. Equal reward budgets do not mean identical rewards.
- All three armor weights can finish the mission. Playtest the target 20–35 minute duration with the intended pauses and dialogue; adjust content from evidence.
- The debrief reflects the actual world state, survivors, infrastructure and warlord status. Future hooks are labeled as unavailable if their missions are outside the slice.

## Gate 5 Saves and Recovery

Test normal suspend/resume during a quiet room, an active encounter, after destruction and immediately after the final choice commits. Restoring must preserve health, ammunition, equipment, cooldowns, actor state, objective state and the relevant seed or random state. Capture a coherent snapshot at a simulation boundary rather than half of a damage event.

Separately test defeat and checkpoint retry. A retry restores the chosen checkpoint consistently; it does not silently count as a canonical withdrawal. Interrupt one save write and verify that the previous valid save remains usable. A missing or incompatible save should produce an understandable recovery message, not a blank screen or silent new campaign.

## Performance and presentation review

Agree on a modest Windows test machine before setting firm budgets. A provisional goal is stable 60 fps at 1920×1080 for ordinary encounters. Record frame-time spikes, actor counts, effects and memory use; lower content budgets when measurements require it. An uncapped empty room is not a representative performance test.

Review the native gameplay frame and movement clip against the [Karth Vale art target and criteria](03_ART_DIRECTION.md#karth-vale-gameplay-art-target). Record visible differences and the owner’s review alongside the build revision.

Check readable enemy telegraphs, damage feedback, UI text, color distinctions and cursor visibility with reduced effects. Do not depend on red versus green alone. Use image previews within the asset-response budgets; do not attach full-resolution raw sheets to routine status updates.

## Ready for owner review

Deliver an actual runnable build or exact reproducible launch instructions, direct Arena access, known controls, a short list of implemented features and the important remaining limitations. Include one or two compressed screenshots only if useful. Mark every unfinished feature plainly. Stop expanding scope once the current milestone is sufficiently verified; record follow-up work instead of hiding it inside the acceptance pass.
