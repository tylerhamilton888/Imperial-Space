# Art Direction and Production

## Chosen direction

Use colorful, readable illustrated science fiction with heroic anatomy, substantial materials and an industrial foundation. The preferred visual comparison is option B: stronger color separation, expressive portraits and clear silhouettes. Its rounded armor is not an approved final character. Keep the readability while moving the Crusader toward a tall, imposing, regal silhouette.

Black and crimson express strength and authority; they do not automatically signify villainy. Ivory/gold, steel/blue, charcoal/bronze and restrained forest green also belong. An Imperial standard creates a common visual language, while personal artificers allow distinct equipment traditions.

## Shape language

Crusaders are noticeably larger than ordinary men, with powerful shoulders, a muscular chest, strong legs and a visible waist. Preserve the impression of a formidable man inside armor. A broad but integrated shoulder line, long vertical plates, a high uniform-like collar, severe mask and heavy cloth produce authority without relying on enormous spherical shoulder pads.

Use original panel proportions and construction. Avoid the combined silhouette of Space Marine round pauldrons, barrel chest and oversized backpack; avoid a recognizable Vader helmet, breathing panel or chest control box; avoid a recognizable Spartan helmet/visor package. These are visual development exclusions, not a legal clearance opinion. Franchise names remain internal reference shorthand and should not appear in game-facing names or marketing.

| Weight | Required visual behavior | Avoid |
| --- | --- | --- |
| Light | Compact full protection, articulated joints, narrow equipment profile, enough freedom for precise footwork. | A normal-sized weak scout, exposed combat face, or unarmored bodysuit replacing the Crusader fantasy. |
| Medium | Heroic proportions, visible torso articulation, strong uniform collar, balanced plates and equipment. | Generic tactical soldier silhouette with no regal character. |
| Heavy | Squared mass, layered chest and shoulders, raised collar, braced hips and powerful feet; visible human head/torso relationship. | Simply enlarging Medium, hiding every human proportion, or duplicating a recognizable franchise suit. |

The favored heavy study uses a collar-like enclosure around the head. Both a recessed protected head and a more prominent helm can exist as variants. Prototype one. The user has not required a single universal heavy helmet arrangement.

## Traditions and customization

Imperial Standard, Knightly and Military are appearance traditions, independent of weight and build. Standard favors ordered panels, vertical trim and formal collars; Knightly favors faceplate character, heraldry and long cloth; Military favors plain durable surfaces and practical fittings. Norse or more fearsome personal styles can come later without becoming new classes.

The six helmet families in the reference are valid directions for future loot: sculpted visage, crowned, faceless, enclosed knightly, practical assault and imposing warlord. They are not six mandatory launch animation sets. Start with one excellent helmet and palette masks. Do not accept generated labels, tiny emblems or visibly derivative ornament as finalized content.

Combat helmets remain on. A worn cloak remains visible through movement, attacks and transitions. Cloaks are optional equipment presentation. Use a few authored cloth poses or a simple secondary-motion treatment; do not make cloth physics a dependency. Do not hide the cloak to solve every clipping problem. Test weapons, shoulder rotation and cloak occlusion together before multiplying variants.

## Characters and environment scale

Adult male characters are conventionally handsome and masculine; adult female characters are conventionally attractive and feminine. Physiques communicate good health, confidence and capability. Uniforms flatter the wearer while remaining credible for the job. Crew designs need distinct faces, silhouettes, posture and personalities, not interchangeable portraits with different hair. See the cast document for proposed characters.

Use a human defender as the scale reference for doors, rails, consoles, seating and street furniture. Establish dimensions before scattering props. A Crusader should feel large because humans and architecture remain coherent, not because stairs, cover and tables change size between scenes. Objects need contact shadows and believable support; avoid floating set dressing or random indoor furniture outdoors.

Human worlds should contain signs of worthwhile ordinary life: housing, transit, green spaces, functioning workshops, public gathering areas and recognizable civic infrastructure. Show battle damage against that baseline. The restored version changes smoke, light, banners, traffic, barricades and people, using the same modular scene wherever possible.

Khorgoth are heavy, aggressive biological warriors with their own anatomy, tools, trophies and warhost markings. Avoid green comic orcs with a different name. Distinguish roles through stance and equipment silhouettes. Harvesters later contrast attractive near-human masks with a specific unsettling predatory anatomy; do not spend the first art budget on them.

## Practical production route

**Recommendation:** fixed three-quarter 2D presentation with layered character art, selected pose swaps and authored attack frames. This avoids making a complete high-quality 3D character pipeline a prerequisite. It still requires consistent drawing, rigging, animation and integration. A beautiful generated illustration does not automatically produce usable sprites.

Build the following proof in the arena before making a roster:

1. Set one camera scale and ground plane. Target a Crusader approximately 120–160 pixels tall at the initial 1080p view, then adjust by playtest. Keep aim and foot collisions on the ground plane.
2. Put a human defender, a Crusader, one Khorgoth, one door and one piece of cover in the same actual scene. Validate relative scale and readability at normal zoom.
3. Separate required parts only: body, weapon/arms where needed, helmet and cloak. Use consistent pivots at the feet and explicit hand/muzzle anchors per facing and pose.
4. Prove movement, a rifle shot, a sword strike, guard, dodge and a hit reaction. Four facings may be used for the first proof. Target eight for the integrated slice only after the pipeline works; document any reduced-facing compromise and its visual impact.
5. Make near/far arm, weapon and cloak ordering depend on facing. Do not rotate a flat standing illustration around its feet to fake all camera views. Mirroring is acceptable only where it preserves handedness, lighting and asymmetrical equipment.
6. Demonstrate one Medium armor set and one weapon swap with no detached hands or drifting head. Then adapt Light and Heavy silhouettes with shared skeleton/anchors where useful. Do not promise that different proportions share every animation unchanged.
7. Export small frames/atlases, validate them, and inspect the result in motion. Only then add portraits, extra helmets and environment decoration.

Movement and facing may be quantized for art while aiming remains continuous. The muzzle position and projectile ray must agree sufficiently that cover behaves honestly. Transparent cloth must not conceal essential enemy telegraphs; lower distracting contrast or use a restrained outline rather than deleting the cloak.

## Minimum animation inventory

The foundation needs idle, locomotion, rifle firing/reload, sword attack, guard/parry, dodge, hit reaction and defeat. The precision rifle initially reuses the rifle animation profile with its own timing and effects. The integrated slice adds hammer and cannon actions, signature abilities, a short interaction and an execution only if that action is retained. Enemies need readable anticipation, active contact and recovery, plus hit and death. The warlord needs an explicit damaged-arm variant. Placeholder timing effects are acceptable early; they do not satisfy final attack readability.

Do not make every movement frame for every proposed physique. One base Crusader rig and cosmetic portrait choices are enough to validate the game. Different physiques are primarily cosmetic long-term options, not mandatory first-slice body variants.

## References and asset status

Read [the reference guide](../reference_art/README.md) before opening the boards. It states which attributes to keep and which remain problematic. The five JPEG derivatives preserve earlier concepts in a manageable form. Source provenance and byte counts are in the manifest; these images belong outside runtime assets.

Prefer purposeful silhouettes, concise impact effects, restrained camera shake, clear hit sounds and readable battlefield contrast over ever larger textures. An actual gameplay screenshot is the evidence for a successful visual milestone. Do not substitute a generated mock screenshot or concept board for that evidence.
