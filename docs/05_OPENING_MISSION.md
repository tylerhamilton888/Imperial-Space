# Opening mission

## The integrated milestone

**Working operation: The Relief of Karth Vale.** Karth Vale, Druvak, Khorvath, and Rellan are proposed names. This is the first integrated campaign demonstration, built **after** movement, presentation, combat, loadouts, saves, and destruction are proven in the Developer Arena. Do not start by scripting a long cinematic or building the entire city.

Target a first completion of **20–35 minutes**, including brief ship interactions. This is an experience target to measure with playtesting, not a verified duration. Use three compact playable regions with clear transitions and distinct landmarks. The opening can conclude one urgent planetary crisis; ordinary future conquests should usually take several operations.

The player's experience is straightforward: a city is losing a battle; he arrives and changes its course; the enemy proves dangerous enough to deserve attention; victory creates a consequential decision and reveals a larger threat.

## Required content budget

Build one bridge/quarters hub area, a landing perimeter, an industrial district, and a warlord compound. Reuse a single city kit across the combat areas. Include a gunner, a melee raider, a veteran role variant, a lieutenant variation, one emplacement, and the warlord. The veteran and lieutenant should reuse suitable base art and behavior rather than require unrelated production rigs. Vehicles, giant monsters, separate civilian schedules, and fully simulated buildings are unnecessary.

One main route and one alternate approach through the district are enough. Add a small number of explicitly authored destructible walls, supports, and explosive objects. The same damage and destruction components must already work in the Arena. 

## Mission sequence

| Stage | Intended play | Required result |
| --- | --- | --- |
| Ship briefing and departure | Approximately 2–3 minutes; read distress report, choose loadout and direct or flank insertion | Player understands the objective, enemy, mission estimate, and armor commitment |
| Landing perimeter | Approximately 4–6 minutes; break an assault on competent but outmatched defenders | Immediate power fantasy; movement, melee, shooting, and defense are useful |
| Industrial advance | Approximately 5–8 minutes; choose road, service flank, or a marked breach; fight lieutenant | Approach changes combat and infrastructure damage; optional civilians and supplies |
| Warlord compound | Approximately 4–7 minutes; short exchange and readable boss fight | Khorvath loses an arm through an earned combat event |
| Crisis resolution | Approximately 3–5 minutes; pursue or protect the evacuation | One clear outcome, with a short playable task rather than only a menu |
| Return and debrief | Approximately 2–4 minutes | Loot, world condition, and two future story hooks are understood |

These ranges total 20–33 minutes before unusual exploration or retries. Adjust encounter density rather than padding travel to hit a number.

## Landing and advance

The distress call shows burning districts, civilian movement, and a defensive line giving ground. On arrival, use an in-engine landing effect, a short camera settle, and immediate control. A heavy impact, debris, and soldiers' reaction can sell the entrance without a cinematic character performance.

The first pack should let the player interrupt an obvious attack on defenders and scatter weaker enemies. The second introduces a gunner with cover and a threatening telegraph. Rellan continues directing soldiers while giving the player one useful route report. 

The industrial district offers three expressions of the same route decision. The road is direct but covered by an emplacement. The service passage offers cover and a better angle. A marked wall can be breached, shortening the approach while damaging a useful depot or workshop. No approach requires a particular armor class; each makes different tools attractive.

Place one optional rescue and one useful supply cache where they reward attention without becoming a checklist. Clearly distinguish these people from the later evacuation crisis in both narrative and save flags. One structural destruction set piece is sufficient: damaging two visible supports collapses a small gantry into a predefined ruined state. Keep collision, cover, navigation, and the visual change synchronized.

The lieutenant encounter tests a learned skill: flank his protection, parry an announced strike, or interrupt the supporting gunner. Reward the win with a real item or material. Inspecting a damaged administrative terminal reveals evacuation records altered before the invasion. Its identifiers suggest a separate infiltration problem, but the player is not asked to solve it now.

## Warlord encounter and permanent injury

Khorvath acknowledges the protagonist's victories. The selected cold reply can be:

> “I have yet to find a warrior among you.”

A trophy toss is optional presentation. If the asset does not exist, use a portrait exchange and the lieutenant's broken insignia on the ground. Do not block the encounter on a bespoke animation.

The initial slice requires a real duel so its central combat demonstration is reliable. Future light-armor assassination routes remain part of the larger design, but a complete stealth boss system is not a prerequisite here. Telegraph this operation as an alerted battlefield, not an assassination contract whose advertised approach mysteriously fails.

Give Khorvath three readable attacks: a committed close strike, a sweeping attack that punishes standing beside him indefinitely, and a short ranged or thrown attack that prevents effortless circling. One reinforcement wave can test target priority. Use stagger windows and positional opportunity rather than an oversized health pool.

At the final stagger threshold, a short controlled action destroys his weapon arm. Clamp the encounter into this authored transition so projectile damage cannot accidentally skip the required wounded state. This is an explicit encounter phase, not an unexplained resurrection. The arm injury persists in both outcomes. Swap to the wounded actor state and change his behavior immediately.

## The crisis and the choice

Establish the relevant logistics before the duel. An enemy ground battery is targeting an evacuation corridor. Its targeting relay is inside the compound; a separate armored departure lane connects to Khorvath's transport. Allied infantry can hold the corridor but cannot cross to the battery. The ship's immediate support craft is already extracting wounded troops and cannot cover both locations.

After his injury, Khorvath starts a prepared withdrawal and orders the battery to fire. The player can personally reach the relay in time to stop the strike, or intercept the retreat before its armored transport clears the compound. Present both goals and their consequences plainly. Use the visible layout, travel distance, and a short established departure sequence to justify the conflict; do not invent an invisible wall or silently declare a successful second action invalid.

For the prototype, a tactical choice confirmation reserves the associated immediate support task and commits the mission branch. This is an authored scenario choice, not a claim that a fully simulated world has proved every conceivable solution impossible. The player then completes a short physical objective. Before confirmation, allow reconsideration; after confirmation, explain the other event through visible action or a report. Avoid a surprise timer during dialogue or inventory use.

**Protect the evacuation:** break through to the relay, disable it, and defeat its remaining guard. Civilians escape; Khorvath departs wounded. The district retains more labor and infrastructure, and the officer reports the people saved. A later revenge operation is suggested, not already implemented.

**Finish the warlord:** breach his departure position and complete a short final exchange. Khorvath dies; the battery hits the evacuation area before allied troops disable it. Show the consequence with a damaged scene state and restrained reports, not an expensive mass-casualty cinematic. His warhost loses its leader, reducing its immediate capacity to reorganize.

Both routes complete the operation successfully. Use equivalent overall loot and progression budgets, with different material or equipment emphases. Do not reserve the only exciting weapon for one moral choice. The larger game can contain demanding opportunities to achieve exceptional outcomes; a secret “save everyone and kill him” solution is outside this first authored scope.

## Resolution and visible restoration

The final scene shows defenders advancing, fires being contained, imperial banners or lights returning, and at least one useful service reopening. The rescue path includes a larger civilian group and a less damaged transit area. The pursuit path shows reduced enemy command pressure but a damaged evacuation sector. The world is improved by the invasion being broken in either case, with a different cost.

On the ship, the captain responds to the chosen priority and the artificer acknowledges recovered supplies. Add a wounded-warlord lead only if he escaped, and a Harvester-infiltration lead on both paths. Label these cards as future operations in the prototype. A debrief should not imply a playable galaxy exists when it does not.

## State and recovery contract

Store separate stable fields for optional district rescue, depot condition, lieutenant defeat, clue discovered and warlord arm lost. Separate `branch_choice` (`none`, `rescue`, `pursuit`) from `mission_status` (`active`, `completed`) and `final_outcome` (`unresolved`, `evacuation_secured`, `warlord_killed`). Confirming a branch records the commitment and its immediate opposing event, but does not claim that the player's remaining objective is already complete. Record rewards as granted once, tied to the completed mission instance.

Keep a checkpoint before the duel and before branch confirmation. On confirmation, atomically create a committed-branch checkpoint for the remaining objective. Defeat after commitment retries that branch; it does not return to the uncommitted choice. Set the completed outcome and grant its rewards together only when the remaining objective succeeds. A suspend save preserves the current state. Earlier checkpoints remain available for isolated developer tests, not as a way to collect both outcomes in the same campaign instance. Reloading must not duplicate loot, restore the arm or kill an escaped warlord.

For ordinary defeat, the campaign may explain a withdrawal or medical recovery when the scene supports it. At this tightly authored climax, checkpoint retry is the honest implementation. A brief recovery-flavored loading line is acceptable, but no alternate defeat storyline is required. The functional milestone is complete only after both branches, both save boundaries, and reward idempotency have been exercised.

## Karth Vale encounter study • The Last Tram

An evacuation car waits at a jammed junction. A signalman throws three locks while two raiders approach from opposite directions. The Knight can intercept a raider or provoke it into leaving the lever. Taking a hit interrupts the worker. If the operator falls, the car stays at the platform. If the line opens, he signals the driver and the loaded car pulls out. This standalone study exercises the district's evacuation stakes ahead of campaign integration.
