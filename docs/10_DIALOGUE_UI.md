# Dialogue and interface

## Presentation

Use text-first classic ARPG presentation: a compact portrait, speaker name, readable text, and a few authored response choices. Voice acting is deferred. The important spectacle happens through the controlled character, enemy reactions, effects, environmental changes, and occasional short camera emphasis.

Dialogue should support momentum. A typical mission exchange is two to six short lines; optional ship conversations can be longer. Give each character a consistent vocabulary and sense of humor. Avoid making every officer an exposition terminal or every Crusader response a quip. Confidence often reads best as a short, unembellished sentence.

Pause single-player combat and mission urgency during full dialogue, pause menus, and inventory. Brief battlefield barks can appear without stealing control. Never let an enemy attack continue behind a modal conversation. Subtitles and interface text must remain legible over bright fire, smoke, and dark armor.

## Main menu and ship hub

The main menu exposes **Continue**, **New Campaign**, **Developer Arena**, **Settings**, and **Quit**. The Arena must be accessible without completing an intro or loading a campaign save. Show unavailable actions as unavailable with a reason, not as buttons that fail silently.

The hub is a compact bridge and personal quarters. Walking to the captain opens operations; the artificer opens equipment. Provide menu shortcuts to the same functions so routine outfitting never requires an unnecessary walk. The visible ship establishes companionship and status without requiring a fully navigable cruiser.

A deployment card displays objective, enemy faction, expected duration, complexity, known hazards, likely rewards, and selected armor weight. The opening card can read “20–35 minutes · several encounters · named commander.” Treat that estimate as provisional until playtested. Before departure, clearly state that armor weight is committed for the operation, while compatible components may still be equipped in the field.

## Equipment and progression

Show complete weapons, recognizable armor slots, and a small number of understandable modifiers. Comparison emphasizes a few useful properties: damage behavior, firing or attack rhythm, armor interaction, and the modifier's actual effect. Avoid a dozen tiny percentages before the player understands the weapon.

If a heavy deployment finds light boots, allow inspection and storage but explain that equipping them requires returning to outfitting. Do not destroy the loot or quietly change the deployment class. Visual tradition and palette stay separate from weight and statistics. Compatible field components are locally paired to the Crusader; the fiction must not contradict the ability to equip upgrades.

Build presets are suggestions the player can change. A small, freely adjustable trait panel is enough for the first milestone. Show weapon mastery as improvement from an already high baseline, not as permission to use an unfamiliar weapon competently. Future trees and crafting options should be represented by stable data hooks, not a screen full of nonfunctional buttons.

## Combat interface

Keep health, ammunition, cooldowns, selected equipment, and the immediate objective readable. There is **no stamina bar** and no momentum meter. Conditional buffs can use brief icons with plain explanations. Telegraph enemies through animation, sound, and consistent shape cues, not color alone.

Allow damage-number density and screen shake to be reduced. Make aim, interaction, and input hints adapt to remapping. Opening a menu must consume its mouse click so the same input cannot fire a gun into the scene behind it. Use action names in dialogue and help text rather than baking keyboard letters into prose.

## Sample opening exchanges

**Distress report**

Rellan: “Our line is still holding. The eastern battery will end that.”

Crusader, measured: “Then it will cease firing.”

Crusader, heroic: “Keep your people behind me.”

Crusader, exuberant: “Good. Something worth landing for.”

**Before the warlord**

Khorvath: “I see you have slain many of my warriors.”

Crusader: “I have yet to find a warrior among you.”

**Crisis report**

Lucan: “The battery has the evacuation corridor. Khorvath is withdrawing through the west lane. You can stop the strike or reach his transport before it clears the compound.”

Choices: “Secure the evacuation” and “Finish Khorvath.” Each receives a one-sentence consequence description before commitment. Do not label either “good,” “evil,” or “correct.”

**After rescue**

Lucan: “The corridor is clear. Rellan is bringing them home.”

Crusader: “Track the warlord. He has left me unfinished work.”

**After pursuit**

Lucan: “Their command net has collapsed. The evacuation sector took the strike.”

Crusader: “Get relief to the survivors. Then show me what remains of his host.”

## Dialogue data and reactive limits

Store dialogue in small structured records with stable IDs, speaker IDs, localization keys, conditions, and explicitly permitted effects. A choice can set a mission flag or select an authored response; it must not execute arbitrary code embedded in text. Evaluate prerequisites before showing choices and validate them again on selection.

For the prototype, support a handful of conditions: mission phase, selected tone, optional rescue, infrastructure state, and outcome. Do not build a universal relationship simulator. Limit reactive debriefs to a few tested variations, with a neutral fallback if a nonessential condition is absent.

The later loyalty-safeguard narrative is deliberately excluded. No ordinary menu should mysteriously rewrite a choice or imply a bug in the prototype. If that branch is built later, its interaction design requires separate tests and clear narrative preparation.

## Developer interface

The Arena can expose technical information because its user is the developer: hitboxes, AI state, damage events, time scale, spawning, invulnerability, and reset controls. Keep that interface visually distinct from campaign menus. Debug state must never leak into a campaign save or create unexplained player advantages after leaving the Arena. The detailed workflow and scenarios live in `12_DEVELOPER_ARENA.md`.
