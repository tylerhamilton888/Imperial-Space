# Reference Art Guide

The [close Karth Vale gameplay target](06_karth_vale_art_target.jpg) and boards 07–10 are the owner’s references for finished scenes. Compare a playable frame with it using the [art acceptance criteria](../docs/03_ART_DIRECTION.md#karth-vale-gameplay-art-target). Camera angle and composition are flexible.

The following five boards are compressed derivatives of concept images supplied in the conversation. They show visual development, not actual gameplay, production-ready sprites or final approved armor. Their old Space Crusader titles, generated labels and emblems are not canonical. **Imperial Space** is the working title.

The written design takes precedence where a board contains a rejected or overly derivative shape. Interpret the references selectively rather than tracing a whole suit.

| Reference | Keep | Change or do not infer |
| --- | --- | --- |
| [01 Visual style](01_visual_style.jpg) | The B direction's color separation, readable battlefield shapes and expressive portraits. | Rounded marine-like armor is not final. UI shown is illustrative; generated screen composition is not evidence of a build. |
| [02 Cloaks and weapons](02_cloaks_and_weapons.jpg) | Grand cloth, regal bearing, substantial firearms and melee equipment; contrasting traditions. | Do not implement every pictured weapon or cosmetic family. Avoid familiar franchise ornament and silhouettes. |
| [03 Helmet variants](03_helmet_variants.jpg) | Multiple helmet families and palettes can coexist as loot. Severe, sculpted or crowned visages fit. | Six directions do not require six production helmets in the first milestone. Design original insignia and clean functional geometry. |
| [04 Armor weights](04_armor_weights.jpg) | Readable Light/Medium/Heavy progression and retained human stature; cloak continuity. | Heavy mass still needs a distinct original design. Do not simply copy the rounded shoulder treatment. |
| [05 Heavy collar variants](05_heavy_collar_variants.jpg) | The collar-like enclosure and squared imposing mass; recessed and prominent helmet alternatives. | User liked the uniform-collar idea while remaining concerned about Space Marine resemblance. Treat this as a refinement target, not a final asset. |

## Additional accepted concepts

- [07 • Imperial Proving Ground](07_proving_ground.jpg) establishes range architecture, fixtures and the control panel.
- [08 • Karth Vale, wide](08_karth_vale_wide.jpg) establishes district scale, connected levels, greenery and the transit corridor.
- [09 • Cruiser Bridge](09_cruiser_bridge.jpg) establishes room composition, Vale’s visual presentation and the dialogue layout.
- [10 • Heavy Proving Ground](10_proving_ground_heavy.jpg) establishes Heavy mass, stance, cloak and weapon silhouette in the same range.

See the [scene acceptance criteria](../docs/03_ART_DIRECTION.md#scene-specific-acceptance-targets) and [prepared kit](../art_studies/README.md).

## Use in implementation

First make one readable Medium Crusader moving and fighting in the real arena. Review a small actual gameplay screenshot against the principles above. Establish hand positions, muzzle anchors, foot pivot, directional facing and cloak ordering. Then expand to Light and Heavy.

The images retain their original composition and color; only technical resizing/compression for review is allowed in these derivatives. Their source filenames, SHA-256 hashes, dimensions and derivative byte counts are in [source_manifest.json](source_manifest.json). Preserve original sources separately. These references belong outside the Godot runtime root.

Do not reload every board for every coding task. Open the relevant board once and rely on the compact written art direction thereafter. The character candidates in the cast specification are proposed descriptions, not newly generated portraits hidden elsewhere in the package.
