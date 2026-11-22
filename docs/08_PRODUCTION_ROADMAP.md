# Production roadmap

## Delivery strategy

Build the fundamentals, prove combat in a permanent Developer Arena, then integrate the opening mission. **The first deliverable is a runnable development foundation with direct arena access, not a finished planetary campaign.** The first major integrated milestone is the opening operation with both outcomes and a useful shipboard loop. This packet specifies the work; it does not contain a completed game.

The default recommendation is a single-player PC game in Godot 4 with typed GDScript and a 2D, three-quarter presentation. Verify the actual repository, installed engine, export support and existing code before choosing a pinned engine version. If a suitable project already exists, extend it rather than replacing it. Record technical deviations with their reasons. Work Mode may make routine reversible choices without another design interview.

No calendar estimate is committed here. Effort depends especially on usable character animation, engine familiarity, asset quality and the observed combat iteration rate. Track completed gates and remaining risks; do not equate generated code volume with a playable result.

## M0 Project foundation

Create or inspect the repository; establish its run instructions, version pin and ignore rules. Implement a boot scene and minimal main menu with **Developer Arena**, settings and quit. Add pause, input actions, basic audio/display preferences, a visible build identifier and a development-only entry override. The arena initially may be a gray floor, player placeholder and camera. Store settings independently from campaign progress.

**Gate:** A clean checkout launches to a usable menu and reaches the empty arena directly. Pause and quit work. Missing optional art does not prevent boot. Work Mode records the exact launch method and what was actually executed. Headless script checks supplement, but do not replace, launching the game.

## M1 Movement and visual proof

Build one production player controller and a representative movement space in the arena. Establish scale against an ordinary human, a doorway, a railing and a Khorgoth placeholder. Tune aim facing, movement, collisions, camera follow and input ownership. UI interaction must not fire a weapon behind the panel.

At the same time, test one medium armor design at the actual game camera size with its helmet and equipped cloak visible. Prove feet pivots, directional poses and one attack. Start with deliberately limited poses if needed, but label them placeholders. Choose the character asset pipeline based on this result. Do not create dozens of armor variants before one actor moves convincingly.

**Gate:** Movement feels responsive, diagonal movement is normalized, scale is coherent, and the player remains readable against a representative environment. A still concept image alone cannot pass the animation gate. If animation quality fails, simplify the presentation or improve the asset workflow before enlarging the content set.

## M2 Shared combat in the arena

Implement health, damage, a service rifle, a sword, melee contact timing, ammo/reload, hit feedback, dodge, guard and parry. There is no stamina meter. Add a stationary target, one raider and one gunner using the same actors and combat rules that campaign scenes will use. Add spawn/clear, refill and a one-action reset with repeatable presets.

Prove damage attribution, one-hit-per-swing rules, shot collision, enemy telegraphs and stagger. Add sound early: impacts and gunfire are part of evaluating feel. Use temporary clearly identified audio if final audio is unavailable. Confirm that appropriate play creates openings and benefits without requiring a generic momentum currency.

**Gate:** The developer can enter the arena and fight without playing any story. A new encounter and a reset are quick. Death and restart work. Holding attack, alternating inputs, parry timing and shots against walls do not create obvious exploit or collision failures. The arena uses production combat scenes, not a disconnected toy implementation.

## M3 Loadouts and build expression

Add Light, Medium and Heavy armor functions using a shared body baseline. Add the precision rifle and heavy cannon, plus the hammer: **three firearms and two melee weapons total**. Give each armor role one initial special and a small set of freely respecable traits. Begin simple weapon mastery with a high baseline competence; its initial progression may be a modest proof rather than a full campaign balance curve.

Add inventory/equipment UI, coherent item definitions and runtime item instances. The normal deployment restricts armor type; arena loadout changes are deliberately unrestricted and cannot affect a campaign save. Starting appearance concepts are selection proposals. Do not require three fully independent animated physiques or every crew alternative before this gate.

**Gate:** Each weight has a recognizable style of play, both melee weapons and all three firearms work, and arena swapping takes only a few actions. No preferred style depends on finding a specific random drop. Cosmetic tradition is independent from weight. New equipment does not mutate every item sharing its definition.

## M4 Destruction and persistence

Add an arena destruction lane with intact/breached walls, cover, an explosive and a deliberately authored structural collapse. Integrate navigation changes and persistent destroyed-state identifiers. Keep rubble effects bounded; do not simulate a whole building to destroy one useful route.

Implement versioned saves, atomic writes, stable IDs and campaign checkpoint versus suspend behavior. Add isolated arena settings/presets and deterministic scenario reset. Extend the arena with representative elite and boss mechanics before writing the full narrative around them. Add inspectable, bounded diagnostics for contacts, damage sources, AI states and timing.

**Gate:** Destruction affects collision and routes consistently, reload restores the correct world state without duplicate loot or actors, and arena experiments cannot contaminate campaign progress. Validate interrupted or invalid saves safely. Developer cheats are conspicuous and cleared on transition back to normal play.

## M5 Opening operation integration

Build the compact bridge/personal quarters interaction space, initially with one captain and one artificer functional. Use portraits, text and radio for other characters. Connect mission briefing, loadout, deployment, three authored combat zones, the lieutenant, warlord duel, arm loss, the consequential rescue/pursuit branch, debrief and rewards.

Use existing arena-proven systems. Implement the first 20–35 minute operation as an explicit pacing target to measure, not a guaranteed runtime. Clearly identify future mission hooks as future content. A small handcrafted operation proves the campaign structure; it is not a commitment that every planet takes one mission.

**Gate:** A fresh run reaches either legitimate ending, the chosen outcome survives save/load, rewards are granted once, and the restored district has visible changes. Rescue and pursuit receive comparable reward budgets with different consequences. The player can resume after defeat without pretending every lethal encounter caused a new canonical death.

## M6 Integrated review and delivery

Review readability, animation, sound, input consistency, UI scale, performance and save reliability on the declared test machine. Run a compact representative matrix from the QA chapter: three armor roles, both endings, destruction, suspension and checkpoint recovery, plus the highest-risk input combinations. Fix blockers; do not repeat every test without a changed risk.

Export a playable build with clear controls and known limitations. Keep the Developer Arena available for development review. Attach small native gameplay screenshots, exact build/run instructions and a short evidence-based test report. Do not present generated concept art as a screenshot from the build.

**Gate:** Another person can start the delivered build, use the arena, play the opening and understand what is implemented. Remaining placeholders are named. A compilation success or a polished menu alone is insufficient.

## Expansion after the opening works

Add content in useful increments: more enemy combinations; stronger armor and weapon visual variety; a second authored operation; richer crew interactions; then a bounded regional campaign generator. World supply, simplified crafting, side plots and event-driven territorial changes follow once they can reuse stable mission systems. A living galaxy should create opportunities, not a constant obligation to defend everything yourself.

Full galaxy simulation, seamless planets, multiplayer, full cruiser interiors, ship piloting, elaborate modular gun assembly, voice production, procedural cutscenes and a complete population simulation remain outside the opening scope. Keep extension points small; do not build speculative frameworks for every eventual idea.

## Handoff at every milestone

Update `PROGRESS.md` with the exact working state, update relevant decisions, and record meaningful validation in `TEST_REPORT.md`. Include the next smallest useful implementation task. If a gate is blocked, describe the concrete blocker and a reversible remedy. Continue useful authorized work instead of waiting for permission on every implementation detail; ask only when a genuine product choice or access requirement prevents progress.
