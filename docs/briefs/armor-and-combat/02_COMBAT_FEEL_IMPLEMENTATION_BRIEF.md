# Imperial Space — Strong, Impactful Combat

## Purpose, status, and authority

This is an implementation brief for the existing Imperial Space project. It specifies the experience to produce, practical implementation responsibilities, a small development sequence, and evidence that can demonstrate success. It is not a report that the current repository has been inspected or that any named feature already exists. Work must audit the current game and improve the useful systems already present before creating replacements.

The owner’s established requirements are authoritative: a powerful augmented human Crusader; equipment-driven builds; viable melee, ranged, stealth, and command-oriented approaches; active defense; cooldown abilities; no stamina; and satisfying progression without universal scaling that erases earned strength. The companion armor brief records the approved Medium/Heavy silhouette. This document adds proposed methods and tuning values for achieving the desired combat. Values are starting hypotheses, not measured results or settled balance.

Keep the project’s pinned Godot version, input conventions, save architecture, and Developer Arena priority unless a concrete defect requires a change. The official engine references at the end support the API cautions; use the documentation matching the installed engine version. No engine upgrade or wholesale combat rewrite is implied.

## 1. The experience we are building

The Crusader is an exceptional fighter before the armor helps him. His body supplies force; the equipment allows him to apply it against extraordinary opposition. He should feel decisive, responsive, controlled, and physically present.

A successful sword strike visibly commits the body, reaches the target, produces an appropriate reaction, and leaves the player ready to make the next decision. A rifle is secure in his hands while its rounds visibly affect the enemy. A hammer carries more preparation and force, then delivers a result worth that commitment. Heavy armor conveys stability and mass without making normal play lethargic.

Three moments should become repeatable pleasures:

- **Turn the attack:** read a raider’s committed swing, parry it, and answer with a decisive cut while another enemy approaches.
- **Break the position:** suppress or strike a gunner, destroy the cover protecting him, and advance into the space that opens.
- **Meet something worthy:** an armored champion withstands casual pressure, reveals readable openings, and rewards an intelligently timed heavy strike or precise volley.

Ordinary enemies demonstrate the player’s superiority. Competent enemies threaten him through their actions, positioning, coordination, and special mechanics. Both should be enjoyable to fight.

## 2. Non-negotiable constraints

- No stamina bar or hidden stamina substitute limiting ordinary movement, attacks, blocking, or dodging. Do not introduce an exhaustion meter under another name.
- Momentum describes good play and escalating advantage. It is not a required build-and-spend currency.
- Special abilities can have cooldowns. Ammunition and reloads remain meaningful, with the established generous supply, salvage, and resupply opportunities.
- The character is competent with every supported weapon. Mastery and talents deepen an already functional baseline. Switching build must not return him to inept handling.
- Preserve equipment-focused builds, manageable complete weapons, and straightforward modifiers. Do not add a complicated assembly system to support this combat pass.
- Armor weight and visual tradition are separate. A knightly appearance does not force melee; a hunting appearance does not permanently assign a class.
- Meaningful attack commitment is permitted. Accidental input locks, long routine helplessness, and sluggishness added merely to imply weight are not.
- Melee and ranged approaches both need answers to the representative encounters. Distinct strengths are desirable; mandatory weapon immunity walls are not the default.
- Improvements to combat must be demonstrated in the running game. Concept art, damage numbers, particle density, and a feature list cannot establish that it feels good.

## 3. Build the full sequence of an impact

Treat a strong attack as a connected sequence:

1. **Intent:** the input is acknowledged and the player can read what will happen.
2. **Preparation:** the stance, weapon position, and body make the direction and force understandable.
3. **Delivery:** hips, shoulders, hands, and feet cooperate along a credible path.
4. **Contact:** authoritative hit detection agrees with the visible striking surface or shot.
5. **Consequence:** the target, its equipment, or the environment responds to that specific contact.
6. **Recovery:** the fighter regains a useful position and the next permitted input takes effect promptly.

Audit this sequence before adding stronger presentation effects. If the blade passes through an unreacting enemy while the camera shakes, the underlying failure remains. Conversely, a clear swing and well-timed recoil should remain understandable with decorative effects disabled.

Do not confuse three separate values: **health damage**, **ability to interrupt or displace**, and **presentation intensity**. A blocked blow can create a strong metallic impact while dealing little damage. A precise rifle hit can deal substantial damage without launching the victim. A corpse can react more dramatically than the living enemy did.

## 4. Body motion, locomotion, and equipment

Author representative poses and transitions before expanding the weapon catalog. For the first sword, show preparation, acceleration, contact, follow-through, and recovery. A hammer needs a planted force-producing movement. A firearm needs a correct grip, brief recoil through arms and torso, and a controlled return to aim.

Reject whole-character rotation, squash pulses, or camera wobble as the principal attack animation. They may supplement authored motion. Verify both legs contribute to walking; feet must not slide continuously beneath a static pelvis. Turns need coherent body/weapon relationships, especially across diagonal facings. Do not rotate a painted character card to stand in for all directional art.

Separate the character’s gameplay movement from decorative sprite offsets. Lunges, charges, recoil displacement, and knockback that change position must use collision-aware movement. A visual torso movement does not automatically move the character’s ground position. The foot pivot, ground plane, shadows, weapon grips, muzzle anchor, cloak anchors, and facing convention must agree.

For Heavy, show firm foot placement, substantial weight transfer, and less reaction to incidental pressure. Preserve enough joint clearance for the same real defensive and offensive actions. Ordinary walking should not silently damage everything touched. Small enemies may yield through crowd separation; stronger displacement and damage belong to deliberate charges, shield strikes, and attacks.

The equipped cloak stays visible. Plan directional layers so it can pass behind a shoulder, clear the gun, and follow the turn without vanishing or becoming a stretched triangle. Helmets remain on during combat. Production assets must be judged at the real game camera, not only in enlarged captures.

## 5. Input, action timing, and commitment

### One authoritative action clock

Use one per-actor action timeline to own startup, active contact windows, recovery, movement allowance, and cancel windows. Animation and effects follow that state. Damage must not depend on whether the renderer happened to display a particular frame. If the project already uses authored animation events as its authority, preserve one consistent authority; do not add a second independent timer that disagrees with it.

Express timing in seconds or milliseconds and evaluate it against the fixed simulation step. Do not tie gameplay to rendered-frame counts. At the current physics rate, record the effective quantized timing rather than pretending an arbitrary fractional frame occurs exactly.

Sample input continuously, including during short hit pauses. Start with a **120 ms input buffer**, then compare roughly 100–150 ms. This is a proposal. Retain a small, bounded intent set instead of queuing a long accidental combo. Consume an action once. Give deliberate guard/dodge input priority over a buffered offensive follow-up when the cancel rules permit it. Released or expired input must not fire unexpectedly several actions later.

An accepted ready-state action should begin on the next eligible simulation step and show its preparation promptly. Measure both input acknowledgement and first contact: a deliberate sword windup is different from the game ignoring the button. Preserve the existing mouse/keyboard movement and aiming scheme; do not silently redesign controls during a feel pass.

### Explicit cancel rules

| Current state | Required behavior |
| --- | --- |
| Free movement | Start a ready attack, defense, dodge, or ability promptly. |
| Early attack preparation | Permit defensive cancellation before a clearly defined commitment point. |
| Committed contact phase | Keep a short, weapon-specific commitment; do not permit free cancellation that duplicates hits. |
| Recovery | Restore movement/defense before the next full attack where appropriate. Readiness need not wait for every decorative settling frame. |
| Reload | Defense or melee can interrupt. Transfer ammunition at one authoritative event and only once; cancellation must not create ammunition. |
| Hit reaction | Return control promptly after ordinary hits; severe reactions belong to understandable stronger attacks. |
| Death, reset, scene exit | Invalidate pending action callbacks, clear temporary states, and release presentation holds. |

Holding a repeatable basic attack may repeat it according to the existing control design, but it must not consume the entire buffer or suppress an intentional defensive action. Weapon switching, ability cooldowns, and reload cancellation must share these rules. An old asynchronous callback from a canceled action must never produce a later ghost hit.

### Proposed first timing profiles

These are tuning seeds. Test them at normal speed with the actual animation and enemies before accepting them.

| Action | Startup | Active contact | Recovery | Intended distinction |
| --- | ---: | ---: | ---: | --- |
| Basic sword cut | 120–180 ms | 70–110 ms | 160–240 ms | Fast, deliberate, readily chained |
| Committed heavy blade cut | 220–320 ms | 90–140 ms | 230–340 ms | Stronger reach/force and clearer commitment |
| Hammer strike | 300–420 ms | 80–130 ms | 280–400 ms | Substantial preparation with a decisive result |

Example sword profile: 140 ms preparation, 90 ms active, 210 ms recovery. Allow an early defensive cancel, then a brief committed interval, then defense before all recovery art finishes. Choose the exact boundaries in data; do not infer them from the table alone.

For a ready rifle, avoid a large artificial first-shot delay. A proposed automatic cadence of 120–170 ms between rounds can be tested if compatible with that weapon’s identity; do not apply it to every firearm. Record reload transfer, first-shot response, cadence, recoil recovery, and ammunition consumption separately.

## 6. Contact, hit detection, and weapon identity

Use each weapon’s actual path. A directional cut must not damage a full circle because a radial query was convenient. Sweep or otherwise sample the motion between relevant weapon poses so a fast strike cannot tunnel through a target between ticks. A rotating blade arc needs adequate swept coverage; a single thin ray is not automatically a correct replacement.

Deduplicate by **attack instance + target + explicitly permitted subhit**. Multiple hurtboxes on one enemy must not multiply an ordinary swing’s damage. Multi-hit actions declare their distinct contacts; lingering overlap is not a multi-hit design. Clear per-attack tracking when the attack ends or is invalidated.

For firearms, one authoritative aim/obstruction solution determines the hit, tracer endpoint, impact position, and damage. Reconcile the visible muzzle with the project’s ground-space/projection convention in every facing. Test shooting beside a wall and across cover; the gun must not appear to fire through intact geometry. Separate shotgun pellet damage accounting from its aggregated feedback so one trigger pull cannot cause a dozen full-strength camera impulses.

Weapon identity should be visible in the exchange:

| Weapon | Required feel | Failure to reject |
| --- | --- | --- |
| Sword | Controlled arc, useful reach, crisp parry/counter, satisfying cuts through appropriate targets | A static blade plus circular damage and a generic flash |
| Hammer | Planted delivery, heavier interruption, strong armor/cover response, short debris aftermath | Slow swing followed by the same tiny response as a rifle round |
| Rifle | Prompt shot, secure handling, readable muzzle-to-impact relationship, controlled recoil | Floating gun, arbitrary spread, hits before shots, or constant recoil knocking the Crusader around |
| Heavy cannon, when supported | Greater report and force, strong bracing, impactful enemy/cover response | A scaled-up rifle sprite with unchanged behavior or an overwhelming effect cloud |

Begin with one sword, one rifle, and one hammer unless equivalent weapons already exist. Reuse a functioning cannon if available. Do not build an entire arsenal before these feel distinct. Strength gains should eventually make earlier foes easier; avoid automatic enemy inflation that cancels those gains.

## 7. Enemy reactions and meaningful threats

Resolve reaction from the incoming action, impact direction, target body/material, defensive state, resistance, current animation, and whether the hit is lethal. Use a small readable vocabulary: acknowledge, flinch, interrupt, stagger, displace, knock down, die. Each target need not support every outcome.

| Target | Successful ordinary contact | Strong contact or earned opening |
| --- | --- | --- |
| Light raider | Local recoil, brief flinch, interrupted careless attack where appropriate | Stagger, displacement, knockdown, or decisive death |
| Gunner | Aim disruption and visible armor/body reaction; attempts to regain cover | Strong interruption, loss of position, broken emplacement |
| Armored brute | Bracing, localized recoil, sparks or plate response even when it resists stagger | Recognizable broken stance or stagger during an intended vulnerability |
| Major enemy | Clear material and body acknowledgement without trivial repeated stun | Authored punish window, phase consequence, armor break, or a substantial reaction |

Heavy damage does not always require large displacement. A braced elite can resist being moved while still communicating the hit. Never make resistance look like an unresponsive sprite. Guarded, parried, immune, and damaging outcomes need different readable feedback.

Lethal hits deserve a clear physical conclusion. A rifle burst can buckle a light enemy; a forceful sword cut can drive a directional collapse; a hammer can throw a defeated body against nearby cover. Select short authored death responses by force and direction, with bounded blood, fragments, or severed armor where appropriate to the established tone and available assets. Begin with convincing collapses and a few strong variants; complex procedural dismemberment is not a prerequisite. Death must resolve immediately enough to communicate the kill and free valid space. Optional executions must not become compulsory pauses in every exchange.

Protect both sides from degenerate stun loops. Use target-specific reaction recovery, interruption resistance, or escalating temporary resistance where needed; do not silently remove damage because a reaction animation is on cooldown. Ordinary attacks should not hold the player in prolonged unavoidable stun. Dangerous enemies earn stronger reactions through visible preparation and counterplay.

Give enemies intentions. Raiders approach and commit; gunners use lines of fire and cover; brutes control space with stronger telegraphed attacks. Limit simultaneous melee engagement through positioning and short-lived engagement slots so a pack surrounds and pressures rather than all occupying one point. This must not turn every enemy into a passive queue: ranged fire, flanking, repositioning, and hazards continue to matter.

Difficulty should arise primarily from combinations of these behaviors, defended angles, terrain, timing, and mistakes the player can understand. Avoid invisible perfect tracking, offscreen instant punishment, and health inflation as the main way to extend a fight. Every representative encounter must remain solvable by the supported melee and ranged approaches with appropriate play.

## 8. Guard, parry, dodge, and recovery

**Guard** provides a dependable defensive option within its declared facing and equipment coverage. A shield can protect against eligible frontal fire; a sword does not automatically stop every projectile. Preserve current weapon/ability rules and communicate exceptions clearly. No guard-energy bar is required. Flanking, grabs, area attacks, and strongly telegraphed crushing attacks can challenge a stationary guard.

**Parry** rewards deliberate timing. Begin testing a 90–130 ms parry window at the start of an eligible guard action, followed by sustained ordinary guard when held. This is a proposal, not a final balance rule. Prevent rapid button tapping from creating uninterrupted perfect-parry coverage. Success gets a distinct contact sound, visible deflection/reaction, and a useful opportunity to counter. Optional talents can trigger short regeneration or cooldown benefits; the baseline parry is already worthwhile.

Any parry rearm interval applies only to the perfect-parry opportunity. Ordinary guard remains available when its normal facing, equipment, and action-state rules permit it; preventing parry spam must not introduce a general defensive lockout.

**Dodge** gives readable displacement and bounded protection. As a starting experiment, test roughly 280–380 ms of total movement with a clearly located 100–160 ms protection interval. Inspect the vulnerable portions and repeat recovery so chaining does not create continuous immunity. Do not add consumable dodge charges or a stamina substitute by default. Heavy can use a forceful short step or braced displacement, while Light can look more agile; preserve practical ways for each to answer encounters.

Telegraphs must agree with actual danger. Use shape, motion, sound, and restrained color together. Explain an unblockable or unavoidable-with-guard action through its presentation before punishing the player. All damaging areas, including a boss’s sweep or explosion, require correct coverage and timing.

Conditional regeneration and recovery reinforce active success without demanding one narrow playstyle. If parry-based recovery exists, also support viable opportunities for ranged or evasive builds through their own choices. Do not require every player to perform executions or stand in a banner radius to sustain normal play.

## 9. Hit pause, sound, camera, and effects

### Hit pause with bounded influence

Use short reaction holds selectively. Proposed target-side pauses: around 20–40 ms for meaningful ordinary impacts and 40–70 ms for major hammer, parry, or decisive impacts. Many automatic-fire hits should use only recoil, sound, and localized effects.

Distinguish a presentation hold from deliberate mechanical hit-stop. Normal player-facing feedback/accessibility settings may reduce presentation intensity, but must not silently change authoritative hit windows, cooldowns, reaction durations, or difficulty. Any hold on an action clock is a combat rule and stays consistent across ordinary presentation settings. Arena controls that change it must be labeled debug/tuning overrides. A visual-only hold must not conceal an imminent attack or let the visible pose drift away from dangerous contact; omit the hold if that agreement cannot be maintained.

Prefer target-local holds. If a heavy melee contact also pauses the attacker’s action timeline, keep that addition very short and preserve input sampling/buffering. Pause the corresponding contact clock too; a visually frozen blade must not keep manufacturing new hit windows. Continue correct world collision and damage evaluation. Do not create accidental invulnerability or repeated unavoidable vulnerability. If attacker pauses harm crowded-fight responsiveness, remove them while retaining the target reaction and other feedback.

Aggregate simultaneous contacts: one sweep hitting six enemies chooses a bounded impact response, rather than adding six camera kicks and six freezes. Do not continually refresh a target into a permanent visual freeze. Track expiry on a clock that can actually advance while the held action is paused. Clear all holds on reset, defeat, scene transition, and invalidated actions.

Do not implement routine contact by repeatedly setting global `Engine.time_scale`. It changes the game clock, affects delta-based simulation and timers, and does not independently slow audio playback. Godot also cautions against setting it to zero. This couples unrelated combat and interface behavior to an impact effect. [G1] Timers have explicit time-scale behavior; choose their clocks deliberately. [G2]

### Sound supplies information and force

Give representative weapons authored sound layers: release/swing, contact material, target reaction, and short aftermath where useful. Distinguish flesh/body, armor, shield, machinery, and stone. A miss still has a weapon-release sound, but no false contact sound. Rifle report, bolt action, cases, and reload handling should support the firearm’s size without burying enemy cues.

Use a small pool of credible variants with restrained pitch/level variation. Limit simultaneous voices and prioritize nearby meaningful contacts, warnings, and player actions. Aggregate crowd impacts; protect the mix from clipping. Loudness alone is not weight. Inspect with ordinary headphones at a reasonable level and ensure prolonged automatic fire is tolerable. Godot provides stream randomization and positional playback facilities; use them within an intentional voice budget. [G7][G8]

### Camera and visual effects preserve play

Begin with short capped impulses. Proposed review values at a 720-pixel-tall presentation: ordinary meaningful hits around 1–2 display pixels and major impacts around 3–5, decaying over roughly 80–160 ms. These are hypotheses, not device-independent engine coordinates. Default most rifle hits to no shake. Test the actual zoom and resolution.

Never let shake alter authoritative aim, collision, or a precision shot’s intended target. Separate logical camera/aim calculations from presentation offset, or otherwise compensate consistently. Godot’s `Camera2D.offset` is suitable for presentation motion but can move the view beyond configured limits, so test scene edges. [G6]

Use brief directional sparks, impact marks, modest dust, small muzzle flashes, and readable body motion. Preserve enemy windups beneath effects. Avoid repeated full-screen flashes, zoom pumping, enormous persistent trails, and decorative circles unrelated to hit geometry. Provide separate shake, flash, and hit-pause controls. Reducing them must leave essential telegraphs and contact information available.

## 10. Destruction and physical consequence

Start with one useful destructible barrier and one authored breach fixture. Give them explicit intact, damaged, and broken states, with appropriate material response. When cover breaks, collision and any relevant navigation/line-of-fire state must update coherently; do not leave an invisible wall behind attractive rubble.

Concentrate debris near the impact and move it consistently with the force. Cap active fragments and settle or remove them so debris cannot clog the arena or consume the whole frame budget. Cosmetic fragments do not need a full persistent physical simulation. Corpses need a clear movement policy and must not become accidental permanent navigation blockers.

Respect authored mission constraints. A protected route or fixture must have an understandable reason and feedback; do not promise universal destruction. Preserve the broader mission doctrine/collateral design without trying to implement every campaign consequence during this combat pass. Arena destruction must reset cleanly and leave campaign state untouched.

## 11. Practical implementation responsibilities

Map these responsibilities onto existing code. They are conceptual boundaries, not a mandate to add a class for every noun:

| Responsibility | Owns |
| --- | --- |
| Actor action controller | Input intent, authoritative phase clock, movement/cancel permissions, action identity |
| Attack definition | Timing, hit geometry, intentional subhits, damage, force, guard/parry rules, animation and feedback references |
| Contact resolver | Collision/obstruction, target deduplication, defense outcome, one accepted contact result |
| Target response | Health, resistance, reaction choice, displacement, death, interruption behavior |
| Feedback presentation | Sound, camera, local holds, effects and their aggregation/budgets |
| Arena controller | Presets, deterministic setup, diagnostics, resets, tuning experiments and save isolation |

An accepted contact result should carry enough information for its consumers: action ID, target ID, permitted subhit ID, position, normal/direction, outcome, material, applied damage, reaction tier, displacement, and lethal/destruction result. Resolve once; present from that result. Debug labels can expose this data without adding runtime UI clutter.

Use the fixed simulation path for authoritative movement and contact. Godot distinguishes fixed physics processing from render processing. [G3] `CharacterBody2D` movement should use the project’s collision-aware movement methods; `move_and_slide()` already incorporates its timestep, so do not multiply the velocity by delta a second time. [G4]

For action-synchronized animation, use the appropriate physics or manual processing mode supported by the installed `AnimationMixer`/`AnimationPlayer` version. Keep method-call ordering safe around deletion and action cancellation. [G5] Do not let independent tween completion, animation callbacks, and timers each claim authority over the same hit.

For suitable swept volumes, `ShapeCast2D` supports shape sweeps and explicit updates. Configure body/area detection, collision masks, exclusions, and maximum results consciously; a hurtbox on an area will not be found by a query configured only for bodies. Shape casting costs more than a ray, so use the needed geometry rather than indiscriminately sweeping every effect. [G9]

Store tunable values in the existing data/resource convention. Separate weapon power from response/feedback profiles. Validate missing animation/attachment references early. Keep generated image originals and documentation outside runtime imports when appropriate; the companion art brief governs the image budgets.

## 12. Developer Arena: the primary workbench

Enter the arena directly without playing a campaign or a long tutorial. Use the same actor, equipment, attack, AI, collision, and destruction systems that campaign scenes use. Test setup may differ; combat behavior must not be secretly simplified in the arena.

Provide compact mouse/keyboard controls for:

- Medium/Heavy and supported Light presets; sword, rifle, hammer, and existing cannon loadouts.
- Named enemy compositions, spawn count, clear enemies, refill, heal, reset, and restore fixtures.
- A fixed seed for initial placement/AI decisions where practical. Do not promise bit-identical physics replays unless separately implemented.
- AI on/off, invulnerability, ammunition override, damage numbers, contact geometry, phase display, and target-reaction display.
- Separate audio, shake, decorative-effect, and hit-pause controls; essential telegraphs remain available.
- Debug pause, slow motion, and physics-step inspection where supported. These are diagnostics, not the main demonstration of feel.
- Explicit save/revert of tuning experiments through the existing data workflow. No accidental campaign saves, loot unlocks, progression, or resource changes.

Reset must invalidate attacks/projectiles, clear transient feedback and overrides, restore destructibles, remove corpses/debris, return actors to valid positions, and release debug time controls. Preserve settings only when intended. Never maintain a separate arena-only damage formula.

Changing armor weight through developer controls is an arena override/reset operation. It does not loosen the campaign rule: choose the armor type for deployment and keep field gear swaps within that type. Keep mechanical timing overrides separate from ordinary audio/visual preferences, and clearly show when a debug override is active.

### Repeatable encounter presets

| Preset | Setup | What it demonstrates |
| --- | --- | --- |
| Single exchange | One knight, one raider, clear floor | Attack animation, exact contact, parry, recovery, target response |
| Break the line | Six raiders and two gunners around useful cover | Crowd spacing, melee arcs, gun feedback, responsive defense under pressure |
| Beat the champion | One armored brute and two supporting enemies | Telegraphs, resistance, earned interruption, viable melee and ranged solutions |
| Make the breach | Gunner behind breakable cover and a blocking fixture | Material response, collision change, usable new space, reset reliability |

Use seedable setups and familiar loadouts to compare a change against the previous baseline. A large impressive horde is a later stress test; it does not replace the single exchange.

## 13. Implementation order

1. **Audit and instrument.** Record current controls, actor/action architecture, assets, timing, collision, feedback, save boundaries, and concrete defects. Keep a short gap list. Add useful diagnostics before guessing at the cause of poor feel.
2. **Prove one sword exchange.** One complete body/weapon animation, precise contact, a raider reaction, guard/parry/dodge, and purposeful sound. Demonstrate at normal speed with and without decorative feedback.
3. **Add weapon and target contrast.** One rifle and one hammer; then a gunner and an armored brute. Give each a distinct interaction while preserving viable approaches.
4. **Integrate both approved armor silhouettes.** Test identical representative actions in Medium and Heavy. Make mass readable without introducing arbitrary input delay or broken attachment clearance.
5. **Add useful destruction and crowd pressure.** Prove the breach and mixed-squad presets, then test constrained spaces, corners, simultaneous hits, and equipment transitions.
6. **Review and carry into the opening mission.** Share a playable arena and representative normal-speed captures. Continue fixing concrete failures before expanding content volume.

Complete each small result far enough to judge it. Do not spread effort across a large catalog of unfinished weapons, enemies, movement rigs, and decorative effects.

## 14. Acceptance evidence and failure cases

The owner should be able to enter the arena, select a loadout, spawn an encounter, and feel a clear difference. Provide short normal-speed captures of the same presets; use slow motion only to explain a specific issue. Include a capture with shake and decorative effects disabled while essential telegraphs remain.

| Check | Passing evidence |
| --- | --- |
| Body and weapon | Both legs work; feet support the action; weapon stays in hands; attack direction and recovery are coherent. |
| Contact | Visible strike/shot, hit resolution, sound and target response agree; no repeated overlap damage or hits through intact cover. |
| Responsiveness | Ready inputs acknowledge promptly; buffers consume once; attack–guard–dodge transitions behave as specified; no routine long locks. |
| Enemy distinction | Raider, gunner and brute respond differently; resistant targets still acknowledge contact and present meaningful openings. |
| Defensive fairness | Successful defenses are legible; threats have usable counterplay; neither player nor enemies fall into trivial permanent stun loops. |
| Physical mass | The Crusader remains stable against incidental pressure; deliberate force produces collision-respecting results. |
| Sustained clarity | Several minutes of play remain readable and tolerable; crowd effects/audio do not stack without bounds. |
| Destruction/reset | Broken cover changes play space, debris stays bounded, and repeated resets restore a valid clean encounter. |
| Armor fidelity | Heavy is identifiable by outline and motion; helmet, cloak, grips and joints remain coherent in all supported facings. |
| Campaign isolation | Arena experiments leave campaign saves, resources, unlocks, missions and progression unchanged. |

Use meaningful automated checks for the actual failure risks: per-target hit deduplication, cancellation invalidation, ammunition transfer exactly once, hit-pause expiry and reset, collision-state transitions, and campaign-save isolation. Add them where the code supports useful verification; do not write tests that merely repeat configuration constants. Visual quality and feel still require observation.

Instrument input time, action acknowledgement, contact time, outcome, reaction, duplicate-hit attempts and frame-time spikes. Compare at more than one render framerate if a concrete frame-dependency risk exists. Record the hardware/build conditions for performance observations; do not claim a frame-rate guarantee from this document. Stop broadening tests after the identified risks and required gates are sufficiently covered.

## 15. Context files and delivery discipline

Maintain separate concise Markdown records and reuse existing equivalents: `COMBAT_FEEL.md` for intent and accepted behavior; `COMBAT_TUNING.md` for actual values and why they changed; `COMBAT_TESTS.md` for evidence and unresolved failures; the project’s asset manifest for attachments/animation; and `PROGRESS.md` for completed work and the next concrete task. Add decisions to the existing decision log rather than duplicating lore across all files.

Preserve this brief as a linked source. Each work session should read the short progress/decision/tuning records relevant to its task, not reload the entire conversation or every image. Record filenames and version/build identifiers for evidence. Keep previews within the project’s 1280-pixel long-edge and 600 KiB budgets, never inline base64, and link additional material. Runtime atlas budgets remain 2048 pixels per edge and 3 MiB encoded; those do not describe total decoded memory.

Report what changed, why, what was observed in the running game, and what remains unproven. Headless tests, a screenshot, or a successfully launched build alone do not prove weight, satisfying combat, or coherent animation. If real play/capture is unavailable, state that limitation rather than declaring the feel pass complete.

## Official technical references

The game-feel decisions and numerical proposals above are design recommendations for this project. The following primary references substantiate engine behavior, not claims that the proposed tuning has been playtested. Select the project’s pinned engine version when using these pages.

- **[G1] Engine:** global time scale and audio caveat — https://docs.godotengine.org/en/4.6/classes/class_engine.html
- **[G2] Timer:** time-scale and processing behavior — https://docs.godotengine.org/en/stable/classes/class_timer.html
- **[G3] Idle and physics processing:** fixed simulation versus render processing — https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html
- **[G4] Physics introduction:** character movement and timestep handling — https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
- **[G5] AnimationMixer:** animation processing and method-call modes — https://docs.godotengine.org/en/4.4/classes/class_animationmixer.html
- **[G6] Camera2D:** presentation offset and camera limits — https://docs.godotengine.org/en/4.4/classes/class_camera2d.html
- **[G7] AudioStreamRandomizer:** variation and no-repeat playback — https://docs.godotengine.org/en/stable/classes/class_audiostreamrandomizer.html
- **[G8] AudioStreamPlayer2D:** positional playback — https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer2d.html
- **[G9] ShapeCast2D:** sweep detection, explicit updates and query configuration — https://docs.godotengine.org/en/stable/classes/class_shapecast2d.html
