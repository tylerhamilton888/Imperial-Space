# Combat and Equipment

## Current Medium combat tuning • 0.3.0

A parry opens the attacker for 0.86 seconds. The next aimed sword attack can riposte for 90 damage; the rifle can counter for 62. A normal sword hit (38) accepts a second press in recovery for a returning cut (49). An ordinary miss grants no follow-up. Raiders have 85 health. Gunner shots evaluate the first body or solid in their locked lane: movement after commitment can make them stagger their own raider. These are arena playtest values.

## Purpose and authority

Build a responsive, readable action RPG in which one exceptional man breaks a battlefield open. The Crusader is already formidable at the start. His equipment and good decisions produce specialization; he never needs to train basic competence. This specification supplies implementation defaults, not measured balance results. All numbers below are provisional tuning values.

The permanent [Developer Arena](12_DEVELOPER_ARENA.md) proves these systems before the opening mission consumes production time. Use the same actors, equipment definitions, damage resolution, movement and destruction code in both modes.

## Locked principles

- No stamina resource. Walking, sprinting, ordinary attacks, blocking and dodging never consume a replenishing action budget.
- Momentum describes rewarding good play. Do not add a momentum meter or a build and spend economy.
- Basic actions remain useful while special abilities recharge. Cooldowns control extraordinary actions, not permission to participate in combat.
- Blocking, parrying, dodging, positioning, aim and target selection all matter. Attacks are dangerous through their behavior and readable consequences, not just large health pools.
- Melee, ranged, mixed and eventually stealth or commander approaches must be viable. Do not adapt enemies to punish whichever equipment the player enjoys.
- Armor augments the man. Avoid a tiny pilot inside a walking vehicle. Helmets stay on in combat; an equipped cloak stays visible.

## Camera and controls

Recommended foundation: a three-quarter 2D view, ground-plane movement and independent mouse aim. Keep aim, world position and illustrated sprite facing distinct. A sprite changing facing must not rotate or move its collision body incorrectly. Test the actual camera scale before commissioning directional animation.

| Action | Proposed default | Behavior |
| --- | --- | --- |
| Move | WASD | Normalize diagonal input; movement does not require a target. |
| Fire ranged weapon | Left mouse | Aim toward cursor; release/hold behavior follows weapon. |
| Melee | Right mouse | Directional attack, including without a selected enemy. |
| Dodge | Space | Directional step with a short animation and bounded recovery. |
| Guard and parry | Left Shift | Hold to guard; initial timed window can parry. |
| Reload | R | Explicit reload; optional automatic reload on empty. |
| Interact | E | Context action with visible prompt. |
| Execution | F | Only against an eligible nearby enemy; never the interact key. |
| Heal | Q | Limited medical charge; generous replenishment. |
| Special abilities | 1–3 | One active slot initially; additional slots come later. |
| Map / equipment | Tab / I | Pause single-player simulation while open. |
| Pause | Escape | Pauses combat and mission timers. |
| Arena panel | F1 | Developer mode only. |

Use named, remappable InputMap actions. Consume clicks in menus so closing a panel cannot fire a gun. Support hold/toggle guard and reduced camera shake. A short configurable input buffer should make deliberate follow-ups reliable without queuing an entire unwanted combo. Controller support is a later milestone unless the chosen project already has it.

## The core combat loop

Spot a threat, choose a route, commit to an attack, read the answer and respond. Melee and ranged weapons are simultaneously equipped, but one action controller owns the current attack, guard, reload or dodge. Clearly specify which actions can interrupt which states. Do not allow duplicate damage from overlapping animation frames or an attack that hits after it has been cancelled.

Start with a short, satisfying sword sequence and a slower hammer strike. Every attack has anticipation, contact and recovery. Impact comes from animation, hit reaction, sound, brief hit stop, particles and restrained screen movement. These treatments must preserve visibility of the next incoming attack. The sword cuts through light enemies; the hammer can interrupt a committed brute at the right moment. Neither is just a different damage number.

Firearms use ballistic presentation: report, recoil, tracer where appropriate, impact, casings and forceful reactions. Use reliable ray or swept collision for fast projectiles; presentation does not require simulating every bullet as a physics object. Gunfire hits the first valid obstruction. Avoid shooting through cover because the muzzle is on the wrong side of a wall.

### Defense without stamina

Guard protects a forward arc and reduces ordinary incoming damage. A correctly timed parry against a marked parryable attack interrupts or exposes the attacker. Heavy attacks can break a held guard and briefly stagger the player; ground effects and clearly signaled unblockable attacks require movement. Guard break is an attack consequence, not a draining stamina substitute.

Initial test values: approximately 0.15 seconds of parry opportunity, 0.25 seconds of dodge movement and 0.15 seconds of recovery. Tune from recordings, input latency and player feedback. Do not ship these as unquestioned constants. Repeatedly tapping guard must not restart a free parry window every frame; apply a short rearm rule. Dodging must not grant continuous invulnerability through animation cancellation. Both remain immediately available again after their brief committed actions.

Basic healing can come from medical charges, safe recovery and specific talents. A successful parry might briefly increase recovery. Holding guard in a corner must not generate an unlimited healing loop. Supply placements should prevent an ammunition shortage from forcing a ranged build to finish a mission with an unwanted weapon.

## Equipment and build scope

The first integrated slice contains three armor weight prototypes, three complete firearms, two melee weapons, one active ability per weight, a small trait selection and a handful of meaningful loot variants. It does not require a sprawling crafting interface or dozens of weapon parts.

| Loadout example | Equipment | Distinct experience | First special |
| --- | --- | --- | --- |
| Light hunter | Precision rifle, sword, light armor | Faster repositioning, deliberate shots, flank routes and awareness | Combat Sprint: short movement burst; no teleport or invisibility |
| Medium champion | Service rifle, sword, medium armor | Versatile shooting, parrying and aggressive close combat | Rally: brief recovery and stagger-resistance benefit |
| Heavy breaker | Heavy cannon, hammer, heavy armor | Forceful advances, suppression, breaches and close impact | Breach: committed short rush that interrupts suitable targets and breaks marked weak structures |

These are presets, not classes. Any weight can equip any of the five weapons unless a specific future item has a stated requirement. A light Crusader holding a cannon remains formidable; its handling, noise and recoil create tradeoffs. All three must complete the same authored mission.

Choose armor weight at deployment. During a mission, swap compatible pieces of that weight; other pieces go into inventory for the ship. Visual traditions such as Imperial Standard, Knightly and Military are cosmetic families independent of weight. Each weight must remain readable beneath color and ornament. The initial art workload is one base body and a limited set of readable armor representations, not a full matrix of every body, tradition, helmet and animation.

Armor is personally encoded. Treat newly found compatible components as unbound parts that the Crusader's authorized equipment can pair locally; do not imply a stranger can wear his whole personal suit. This is a proposed reconciliation for instant field upgrades, with no extra minigame.

### Small progression implementation

Begin with two freely selectable trait slots and six traits: improved recovery after parry, reduced ranged handling penalty after movement, a stronger first melee strike after a dodge, improved medical charge recovery, wider heavy-weapon suppression and a longer short-range detection grace period. Define a trigger, benefit, duration and internal cooldown for each. Avoid effects that recursively trigger themselves. This small selection demonstrates build choices; a full skill tree can follow proven combat.

Weapon-family mastery starts at a high competence floor. Record legitimate combat use and grant a modest first mastery benefit, such as a small reload or recovery improvement. New weapon families must feel good immediately. Do not force dummy farming, and never award campaign mastery from the Arena. Retain earned mastery when respeccing traits. The full game can add more interesting mastery unlocks after this small implementation works.

Loot is a complete item with a clear base identity and a few understandable properties. Prefer one interesting upgrade after a meaningful encounter over piles of near-identical junk. Prototype rarities can be Standard, Refined and Distinguished; names are provisional. One or two editable modifiers, such as ammunition type, are enough. Compare damage behavior, handling, useful effects and armor compatibility without a wall of percentages.

Keep item definitions immutable and item instances individually identified. Equipping one copy must not modify every item sharing its resource. Knowledge of unlocked fabrication survives a later loss of the supplying world; current material access may change. The first slice only needs a foundry-related unlock or resource reward, not an empire manufacturing simulation.

## Enemies and fair threat

Start with a training dummy and a melee raider. Add a gunner, a tougher veteran, a stationary emplacement, the lieutenant and the warlord through later Arena presets. Reuse rigs and core behaviors where credible; do not require seven unrelated animation pipelines before proving one attack.

Raiders close aggressively; gunners seek useful firing positions; veterans time or cover an approach. The warlord has a small set of legible attacks and meaningful openings. Ordinary human allies are competent but overwhelmed. Enemies respond to what they perceive and their faction's courage or discipline, not perfect knowledge of the player's cursor, inventory or position behind walls.

Stealth eventually uses sight, sound, suspicion, last-known position, search and alarm. A suppressed weapon reduces detection rather than deleting it. A commander can retreat, summon help or spring a prepared trap when that behavior is established and readable. The slice may demonstrate a flank and a short detection encounter; a fully systemic assassination of every boss is deferred. This limitation does not establish boss immunity as a permanent design rule.

Executions require a meaningful opening and a conscious input. Keep them short and prevent guaranteed invulnerability loops. A vulnerability indicator must be legible without requiring a fixed cinematic camera. Dismemberment is selective and authored; the warlord's arm loss is a specific narrative state, not a promise of arbitrary anatomical simulation.

## Destruction and defeat

Prototype three destruction classes: cosmetic breakables, cover that changes collision, and authored structural objectives with explicit support rules. A breached wall updates collision, navigation and line of sight together. Debris is capped and mostly cosmetic. Destruction can open a fast route while harming a settlement or reducing its surviving infrastructure. Record concrete outcomes; avoid a universal morality score.

Pause and suspend preserve the current expedition. Combat defeat reloads the latest designated checkpoint as a retry of the encounter. A real withdrawal, when offered, is a separate explicitly chosen outcome. Do not simultaneously claim the player canonically lost a world and restore it through a retry. The medical recovery fiction can explain ordinary recoverable failures later; it must not silently undo a completed story choice.

An ending decision commits once, with consistent mission and world flags. Suspension after committing it must preserve that choice. The opening mission's civilian rescue and warlord pursuit outcomes receive comparable reward budgets with different benefits; neither is secretly the only route to viable equipment.
