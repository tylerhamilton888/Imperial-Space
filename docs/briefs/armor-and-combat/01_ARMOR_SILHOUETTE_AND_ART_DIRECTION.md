# Imperial Space — Armor Silhouette and Art Direction

## Status and authority

**Approved direction:** the latest Medium/Heavy comparison board was accepted by the owner as the direction to develop. Use [the approved silhouette reference](references/approved_medium_heavy_silhouettes.jpg) with this brief. The approval concerns the distinction between the two armor constructions and their shared Imperial identity. It does not prove that production sprites, animation, collision, equipment swapping, or the pictured details already work in the game.

This is a focused addition to the existing design. Preserve the project’s gameplay, Godot architecture, scope, and Developer Arena priority. Read the project’s current instructions and context files before implementation. Audit the existing art pipeline and improve it in place where practical; do not restart the project to match a concept sheet. Numeric review suggestions below are proposed working targets unless explicitly identified as existing project budgets.

## 1. The visual promise

The player is a physically exceptional human warrior wearing an individually fitted suit of advanced armor. His anatomy, bearing, equipment, and deeds convey his power. Armor augments that man; the figure should remain recognizably wearable and capable of deliberate movement.

The common aesthetic is **Imperial knighthood expressed through industrial science fiction**: articulated plate, enclosed helmets, imposing collars, substantial firearms, practical mechanisms, personal heraldry, and grand cloth. Rich readable colors and carefully chosen detail support a mature heroic tone. Preserve the contrast between a capable, inhabited human realm and the violence its champions can unleash against active enemies.

Male Crusaders should be massive, masculine, and conventionally handsome when unhelmeted. Their physiques may range from athletic to exceptionally broad without quietly creating different gameplay statistics. Adult female characters should retain the established conventionally attractive, feminine direction, with flattering, properly fitted clothing appropriate to their roles. These preferences should yield distinct characters rather than identical faces and uniforms.

## 2. Medium and Heavy must have different outlines

The earlier heavy attempts failed in two different ways: one became an oversized machine-like enclosure with a tiny buried head; the next mostly returned to the medium suit’s silhouette. **Neither is the approved target.** The accepted board changes construction, outline, and distribution of mass while retaining human proportions.

| Feature | Medium — approved baseline | Heavy — approved distinction |
| --- | --- | --- |
| Shoulders | Sloping, overlapping plates following the upper arm | Broad, nearly horizontal mantle with chamfered structural housings and short hanging upper-arm plates |
| Helmet position | Clearly above the shoulder line | Lower relative to raised shoulders and back protection, but full faceplate and crown remain readable |
| Collar and back | Pronounced gorget integrated with a mobile harness | Squared protective collar and reinforced upper-back yoke, without a towering box around the entire head |
| Chest and waist | Strong breastplate tapering into a pronounced waist | Deeper, broader chest above a robust, visibly articulated waist |
| Hips and thighs | Flowing, diagonal overlapping protection | Larger separated hip guards and substantial thigh protection with clear joint gaps |
| Knees and shins | Articulated knees and tapered greaves | Squared knee defenses and broad, comparatively straight-sided greaves |
| Overall rhythm | Sloping shoulders, taper, elegant articulation | Horizontal upper mass, recessed elbows, protected hips, substantial lower legs |

Heavy does not gain its identity solely from being taller, closer to the camera, redder, or more decorated. Use an equal-height comparison first. Its broad shoulder mantle and lower-body construction should remain distinguishable when color, surface detail, and weapons are removed.

Keep the helmet large enough to read as a human head. The back yoke may rise behind it; the front collar must leave the faceplate visible. The wearer needs a plausible neck position and turning clearance. Heavy’s waist, pelvis, separate legs, and arm joints should remain intelligible. Avoid a huge upper body perched on unchanged slim legs, giant mitten hands, or flattened vehicle-like feet.

## 3. Armor weight and visual tradition are separate

Light, Medium, and Heavy describe functional equipment types. Imperial Standard, knightly, military, hunting, and other personal traditions describe appearance. Do not convert this board into three permanent classes, personalities, or compulsory orders.

The antlered hunter remains a useful example of personal character: crest, heraldry, meaningful keepsakes, and a carried instrument. An antlered helmet does not automatically make its wearer Light. A polished knight may use Heavy; a severe military appearance may use Medium. Maintain recognizable weight silhouettes within those traditions.

Light retains its established agile, stealth-capable purpose, but this board does not finalize its appearance. Develop its compact protection and mobile silhouette after the Medium/Heavy distinction works. Label that exploration honestly instead of presenting an unreviewed Light design as approved.

Preserve equipment rules: the player chooses an essential armor type before deployment and may replace compatible pieces found during a mission. A Heavy wearer can equip a suitable Heavy helmet upgrade in the field; switching to Light equipment requires the appropriate later loadout opportunity. The art system must support that rule rather than silently broadening it.

## 4. Wearability is a design requirement

Evaluate the suit around the body throughout movement, not only in a handsome standing pose.

- Place the wearer’s shoulder, elbow, wrist, hip, knee, and ankle joints before adding external armor. Plates and flexible connections must accommodate those positions.
- Leave usable space beneath the shoulder mantle and around the elbows. A two-handed weapon needs a credible path across the chest.
- Keep firing hands attached to real grips. The stock, collar, breastplate, and head cannot occupy the same space. Show muzzle direction and hand placement consistently.
- Attach holstered weapons through identifiable mounts. Handles, scabbards, and hammer heads must clear legs and the equipped cloak during the intended motion.
- Separate hip protection enough to permit a stride, planted stance, and knee flexion. A broad armored skirt cannot remain rigid while the legs pass through it.
- Ground the figure through feet, weight transfer, and contact shadows. Decorative shoulder width does not by itself require a larger gameplay hurtbox or floor collision shape; review those separately against existing combat design.

Do not add speed penalties, long input locks, or cumbersome handling simply because Heavy looks substantial. Its juggernaut role must remain enjoyable under the combat brief.

## 5. Helmet, cloth, color, and heraldry

Helmets stay on in combat. Unhelmeted appearances belong to appropriate shipboard or safe narrative moments. Never replace a combat helmet with a portrait head to improve facial visibility.

Cloaks are optional equipment visually, but an equipped cloak remains present in combat, movement, and interaction. Plan attachment points and directional layering from the start. The cloth should fall from the shoulders or rear yoke, respond to motion with weight, and leave hands and weapons readable. It must not vanish during attacks or become a permanently stretched triangle.

Diagnostic cloak-free renders are permitted for silhouette evaluation; they are review tools, not a rule for hiding equipped cloth in ordinary play. Test the final silhouette with the cloak present as well.

Blackened steel, selective brass, and crimson are strong defaults. Ivory, navy, green, and other established palettes can coexist. Armor pieces should retain recognizable construction under recoloring. Use broad material and color areas first; engraving, scratches, and insignia are secondary at gameplay scale.

Imperial insignia expresses allegiance; personal arms identify the individual; honors can record service. Avoid filling every surface with the same symbol. Civilians do not all wear the Crusader’s personal heraldry. Reference existing franchise art only for broad proportions or mood; create original helmets, devices, plate geometry, and construction details.

## 6. Production art must survive the game camera

Use the concept to establish shapes and materials, then author reusable production assets appropriate to the current rendering pipeline. A flattened illustration placed behind a HUD cannot demonstrate a functioning armor system.

Review both suits at the actual default gameplay camera, in the supported facing directions, with real movement and attacks. Do not zoom in only for Heavy or enlarge its portrait to manufacture distinction. Keep the same ground plane, foot pivot convention, and ordinary-human scale reference.

For a fresh comparison, use matching pose, facing, lighting, standing height, palette, and cloak placement. Then inspect small solid-black armor-only silhouettes. As a proposed review aid, compare reductions around 96–128 pixels tall alongside the actual in-game size; choose the final scale from the project’s camera and readability needs. Do not treat those suggested pixel counts as mandatory character dimensions.

Large shoulder shapes, helmet position, hip guards, and greaves should carry the result. If readability depends on tiny engravings or extra particles, revise the construction. Check recognition against both bright civic paving and darker industrial surroundings.

## 7. Equipment and animation integration

Use the existing animation and attachment architecture where it can deliver coherent results. Record supported facings, frame sizes, foot pivots, weapon grips, muzzle locations, cloak anchors, and layer order in one asset manifest. Audit these agreements before expanding the equipment catalog.

Modular visual slots are a production technique, not a new player-facing assembly system. Preserve complete weapons and the existing manageable equipment choices. Begin with one Medium suit, one Heavy suit, one firearm, one melee weapon, and the relevant cloak treatment. Add compatible variants after they work together.

At minimum, demonstrate idle, locomotion, turning, firearm handling, a melee attack, defense, and a hit response in the first integrated sample. Include diagonal facings if the game supports them. Draw or animate the directional relationships deliberately; rotating a painted character card is not a substitute for a convincing turn.

Synchronize body, weapon, and cloth with the combat event timing. The shot must leave the displayed muzzle; the striking surface must reach the contact location; recoil must resolve through arms and torso; feet must recover their stance. Heavy can show greater mass through measured weight transfer and firmer planting while preserving prompt control. See the companion combat brief for commitment, impact, and response behavior.

## 8. Scene logic and the realm’s tone

Friendly places should feel inhabited, capable, and worth defending: useful transit, maintained gardens, functioning workshops, competent crews, and understandable circulation. Industrial machinery must have access and purpose. Keep architecture and props at a consistent human scale, with purposeful doorways, stairs, cover, and workstations.

During an evacuation under fire, civilians move urgently toward real cover. Show fear, concentration, and strained relief. They do not smile, stroll, or pause to admire the hero in an exposed firing lane. Position the knight to protect a believable crossing while walls and doors protect the remaining route. Soldiers need clear firing lanes that do not pass through him or the civilians.

A peaceful return can show affection, relaxed posture, and public life after the danger has passed. Enemy-facing scenes can show decisive force through broken defenses, strong reactions, and destructive impacts. Match behavior to the actual mission state; a smiling crowd and incoming fire cannot simply coexist because both make an attractive illustration.

Check physical implications of scenery. For example, shattered greenhouse glass can open onto a habitable planet; an exposed orbital habitat requires an established containment explanation. This brief does not change the broader narrative, mission contracts, or faction politics.

## 9. Implementation sequence and evidence

1. **Audit current work.** Identify existing Medium/Heavy assets, camera scale, animation method, attachments, collision, asset budgets, and known defects. Report what exists without assuming a feature is implemented because a concept depicts it.
2. **Prove the outline.** Create a controlled equal-height Medium/Heavy comparison and armor-only silhouettes. Resolve shape and wearability before decorating additional variants.
3. **Integrate one small arena sample.** Use a polished reusable corner, a human scale reference, and one representative enemy. Demonstrate both armor types with the same representative actions.
4. **Review motion and contact.** Capture short actual gameplay footage and compact stills. Include turns, an attack, defense, a hit, and passage behind cover. Identify remaining placeholders explicitly.
5. **Expand from the proven construction.** Reuse the agreed pivots, lighting, material treatment, layering, and geometry across additional gear and environments. Continue independent combat-system work while visual feedback is pending.

## 10. Acceptance and context preservation

Accept the direction in the implemented sample when Medium and Heavy are distinguishable by silhouette; the heavy wearer remains recognizably human; joints and equipment work in motion; the helmet and equipped cloak remain consistent; and the assets share the environment’s perspective, lighting, and rendering quality. Reject a return to the giant machine-like enclosure, a merely enlarged Medium suit, floating attachments, sliding feet, or detailed characters on visibly unfinished geometric surroundings.

Preserve separate concise Markdown context files. Reuse existing equivalents where available: an art-direction record for approved/rejected decisions; an asset manifest for pivots, layers, sources, and compatibility; a tuning or test record for observations; and a progress file listing the next concrete task. Store links to the reference once. Do not reload every concept image for unrelated coding work or copy this entire brief into every context file.

Existing project budgets remain: **chat previews at most 1280 pixels on the long edge and 600 KiB; runtime atlases at most 2048 pixels per edge and 3 MiB encoded.** These are project working limits, not platform guarantees or total memory budgets. Preserve high-quality sources separately, resize only review derivatives, and split useful asset families when required. Never inline base64 image payloads or dump atlas data into a response. Deliver compact evidence of what changed and state clearly what was actually verified in the running game.
